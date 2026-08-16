package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import java.util.ArrayDeque
import java.util.concurrent.Executors

/**
 * Browser-only protection shared by both Android distributions.
 *
 * Settings/package-installer monitoring deliberately lives only in the
 * research source set so it cannot be included in the Play binary.
 */
abstract class BrowserProtectionAccessibilityService : AccessibilityService() {
    companion object {
        const val CHANNEL_ID = "gamblock_protection"
        const val NOTIFICATION_ID = 1001

        private val SUPPORTED_BROWSERS = setOf(
            "com.android.chrome",
            "com.chrome.beta",
            "com.chrome.dev",
            "com.chrome.canary",
            "com.google.android.apps.chrome",
            "com.microsoft.emmx",
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
            "com.uc.browser.en",
            "com.UCMobile.intl",
        )
        private val URL_RESOURCE_IDS = listOf(
            "com.android.chrome:id/url_bar",
            "com.android.chrome:id/search_box_text",
            "com.android.chrome:id/location_bar_edit_text",
            "com.android.chrome:id/line_1",
            "com.android.chrome:id/omnibox_title_view",
            "com.microsoft.emmx:id/url_bar",
            "com.microsoft.emmx:id/location_bar_edit_text",
            "com.microsoft.emmx:id/search_box_text",
            "com.sec.android.app.sbrowser:id/location_bar_edit_text",
            "com.sec.android.app.sbrowser:id/url_bar",
            "org.mozilla.firefox:id/toolbar_url",
            "org.mozilla.firefox:id/mozac_browser_toolbar_url_view",
            "com.brave.browser:id/url_bar",
            "com.opera.browser:id/url_field",
        )

        fun isNavigationContentChange(changeTypes: Int): Boolean {
            return (changeTypes and (
                AccessibilityEvent.CONTENT_CHANGE_TYPE_SUBTREE or
                    AccessibilityEvent.CONTENT_CHANGE_TYPE_PANE_APPEARED or
                    AccessibilityEvent.CONTENT_CHANGE_TYPE_PANE_DISAPPEARED
                )) != 0
        }

        fun looksLikeUrl(value: String): Boolean {
            val trimmed = value.trim()
            return trimmed.startsWith("http://") ||
                trimmed.startsWith("https://") ||
                (trimmed.contains('.') && !trimmed.contains(' ') && trimmed.length >= 4)
        }

        fun isBetterUrlCandidate(candidate: String, current: String): Boolean {
            if (current.isEmpty()) return true
            val candidateIsUrl = looksLikeUrl(candidate)
            val currentIsUrl = looksLikeUrl(current)
            if (candidateIsUrl != currentIsUrl) return candidateIsUrl
            val candidateHasScheme =
                candidate.startsWith("http://") || candidate.startsWith("https://")
            val currentHasScheme =
                current.startsWith("http://") || current.startsWith("https://")
            if (candidateHasScheme != currentHasScheme) return candidateHasScheme
            return candidate.length > current.length
        }
    }

    protected open val additionalObservedPackages: Set<String> = emptySet()

    protected open val additionalBrowserPackages: Set<String> = emptySet()

    private val observedBrowsers: Set<String>
        get() = SUPPORTED_BROWSERS + additionalBrowserPackages

