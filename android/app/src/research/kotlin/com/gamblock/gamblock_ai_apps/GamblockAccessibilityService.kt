package com.gamblock.gamblock_ai_apps

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import java.util.ArrayDeque

/** Research distribution: browser protection plus transparent removal friction. */
class GamblockAccessibilityService : BrowserProtectionAccessibilityService() {
    companion object {
        private val NON_STANDARD_BROWSERS = setOf(
            "com.sec.android.app.sbrowser",
            "com.sec.android.app.sbrowser.beta",
            "com.samsung.android.app.sbrowser",
            "com.brave.browser",
            "com.opera.browser",
            "com.opera.mini.native",
            "com.opera.touch",
            "org.mozilla.firefox",
            "org.mozilla.firefox_beta",
            "org.mozilla.focus",
            "com.mi.globalbrowser",
            "com.vivo.browser",
            "com.heytap.browser",
            "com.coloros.browser",
            "com.oppo.browser",
            "com.duckduckgo.mobile.android",
            "com.uc.browser",
            "com.uc.browser.en",
            "com.UCMobile.intl",
        )
        private const val LAUNCHER_ARM_TTL_MS = 5_000L
        private const val DEVICE_ADMIN_PROMPT_COOLDOWN_MS = 10_000L
    }

    private val resolvedTamperPackages: ResolvedTamperPackages by lazy {
        TamperPackageResolver(this).resolve()
    }
    override val additionalObservedPackages: Set<String>
        get() = resolvedTamperPackages.observed
    override val additionalBrowserPackages: Set<String> = NON_STANDARD_BROWSERS
    override val additionalAccessibilityEventTypes: Int =
        AccessibilityEvent.TYPE_VIEW_LONG_CLICKED

    private lateinit var tamperOverlay: TamperWarningOverlay
    private lateinit var samsungScreenshotOcr: SamsungInternetScreenshotOcr
    private var launcherArmedUntilElapsedMs = 0L
    private var lastDeviceAdminPromptAtElapsedMs = 0L

    override fun onProtectionServiceConnected() {
        samsungScreenshotOcr = SamsungInternetScreenshotOcr(this)
        tamperOverlay = TamperWarningOverlay(this)
        if (!isDeviceAdminActiveForResearch()) {
            stateStore.setStatus("degraded", "device_admin_inactive")
            requestDeviceAdminActivationIfNeeded()
            ProtectionBridge.emit(this, snapshotMap())
        }
    }

    override fun onProtectionServiceDestroyed() {
        if (::samsungScreenshotOcr.isInitialized) samsungScreenshotOcr.close()
        if (::tamperOverlay.isInitialized) tamperOverlay.dismiss()
    }

    override fun requestAdditionalBrowserSignals(
        event: AccessibilityEvent,
        root: AccessibilityNodeInfo?,
        input: ClassificationInput,
        onReady: (ClassificationInput) -> Unit,
    ) {
        val packageName = event.packageName?.toString().orEmpty()
        if (!BrowserProtectionAccessibilityService.isSamsungInternetPackage(packageName) ||
            input.hasDomContent ||
            !::samsungScreenshotOcr.isInitialized
        ) {
            onReady(input)
            return
        }
        samsungScreenshotOcr.request(root, input, onReady)
    }

    override fun handleAdditionalAccessibilityEvent(
        event: AccessibilityEvent,
        sourcePackage: String,
    ) {
        val surface = resolvedTamperPackages.surfaceFor(sourcePackage)
        if (surface == TamperSurface.OTHER) return

        val sourceTexts = buildList {
            event.text.mapNotNull { it?.toString()?.trim() }
                .filter(String::isNotEmpty)
                .let(::addAll)
            event.contentDescription?.toString()?.trim()
                ?.takeIf(String::isNotEmpty)
                ?.let(::add)
            addAll(collectSingleNodeTexts(event.source))
        }
        val targetIdentifiers = setOf(
            packageName,
            "Gamblock-AI Research",
            "Gamblock-AI",
            "Gamblock AI Research",
            "Gamblock AI",
        )
        if (
            surface == TamperSurface.LAUNCHER &&
            event.eventType == AccessibilityEvent.TYPE_VIEW_LONG_CLICKED
        ) {
            if (TamperActionDetector.containsGamblockTarget(sourceTexts, targetIdentifiers)) {
                launcherArmedUntilElapsedMs = SystemClock.elapsedRealtime() + LAUNCHER_ARM_TTL_MS
            }
            return
        }

        // During an OEM system-UI transition the event can arrive before the
        // accessibility window root is available. The event/source labels are
        // still useful (and may contain the uninstall confirmation), so do not
        // drop the tamper check solely because the root is temporarily null.
        val root = rootInActiveWindow
        val observation = TamperObservation(
            surface = surface,
            eventKind = eventKind(event.eventType),
            sourceTexts = sourceTexts,
            windowTexts = root?.let { collectNodeTexts(it, limit = 320) }.orEmpty(),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = SystemClock.elapsedRealtime() <= launcherArmedUntilElapsedMs,
            sourceCheckable = event.source?.isCheckable == true,
            sourceChecked = event.source?.isChecked == true,
        )
        val action = TamperActionDetector.detect(observation)
        if (action == TamperAction.NONE) return
        launcherArmedUntilElapsedMs = 0L
        if (stateStore.activeGrantAllowsTamperAction(action.wireValue)) return

        val newlyPending = stateStore.recordPendingTamperAction(action.wireValue)
        if (newlyPending) {
            aggregateStore.increment("tamper_detected")
        }
        var surfaceCleared = safelyLeaveTamperSurface()
        // Xiaomi/Redmi can terminate the protection process immediately after
        // confirming force-stop. Re-request the OS uninstall guard while the
        // Accessibility event is still available; the durable tamper event is
        // already persisted above for replay after the next app launch.
        val adminPromptStarted = requestDeviceAdminActivationIfNeeded()
        if (!adminPromptStarted) {
            tamperOverlay.show(
                tamperAction = action.wireValue,
                onSafeDismiss = {
                    if (!surfaceCleared) {
                        surfaceCleared = safelyLeaveTamperSurface()
                    }
                },
            )
        }
        if (newlyPending) {
            stateStore.pendingApprovalEvent()?.let {
                ProtectionBridge.emit(this, it)
            }
        }
    }

