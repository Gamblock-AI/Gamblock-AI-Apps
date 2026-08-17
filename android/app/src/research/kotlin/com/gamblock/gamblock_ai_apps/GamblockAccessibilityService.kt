package com.gamblock.gamblock_ai_apps

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
    private var launcherArmedUntilElapsedMs = 0L

    override fun onProtectionServiceConnected() {
        tamperOverlay = TamperWarningOverlay(this)
    }

    override fun onProtectionServiceDestroyed() {
        if (::tamperOverlay.isInitialized) tamperOverlay.dismiss()
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

        val root = rootInActiveWindow ?: return
        val observation = TamperObservation(
            surface = surface,
            eventKind = eventKind(event.eventType),
            sourceTexts = sourceTexts,
            windowTexts = collectNodeTexts(root, limit = 320),
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
        tamperOverlay.show(
            tamperAction = action.wireValue,
            onSafeDismiss = {
                if (!surfaceCleared) {
                    surfaceCleared = safelyLeaveTamperSurface()
                }
            },
        )
        if (newlyPending) {
            stateStore.pendingApprovalEvent()?.let(NativeEventBus::emit)
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
        return listOfNotNull(
            node.text?.toString()?.trim()?.takeIf(String::isNotEmpty),
            node.contentDescription?.toString()?.trim()?.takeIf(String::isNotEmpty),
        )
    }
}
