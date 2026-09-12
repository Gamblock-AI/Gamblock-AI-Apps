package com.gamblock.gamblock_ai_apps

import android.os.SystemClock
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import java.util.ArrayDeque

/** Research-only browser package registry, isolated for local unit coverage. */
internal object ResearchBrowserPackages {
    const val UPX_BROWSER_PACKAGE = "net.upx.proxy.browser"

    val additionalBrowserPackages = setOf(
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
        UPX_BROWSER_PACKAGE,
    )
}

/** Research distribution: browser protection plus transparent removal friction. */
class GamblockAccessibilityService : BrowserProtectionAccessibilityService() {
    companion object {
        private const val TAG = "GamblockAccessibility"
        private const val LAUNCHER_ARM_TTL_MS = 5_000L
        private const val SETTINGS_ARM_TTL_MS = 5_000L
    }

    private val resolvedTamperPackages: ResolvedTamperPackages by lazy {
        TamperPackageResolver(this).resolve()
    }
    override val additionalObservedPackages: Set<String>
        get() = resolvedTamperPackages.observed
    override val additionalBrowserPackages: Set<String> =
        ResearchBrowserPackages.additionalBrowserPackages
    override val additionalAccessibilityEventTypes: Int =
        AccessibilityEvent.TYPE_VIEW_LONG_CLICKED

    private lateinit var tamperOverlay: TamperWarningOverlay
    private var samsungScreenshotOcr: SamsungInternetScreenshotOcr? = null
    private var launcherArmedUntilElapsedMs = 0L
    private var settingsArmedUntilElapsedMs = 0L

    override fun onProtectionServiceConnected() {
        samsungScreenshotOcr = SamsungInternetScreenshotOcr.createOrNull(this)
        tamperOverlay = TamperWarningOverlay(this)
        if (!isDeviceAdminActiveForResearch()) {
            stateStore.setStatus("degraded", "device_admin_inactive")
            ProtectionBridge.emit(this, snapshotMap())
        }
    }

    override fun onProtectionServiceDestroyed() {
        samsungScreenshotOcr?.close()
        samsungScreenshotOcr = null
        if (::tamperOverlay.isInitialized) tamperOverlay.dismiss()
    }

    override fun requestAdditionalBrowserSignals(
        event: AccessibilityEvent,
        root: AccessibilityNodeInfo?,
        input: ClassificationInput,
        onReady: (ClassificationInput) -> Unit,
    ) {
        val screenshotOcr = samsungScreenshotOcr
        val packageName = event.packageName?.toString().orEmpty()
        if (!BrowserProtectionAccessibilityService.isSamsungInternetPackage(packageName)) {
            screenshotOcr?.invalidate()
            onReady(input)
            return
        }

        val clickedNode = event.source.takeIf {
            event.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED
        }
        val pageState = try {
            SamsungInternetScreenshotOcr.capturePageState(root, packageName, clickedNode)
        } catch (error: RuntimeException) {
            Log.w(TAG, "Samsung page state unavailable: ${error.javaClass.simpleName}")
            screenshotOcr?.invalidate()
            return
        }
        if (!pageState.isEligible) {
            screenshotOcr?.invalidate()
            Log.d(TAG, "Samsung screenshot suppressed for non-page browser UI")
            return
        }
        if (input.hasDomContent || screenshotOcr == null) {
            screenshotOcr?.invalidate()
            onReady(input)
            return
        }
        Log.d(TAG, "requesting Samsung screenshot fallback")
        screenshotOcr.request(pageState, input, onReady)
    }

    override fun handleAdditionalAccessibilityEvent(
        event: AccessibilityEvent,
        sourcePackage: String,
    ) {
        val surface = resolvedTamperPackages.surfaceFor(sourcePackage)
        if (surface == TamperSurface.OTHER) {
            launcherArmedUntilElapsedMs = 0L
            settingsArmedUntilElapsedMs = 0L
            return
        }

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
        val nowElapsedMs = SystemClock.elapsedRealtime()
        if (
            surface == TamperSurface.LAUNCHER &&
            event.eventType == AccessibilityEvent.TYPE_VIEW_LONG_CLICKED
        ) {
            if (TamperActionDetector.containsGamblockTarget(sourceTexts, targetIdentifiers)) {
                launcherArmedUntilElapsedMs = nowElapsedMs + LAUNCHER_ARM_TTL_MS
            }
            return
        }

        // During an OEM system-UI transition the event can arrive before the
        // accessibility window root is available. The event/source labels are
        // still useful (and may contain the uninstall confirmation), so do not
        // drop the tamper check solely because the root is temporarily null.
        val root = rootInActiveWindow
        val windowTexts = root?.let { collectNodeTexts(it, limit = 320) }.orEmpty()
        val targetVisible =
            TamperActionDetector.containsGamblockTarget(sourceTexts, targetIdentifiers) ||
                TamperActionDetector.containsGamblockTarget(windowTexts, targetIdentifiers)
        if (surface != TamperSurface.SETTINGS) {
            settingsArmedUntilElapsedMs = 0L
        } else if (targetVisible) {
            settingsArmedUntilElapsedMs = nowElapsedMs + SETTINGS_ARM_TTL_MS
        }
        val observation = TamperObservation(
            surface = surface,
            eventKind = eventKind(event.eventType),
            sourceTexts = sourceTexts,
            windowTexts = windowTexts,
            targetIdentifiers = targetIdentifiers,
            launcherArmed = nowElapsedMs <= launcherArmedUntilElapsedMs,
            settingsArmed = nowElapsedMs <= settingsArmedUntilElapsedMs,
            sourceCheckable = event.source?.isCheckable == true,
            sourceChecked = event.source?.isChecked == true,
        )
        val action = TamperActionDetector.detect(observation)
        if (action == TamperAction.NONE) {
            if (
                surface == TamperSurface.SETTINGS &&
                observation.eventKind == TamperEventKind.CLICK &&
                !targetVisible
            ) {
                settingsArmedUntilElapsedMs = 0L
            }
            return
        }
        launcherArmedUntilElapsedMs = 0L
        settingsArmedUntilElapsedMs = 0L
        if (stateStore.hasApprovedRemovalPending()) return
        if (
            action != TamperAction.UNINSTALL &&
            stateStore.activeGrantAllowsTamperAction(action.wireValue)
        ) return

        val newlyPending = stateStore.recordPendingTamperAction(action.wireValue)
        if (newlyPending) {
            aggregateStore.increment("tamper_detected")
        }
        var surfaceCleared = safelyLeaveTamperSurface()
        tamperOverlay.show(
            tamperAction = action.wireValue,
            onSafeDismiss = {
                if (!surfaceCleared) {
                    surfaceCleared = safelyLeaveTamperSurface()
                }
            },
        )
        if (newlyPending) {
            stateStore.pendingApprovalEvent()?.let {
                ProtectionBridge.emit(this, it)
            }
        }
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
