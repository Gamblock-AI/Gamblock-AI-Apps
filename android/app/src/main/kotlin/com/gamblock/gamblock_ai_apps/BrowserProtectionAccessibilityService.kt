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
            "com.microsoft.emmx",
        )
        private val URL_RESOURCE_IDS = listOf(
            "com.android.chrome:id/url_bar",
            "com.microsoft.emmx:id/url_bar",
            "com.microsoft.emmx:id/location_bar_edit_text",
        )
    }

    protected open val additionalObservedPackages: Set<String> = emptySet()

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
            notificationTimeout = 250
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
            packageNames = (SUPPORTED_BROWSERS + additionalObservedPackages).toTypedArray()
        }
        classifier = HybridClassifier(applicationContext)
        aggregateStore = DailyAggregateStore(applicationContext)
        stateStore = ProtectionStateStore(applicationContext)
        overlay = PatternInterruptOverlay(this, NativeConfig.webBaseUrl(this))
        phase4Evidence = Phase4EvidenceRecorder(applicationContext)
        HealthNotificationPreferences.show(this)
        NativeEventBus.emit(snapshotEvent())
        onProtectionServiceConnected()
        // Model parsing + SHA-256 integrity verification are heavy; keep them
        // off the accessibility main thread. The single worker guarantees the
        // load finishes before the first classification.
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
        if (sourcePackage in SUPPORTED_BROWSERS) {
            // AI activates only on committed navigation (Enter/submit/link
            // click/page change), never on keystrokes or plain text edits.
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
                val changeTypes = event.contentChangeTypes
                (changeTypes and (
                    AccessibilityEvent.CONTENT_CHANGE_TYPE_SUBTREE or
                        AccessibilityEvent.CONTENT_CHANGE_TYPE_PANE_APPEARED or
                        AccessibilityEvent.CONTENT_CHANGE_TYPE_PANE_DISAPPEARED
                    )) != 0
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
            val scanStartedNanos = SystemClock.elapsedRealtimeNanos()
            val input = extractSignals(event, rootInActiveWindow)
            if (input == null) {
                stateStore.setStatus("degraded", "signal_unavailable")
                NativeEventBus.emit(snapshotEvent())
                return@Runnable
            }
            val inputReadyNanos = SystemClock.elapsedRealtimeNanos()
            worker.execute {
                val classificationStartedNanos = SystemClock.elapsedRealtimeNanos()
                val result = classifier.classify(input)
                val classificationFinishedNanos = SystemClock.elapsedRealtimeNanos()
                val signature = listOf(input.url, input.title, input.headings, input.anchorTexts).hashCode()
                val now = System.currentTimeMillis()
                if (signature == lastSignature && now - lastDecisionAt < 2500) {
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
                        performGlobalAction(GLOBAL_ACTION_BACK)
                        overlay.showIntervention {
                            phase4Evidence.recordLatency(
                                Phase4LatencySample(
                                    scanStartedNanos = scanStartedNanos,
                                    inputReadyNanos = inputReadyNanos,
                                    classificationStartedNanos = classificationStartedNanos,
                                    classificationFinishedNanos = classificationFinishedNanos,
                                    visibleNanos = SystemClock.elapsedRealtimeNanos(),
                                    modelVersion = result.modelVersion,
                                    rulesetVersion = result.rulesetVersion,
                                ),
                            )
                        }
                        NativeEventBus.emit(
                            mapOf(
                                "type" to "intervention_shown",
                                "reason_code" to result.reasonCode,
                                "model_version" to result.modelVersion,
                                "ruleset_version" to result.rulesetVersion,
                                "native_overlay" to true,
                            ),
                        )
                    }
                } else {
                    NativeEventBus.emit(snapshotEvent())
                }
            }
        }
        pendingScan = runnable
        mainHandler.postDelayed(runnable, 500)
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
        var fallbackEditable = ""
        val queue = ArrayDeque<AccessibilityNodeInfo>()
        queue.add(root)
        var visited = 0
        while (queue.isNotEmpty() && visited < 500) {
            val node = queue.removeFirst()
            visited++
            val text = (node.text?.toString() ?: node.contentDescription?.toString() ?: "")
                .trim()
                .take(256)
            if (fallbackEditable.isEmpty() && node.isEditable && text.length <= 2048) {
                fallbackEditable = text
            }
            if (text.isNotEmpty()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && node.isHeading && headings.size < 32) {
                    headings.add(text)
                }
                if ((node.isClickable || node.isFocusable) && anchors.size < 64) {
                    anchors.add(text)
                }
            }
            for (index in 0 until node.childCount) {
                node.getChild(index)?.let(queue::add)
            }
        }
        if (url.isEmpty() && looksLikeUrl(fallbackEditable)) url = fallbackEditable
        val title = (
            event.contentDescription?.toString()
                ?: event.text.firstOrNull()?.toString()
                ?: (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) root.paneTitle?.toString() else null)
                ?: ""
            ).take(512)
        if (url.isEmpty() && title.isEmpty() && headings.isEmpty() && anchors.isEmpty()) {
            return null
        }
        return ClassificationInput(
            url = url,
            title = title,
            headings = headings,
            anchorTexts = anchors,
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

    private fun looksLikeUrl(value: String): Boolean {
        return value.startsWith("http://") ||
            value.startsWith("https://") ||
            (value.contains('.') && !value.contains(' '))
    }

    override fun onInterrupt() {
        stateStore.setStatus("degraded", "accessibility_interrupted")
        NativeEventBus.emit(snapshotEvent())
    }

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
