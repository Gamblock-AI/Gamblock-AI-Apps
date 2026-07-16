package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import java.util.ArrayDeque
import java.util.concurrent.Executors

class GamblockAccessibilityService : AccessibilityService() {
    companion object {
        const val CHANNEL_ID = "gamblock_protection"
        const val NOTIFICATION_ID = 1001
        private val supportedBrowsers = setOf(
            "com.android.chrome",
            "com.microsoft.emmx",
        )
        private val settingsPackages = setOf(
            "com.android.settings",
            "com.google.android.packageinstaller",
            "com.android.packageinstaller",
        )
        private val urlResourceIds = listOf(
            "com.android.chrome:id/url_bar",
            "com.microsoft.emmx:id/url_bar",
            "com.microsoft.emmx:id/location_bar_edit_text",
        )
    }

    private val worker = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private lateinit var classifier: HybridClassifier
    private lateinit var aggregateStore: DailyAggregateStore
    private lateinit var stateStore: ProtectionStateStore
    private lateinit var overlay: PatternInterruptOverlay
    private lateinit var artifactUpdater: ArtifactUpdater
    private var lastSignature = 0
    private var lastDecisionAt = 0L
    private var pendingScan: Runnable? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        serviceInfo = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                AccessibilityEvent.TYPE_VIEW_CLICKED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 250
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        }
        classifier = HybridClassifier(applicationContext)
        aggregateStore = DailyAggregateStore(applicationContext)
        stateStore = ProtectionStateStore(applicationContext)
        overlay = PatternInterruptOverlay(this, NativeConfig.webBaseUrl(this))
        artifactUpdater = ArtifactUpdater(applicationContext, classifier, aggregateStore)
        if (classifier.load()) {
            stateStore.setStatus("active")
        } else {
            stateStore.setStatus("degraded", "artifact_invalid")
        }
        HealthNotificationPreferences.show(this)
        NativeEventBus.emit(snapshotEvent())
        scheduleArtifactUpdate()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        val packageName = event.packageName?.toString() ?: return
        if (packageName in settingsPackages) {
            inspectTamperScreen()
            return
        }
        if (packageName !in supportedBrowsers) return
        scheduleBrowserScan(event)
    }

    private fun scheduleBrowserScan(event: AccessibilityEvent) {
        if (stateStore.activeGrant() != null) {
            stateStore.setStatus("paused")
            NativeEventBus.emit(snapshotEvent())
            return
        }
        pendingScan?.let(mainHandler::removeCallbacks)
        val runnable = Runnable {
            val input = extractSignals(event, rootInActiveWindow)
            if (input == null) {
                stateStore.setStatus("degraded", "signal_unavailable")
                NativeEventBus.emit(snapshotEvent())
                return@Runnable
            }
            worker.execute {
                val result = classifier.classify(input)
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
                        overlay.showIntervention()
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
        for (resourceId in urlResourceIds) {
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
                ?: if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) root.paneTitle?.toString() else null
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

    private fun inspectTamperScreen() {
        val root = rootInActiveWindow ?: return
        val texts = mutableListOf<String>()
        val queue = ArrayDeque<AccessibilityNodeInfo>()
        queue.add(root)
        var visited = 0
        while (queue.isNotEmpty() && visited < 300) {
            val node = queue.removeFirst()
            visited++
            node.text?.toString()?.takeIf(String::isNotBlank)?.let(texts::add)
            node.contentDescription?.toString()?.takeIf(String::isNotBlank)?.let(texts::add)
            for (index in 0 until node.childCount) {
                node.getChild(index)?.let(queue::add)
            }
        }
        val combined = texts.joinToString(" ").lowercase()
        val targetsGamblock = combined.contains("gamblock") || combined.contains(packageName.lowercase())
        val removalAttempt = listOf(
            "uninstall",
            "copot",
            "hapus aplikasi",
        ).any(combined::contains)
        val dangerous = listOf(
            "uninstall",
            "copot",
            "hapus aplikasi",
            "force stop",
            "paksa berhenti",
            "disable",
            "nonaktifkan",
            "accessibility",
            "aksesibilitas",
        ).any(combined::contains)
        if (!targetsGamblock || !dangerous) return
        if (stateStore.activeGrantAllowsSettingsAction(removalAttempt)) return
        aggregateStore.increment("tamper_detected")
        performGlobalAction(GLOBAL_ACTION_BACK)
        overlay.showTamperWarning()
        NativeEventBus.emit(mapOf("type" to "approval_required"))
    }

    private fun scheduleArtifactUpdate() {
        worker.execute {
            if (!artifactUpdater.check(NativeConfig.apiBaseUrl(this))) {
                stateStore.setStatus("degraded", "artifact_update_failed")
            }
            NativeEventBus.emit(snapshotEvent())
        }
        mainHandler.postDelayed(::scheduleArtifactUpdate, 24 * 60 * 60 * 1000L)
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