    /**
     * Device Admin is the only supported uninstall guard for a sideloaded
     * Research app. It cannot prevent force-stop itself, so this is a
     * best-effort re-arm before an OEM completes the force-stop action.
     */
    private fun requestDeviceAdminActivationIfNeeded(): Boolean {
        if (!BuildConfig.SUPPORTS_CONTROLLED_REMOVAL) return false
        if (isDeviceAdminActiveForResearch()) return false

        val now = SystemClock.elapsedRealtime()
        if (now - lastDeviceAdminPromptAtElapsedMs < DEVICE_ADMIN_PROMPT_COOLDOWN_MS) {
            return false
        }
        lastDeviceAdminPromptAtElapsedMs = now

        return runCatching {
            val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val component = ComponentName(
                packageName,
                "com.gamblock.gamblock_ai_apps.ProtectionDeviceAdminReceiver",
            )
            if (dpm.isAdminActive(component)) return@runCatching false
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, component)
                putExtra(
                    DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                    getString(R.string.device_admin_explanation),
                )
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        }.getOrDefault(false)
    }

    private fun safelyLeaveTamperSurface(): Boolean {
        val backAccepted = performGlobalAction(GLOBAL_ACTION_BACK)
        if (backAccepted) return true
        val homeAccepted = performGlobalAction(GLOBAL_ACTION_HOME)
        stateStore.setStatus(
            "degraded",
            if (homeAccepted) "tamper_back_failed" else "tamper_cancel_failed",
        )
        return homeAccepted
    }

    private fun eventKind(eventType: Int): TamperEventKind = when (eventType) {
        AccessibilityEvent.TYPE_VIEW_CLICKED -> TamperEventKind.CLICK
        AccessibilityEvent.TYPE_VIEW_LONG_CLICKED -> TamperEventKind.LONG_CLICK
        AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> TamperEventKind.WINDOW_CHANGED
        AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> TamperEventKind.CONTENT_CHANGED
        else -> TamperEventKind.OTHER
    }

    private fun collectNodeTexts(
        startingNode: AccessibilityNodeInfo?,
        limit: Int,
    ): List<String> {
        if (startingNode == null) return emptyList()
        val result = mutableListOf<String>()
        val queue = ArrayDeque<AccessibilityNodeInfo>()
        queue.add(startingNode)
        var visited = 0
        while (queue.isNotEmpty() && visited < limit) {
            val node = queue.removeFirst()
            visited++
            node.text?.toString()?.trim()?.takeIf(String::isNotEmpty)?.let(result::add)
            node.contentDescription?.toString()?.trim()
                ?.takeIf(String::isNotEmpty)
                ?.let(result::add)
            for (index in 0 until node.childCount) {
                node.getChild(index)?.let(queue::add)
            }
        }
        return result
    }

    private fun collectSingleNodeTexts(node: AccessibilityNodeInfo?): List<String> {
        if (node == null) return emptyList()
        val result = mutableListOf<String>()
        node.text?.toString()?.trim()?.takeIf(String::isNotEmpty)?.let(result::add)
        node.contentDescription?.toString()?.trim()?.takeIf(String::isNotEmpty)?.let(result::add)
        // Some OEM buttons keep their label in a child view; walk a shallow
        // bounded subtree so the label still reaches the detector.
        val queue = ArrayDeque<AccessibilityNodeInfo>()
        for (index in 0 until node.childCount) {
            node.getChild(index)?.let(queue::add)
        }
        var visited = 0
        while (queue.isNotEmpty() && visited < 8 && result.size < 8) {
            val child = queue.removeFirst()
            visited++
            child.text?.toString()?.trim()?.takeIf(String::isNotEmpty)?.let(result::add)
            child.contentDescription?.toString()?.trim()?.takeIf(String::isNotEmpty)
                ?.let(result::add)
            for (index in 0 until child.childCount) {
                child.getChild(index)?.let(queue::add)
            }
        }
        return result.distinct()
    }
}