    private val worker = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private lateinit var classifier: HybridClassifier
    protected lateinit var aggregateStore: DailyAggregateStore
    protected lateinit var stateStore: ProtectionStateStore
    protected lateinit var overlay: PatternInterruptOverlay
    private lateinit var phase4Evidence: Phase4EvidenceRecorder
    private var lastSignature = 0
    private var lastDecisionAt = 0L
    private var pendingScan: Runnable? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        serviceInfo = serviceInfo.apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                AccessibilityEvent.TYPE_VIEW_CLICKED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 150
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
            packageNames = (observedBrowsers + additionalObservedPackages).toTypedArray()
        }
        classifier = HybridClassifier(applicationContext)
        aggregateStore = DailyAggregateStore(applicationContext)
        stateStore = ProtectionStateStore(applicationContext)
        overlay = PatternInterruptOverlay(this, NativeConfig.webBaseUrl(this))
        phase4Evidence = Phase4EvidenceRecorder(applicationContext)
        HealthNotificationPreferences.show(this)
        NativeEventBus.emit(snapshotEvent())
        onProtectionServiceConnected()
        worker.execute {
            val loaded = classifier.load()
            mainHandler.post {
                if (loaded) {
                    stateStore.setStatus("active")
                } else {
                    stateStore.setStatus("degraded", "artifact_invalid")
                }
                NativeEventBus.emit(snapshotEvent())
            }
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        val sourcePackage = event.packageName?.toString() ?: return
        if (sourcePackage in observedBrowsers) {
            if (!isNavigationLike(event)) return
            scheduleBrowserScan(event)
            return
        }
        handleAdditionalAccessibilityEvent(sourcePackage)
    }

    private fun isNavigationLike(event: AccessibilityEvent): Boolean {
        return when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_VIEW_CLICKED -> true

            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                isNavigationContentChange(event.contentChangeTypes)
            }

            else -> false
        }
    }

    protected open fun handleAdditionalAccessibilityEvent(sourcePackage: String) = Unit

    protected open fun onProtectionServiceConnected() = Unit

    protected open fun onProtectionServiceDestroyed() = Unit

    private fun scheduleBrowserScan(event: AccessibilityEvent) {
        if (stateStore.activeGrantAllowsProtectionPause()) {
            stateStore.setStatus("paused")
            NativeEventBus.emit(snapshotEvent())
            return
        }
        pendingScan?.let(mainHandler::removeCallbacks)
        val runnable = Runnable {
            val root = rootInActiveWindow ?: event.source
            val input = extractSignals(event, root)
            // Transient intermediate frames during navigation are normal; ignore without degrading
            if (input == null) return@Runnable

            worker.execute {
                val result = classifier.classify(input)
                val signature = listOf(input.url, input.title, input.headings, input.anchorTexts).hashCode()
                val now = System.currentTimeMillis()
                if (signature == lastSignature && now - lastDecisionAt < 500 && result.decision != "block") {
                    return@execute
                }
                lastSignature = signature
                lastDecisionAt = now
                stateStore.setStatus("active")
                stateStore.setLastEventNow()
                if (result.decision == "block") {
                    aggregateStore.increment("block_count_sync")
                    aggregateStore.increment("intervention_shown")
                    mainHandler.post {
                        try {
                            performGlobalAction(GLOBAL_ACTION_BACK)
                            startActivity(
                                Intent(this@BrowserProtectionAccessibilityService, MainActivity::class.java).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                                    putExtra("open_intervention", true)
                                },
                            )
                            NativeEventBus.emit(
                                mapOf(
                                    "type" to "intervention_shown",
                                    "reason_code" to result.reasonCode,
                                    "model_version" to result.modelVersion,
                                    "ruleset_version" to result.rulesetVersion,
                                ),
                            )
                        } catch (_: Exception) {
                            overlay.showIntervention()
                        }
                    }
                } else {
                    NativeEventBus.emit(snapshotEvent())
                }
            }
        }
        pendingScan = runnable
        mainHandler.postDelayed(runnable, 300)
    }

    private fun extractSignals(
        event: AccessibilityEvent,
        root: AccessibilityNodeInfo?,
    ): ClassificationInput? {
        if (root == null) return null
        var url = ""
        for (resourceId in URL_RESOURCE_IDS) {
            val node = root.findAccessibilityNodeInfosByViewId(resourceId).firstOrNull()
            val value = node?.text?.toString()?.trim().orEmpty()
            if (value.isNotEmpty()) {
                url = value
                break
            }
        }
        val headings = mutableListOf<String>()
        val anchors = mutableListOf<String>()
        val bodyTexts = mutableListOf<String>()
        var fallbackUrlCandidate = ""
        val queue = ArrayDeque<AccessibilityNodeInfo>()
        queue.add(root)
        var visited = 0
        while (queue.isNotEmpty() && visited < 500) {
            val node = queue.removeFirst()
            visited++
            val rawText = (node.text?.toString() ?: node.contentDescription?.toString() ?: "").trim()
            val text = rawText.take(256)

            val viewId = node.viewIdResourceName?.lowercase().orEmpty()
            if (viewId.contains("url") || viewId.contains("location") || viewId.contains("search_box") || viewId.contains("address")) {
                if (rawText.isNotEmpty() && isBetterUrlCandidate(rawText, fallbackUrlCandidate)) {
                    fallbackUrlCandidate = rawText
                }
            } else if (rawText.isNotEmpty() && looksLikeUrl(rawText) && isBetterUrlCandidate(rawText, fallbackUrlCandidate)) {
                fallbackUrlCandidate = rawText
            }

            if (text.isNotEmpty()) {
                val isHeadingNode = (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && node.isHeading) ||
                    (text.length in 4..80 && (node.className == "android.widget.TextView" || node.className == "android.view.View"))
                if (isHeadingNode && headings.size < 32) {
                    headings.add(text)
                } else if ((node.isClickable || node.isFocusable) && anchors.size < 64) {
                    anchors.add(text)
                } else if (bodyTexts.size < 64) {
                    bodyTexts.add(text)
                }
            }
            for (index in 0 until node.childCount) {
                node.getChild(index)?.let(queue::add)
            }
        }

        val resolvedUrl = when {
            url.isNotEmpty() -> url
            looksLikeUrl(fallbackUrlCandidate) -> fallbackUrlCandidate
            fallbackUrlCandidate.isNotEmpty() -> fallbackUrlCandidate
            else -> ""
        }

        val title = (
            event.contentDescription?.toString()
                ?: event.text.firstOrNull()?.toString()
                ?: (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) root.paneTitle?.toString() else null)
                ?: headings.firstOrNull()
                ?: ""
        ).take(512)

        // Combine collected body text into anchors list to feed the classifier unigrams/bigrams
        val allSignals = anchors + bodyTexts
        if (resolvedUrl.isEmpty() && title.isEmpty() && headings.isEmpty() && allSignals.isEmpty()) {
            return null
        }
        return ClassificationInput(
            url = resolvedUrl,
            title = title,
            headings = headings,
            anchorTexts = allSignals.take(64),
        )
    }

    private fun snapshotEvent(): Map<String, Any?> {
        return mapOf(
            "type" to "protection_status",
            "platform" to "android",
            "status" to stateStore.status(),
            "service_running" to true,
            "sensor_status" to "connected",
            "permission_status" to "granted",
            "model_version" to classifier.modelVersion,
            "ruleset_version" to classifier.rulesetVersion,
            "degraded_reason_code" to stateStore.degradedReason(),
            "last_event_at" to stateStore.lastEventAt(),
        )
    }

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        onProtectionServiceDestroyed()
        pendingScan?.let(mainHandler::removeCallbacks)
        mainHandler.removeCallbacksAndMessages(null)
        overlay.dismiss()
        worker.shutdownNow()
        aggregateStore.increment("permission_revoked")
        stateStore.setStatus("inactive", "accessibility_disabled")
        NativeEventBus.emit(snapshotEvent())
        super.onDestroy()
    }
}
