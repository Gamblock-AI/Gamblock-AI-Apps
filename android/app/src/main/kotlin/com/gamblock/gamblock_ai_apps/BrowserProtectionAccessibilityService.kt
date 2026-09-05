package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityManager
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
            "com.microsoft.emmx.beta",
            "com.microsoft.emmx.dev",
            "com.microsoft.emmx.canary",
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
            "com.sec.android.app.sbrowser:id/location_bar",
            "com.sec.android.app.sbrowser:id/url_bar",
            "com.sec.android.app.sbrowser:id/url_bar_text",
            "com.sec.android.app.sbrowser:id/search_box_text",
            "com.sec.android.app.sbrowser:id/toolbar_url",
            "com.sec.android.app.sbrowser:id/location_bar_text",
            "com.sec.android.app.sbrowser.beta:id/location_bar_edit_text",
            "com.sec.android.app.sbrowser.beta:id/location_bar",
            "com.sec.android.app.sbrowser.beta:id/url_bar",
            "com.sec.android.app.sbrowser.beta:id/url_bar_text",
            "com.sec.android.app.sbrowser.beta:id/search_box_text",
            "com.sec.android.app.sbrowser.beta:id/toolbar_url",
            "com.sec.android.app.sbrowser.beta:id/location_bar_text",
            "com.samsung.android.app.sbrowser:id/location_bar_edit_text",
            "com.samsung.android.app.sbrowser:id/location_bar",
            "com.samsung.android.app.sbrowser:id/url_bar",
            "com.samsung.android.app.sbrowser:id/url_bar_text",
            "com.samsung.android.app.sbrowser:id/search_box_text",
            "com.samsung.android.app.sbrowser:id/toolbar_url",
            "com.samsung.android.app.sbrowser:id/location_bar_text",
            "org.mozilla.firefox:id/toolbar_url",
            "org.mozilla.firefox:id/mozac_browser_toolbar_url_view",
            "com.brave.browser:id/url_bar",
            "com.opera.browser:id/url_field",
        )
        private val SAMSUNG_INTERNET_PACKAGES = setOf(
            "com.sec.android.app.sbrowser",
            "com.sec.android.app.sbrowser.beta",
            "com.samsung.android.app.sbrowser",
        )
        private val SAMSUNG_PAGE_CONTENT_RESOURCE_IDS = setOf(
            "com.sec.android.app.sbrowser:id/content_layout",
            "com.sec.android.app.sbrowser.beta:id/content_layout",
            "com.samsung.android.app.sbrowser:id/content_layout",
        )
        private val ACCESSIBILITY_CONTROL_CHARS = Regex("[\\p{Cc}]")
        private val ACCESSIBILITY_FORMAT_CHARS = Regex("[\\p{Cf}]")
        private val ACCESSIBILITY_WHITESPACE = Regex("\\s+")
        private val SAMSUNG_BROWSER_CHROME_RESOURCE_MARKERS = listOf(
            ":id/location_bar",
            ":id/url_bar",
            ":id/search_box",
            ":id/toolbar",
            ":id/tab_",
        )
        private val TAB_SWITCHER_SURFACE_RESOURCE_MARKERS = listOf(
            "tab_switcher_view",
            "tab_switcher_toolbar",
            "tab_switcher_layout",
            "tab_grid",
            "tab_list",
            "tab_overview",
            "tab_model",
        )
        private val TAB_SWITCHER_CONTROL_RESOURCE_MARKERS = listOf(
            "tab_switcher",
            "tab_grid_button",
        )
        private const val TAB_SWITCHER_SETTLE_WINDOW_MS = 500L

        fun isNavigationContentChange(changeTypes: Int): Boolean {
            return (changeTypes and (
                AccessibilityEvent.CONTENT_CHANGE_TYPE_SUBTREE or
                    AccessibilityEvent.CONTENT_CHANGE_TYPE_PANE_APPEARED or
                    AccessibilityEvent.CONTENT_CHANGE_TYPE_PANE_DISAPPEARED
                )) != 0
        }

        fun looksLikeUrl(value: String): Boolean {
            val trimmed = normalizeAccessibilityText(value)
            return trimmed.startsWith("http://") ||
                trimmed.startsWith("https://") ||
                (trimmed.contains('.') && !trimmed.contains(' ') && trimmed.length >= 4)
        }

        fun isBetterUrlCandidate(candidate: String, current: String): Boolean {
            val normalizedCandidate = normalizeAccessibilityText(candidate)
            val normalizedCurrent = normalizeAccessibilityText(current)
            if (normalizedCurrent.isEmpty()) return true
            val candidateIsUrl = looksLikeUrl(normalizedCandidate)
            val currentIsUrl = looksLikeUrl(normalizedCurrent)
            if (candidateIsUrl != currentIsUrl) return candidateIsUrl
            val candidateHasScheme =
                normalizedCandidate.startsWith("http://") ||
                    normalizedCandidate.startsWith("https://")
            val currentHasScheme =
                normalizedCurrent.startsWith("http://") ||
                    normalizedCurrent.startsWith("https://")
            if (candidateHasScheme != currentHasScheme) return candidateHasScheme
            return normalizedCandidate.length > normalizedCurrent.length
        }

        fun normalizeAccessibilityText(value: String): String {
            return value
                .replace(ACCESSIBILITY_FORMAT_CHARS, "")
                .replace(ACCESSIBILITY_CONTROL_CHARS, " ")
                .replace(ACCESSIBILITY_WHITESPACE, " ")
                .trim()
        }

        fun isSamsungInternetPackage(packageName: String): Boolean {
            return packageName.trim().lowercase() in SAMSUNG_INTERNET_PACKAGES
        }

        fun isSamsungInternetPageContentResourceId(viewId: String): Boolean {
            return viewId.trim().lowercase() in SAMSUNG_PAGE_CONTENT_RESOURCE_IDS
        }

        fun isSamsungInternetChromeResourceId(viewId: String): Boolean {
            val normalized = viewId.trim().lowercase()
            return normalized.isNotEmpty() &&
                SAMSUNG_BROWSER_CHROME_RESOURCE_MARKERS.any { normalized.contains(it) }
        }

        /**
         * Browser tab overview controls are browser chrome, not page content.
         * Keep this local structural check deliberately narrow: it only uses
         * native accessibility metadata and never sends it outside the device.
         */
        fun isTabSwitcherResourceId(viewId: String): Boolean {
            val normalized = viewId.trim().lowercase()
            return normalized.isNotEmpty() &&
                TAB_SWITCHER_SURFACE_RESOURCE_MARKERS.any { normalized.contains(it) }
        }

        fun isTabSwitcherClassName(className: String): Boolean {
            val normalized = className.trim().lowercase()
            return normalized.contains("tab") && (
                normalized.contains("grid") ||
                    normalized.contains("list") ||
                    normalized.contains("overview") ||
                    normalized.contains("model") ||
                    (normalized.contains("tabswitcher") && !normalized.contains("button"))
                )
        }

        fun isTabSwitcherUi(viewIds: List<String>, classNames: List<String>): Boolean {
            return viewIds.any(::isTabSwitcherResourceId) || classNames.any(::isTabSwitcherClassName)
        }

        fun isBrowserWebContentClassName(className: String): Boolean {
            val normalized = className.trim().lowercase()
            return normalized == "android.webkit.webview" ||
                normalized.endsWith(".webview") ||
                normalized.contains("webview")
        }

        /**
         * The provider runs in this same protection process and needs a live
         * service instance for truthful snapshots and bridge commands. Keep a
         * strong reference only for the service lifetime; onDestroy clears it.
         */
        @Volatile
        private var activeService: BrowserProtectionAccessibilityService? = null

        /** True only when a service instance is actually bound in this process. */
        fun isRunning(): Boolean = activeService != null

        fun current(): BrowserProtectionAccessibilityService? = activeService

        fun notifyFlutterVisibilityClaimed(interventionId: String) {
            activeService?.cancelNativeFallback(interventionId)
        }

        fun notifyInterventionCompleted(interventionId: String) {
            activeService?.onExternalInterventionCompleted(interventionId)
        }

        fun notifyFlutterPresentationLost(interventionId: String) {
            activeService?.onFlutterPresentationLost(interventionId)
        }
    }

    protected open val additionalObservedPackages: Set<String> = emptySet()

    protected open val additionalBrowserPackages: Set<String> = emptySet()

    protected open val additionalAccessibilityEventTypes: Int = 0

    private val observedBrowsers: Set<String>
        get() = SUPPORTED_BROWSERS + additionalBrowserPackages

    private val worker = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private lateinit var classifier: HybridClassifier
    protected lateinit var aggregateStore: DailyAggregateStore
    protected lateinit var stateStore: ProtectionStateStore
    protected lateinit var overlay: PatternInterruptOverlay
    private var phase4Evidence: Phase4EvidenceRecorder? = null
    private var lastSignature = 0
    private var lastDecisionAt = 0L
    private var pendingScan: Runnable? = null
    private var tabSwitcherSettleUntilElapsed = 0L
    private var nativeFallback: Runnable? = null
    private var interventionExpiry: Runnable? = null

    private data class QueuedBrowserNode(
        val node: AccessibilityNodeInfo,
        val insideWebContent: Boolean,
    )

    override fun onServiceConnected() {
        super.onServiceConnected()
        serviceInfo = serviceInfo.apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                AccessibilityEvent.TYPE_VIEW_CLICKED or
                additionalAccessibilityEventTypes
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 150
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS or
                // Samsung Internet can mark its page bridge as not important
                // even though it is the only accessible representation of the
                // committed page. Keep extraction local and filter browser
                // chrome below before any text reaches the classifier.
                AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                // Ask Chromium/Samsung browser bridges to expose their
                // enhanced web-accessibility representation when available.
                AccessibilityServiceInfo.FLAG_REQUEST_ENHANCED_WEB_ACCESSIBILITY
            packageNames = (observedBrowsers + additionalObservedPackages).toTypedArray()
        }
        classifier = HybridClassifier(applicationContext)
        aggregateStore = DailyAggregateStore(applicationContext)
        stateStore = ProtectionStateStore(applicationContext)
        stateStore.setRuntimeConnected(true)
        overlay = PatternInterruptOverlay(this, NativeConfig.webBaseUrl(this))
        runCatching { overlay.prepare() }
        runCatching { phase4Evidence = Phase4EvidenceRecorder(applicationContext) }
        activeService = this
        runCatching { HealthNotificationPreferences.show(this) }
        ProtectionKeepAliveService.start(this)
        ProtectionBridge.emit(this, snapshotEvent())
        onProtectionServiceConnected()
        restorePendingIntervention()
        worker.execute {
            val loaded = classifier.load()
            mainHandler.post {
                if (loaded) {
                    if (stateStore.status() != "degraded") {
                        stateStore.setStatus("active")
                    }
                } else {
                    stateStore.setStatus("degraded", "artifact_invalid")
                }
                ProtectionBridge.emit(this, snapshotEvent())
            }
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        val sourcePackage = event.packageName?.toString() ?: return
        if (sourcePackage in observedBrowsers) {
            if (isTabSwitcherTrigger(event)) {
                pendingScan?.let(mainHandler::removeCallbacks)
                tabSwitcherSettleUntilElapsed =
                    SystemClock.elapsedRealtime() + TAB_SWITCHER_SETTLE_WINDOW_MS
                return
            }
            if (!isNavigationLike(event)) return
            scheduleBrowserScan(event)
            return
        }
        handleAdditionalAccessibilityEvent(event, sourcePackage)
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

    protected open fun handleAdditionalAccessibilityEvent(
        event: AccessibilityEvent,
        sourcePackage: String,
    ) = Unit

    protected open fun onProtectionServiceConnected() = Unit

    protected open fun onProtectionServiceDestroyed() = Unit

    private fun isTabSwitcherTrigger(event: AccessibilityEvent): Boolean {
        if (event.eventType != AccessibilityEvent.TYPE_VIEW_CLICKED) return false
        val source = event.source ?: return false
        val sourceViewId = source.viewIdResourceName?.toString().orEmpty().lowercase()
        val sourceClassName = source.className?.toString().orEmpty().lowercase()
        return TAB_SWITCHER_CONTROL_RESOURCE_MARKERS.any { sourceViewId.contains(it) } ||
            (sourceClassName.contains("tab") && sourceClassName.contains("switch")) ||
            isTabSwitcherResourceId(sourceViewId) ||
            isTabSwitcherClassName(sourceClassName)
    }

    private fun scheduleBrowserScan(event: AccessibilityEvent) {
        if (stateStore.activeGrantAllowsProtectionPause()) {
            stateStore.setStatus("paused")
            ProtectionBridge.emit(this, snapshotEvent())
            return
        }
        pendingScan?.let(mainHandler::removeCallbacks)
        val scanStartedNanos = SystemClock.elapsedRealtimeNanos()
        val runnable = Runnable {
            if (SystemClock.elapsedRealtime() < tabSwitcherSettleUntilElapsed) return@Runnable
            val root = rootInActiveWindow ?: event.source
            if (isTabSwitcherEvent(event)) return@Runnable
            val input = extractSignals(event, root)
            // Transient intermediate frames during navigation are normal; ignore without degrading
            if (input == null) return@Runnable
            val inputReadyNanos = SystemClock.elapsedRealtimeNanos()

            worker.execute {
                val classificationStartedNanos = SystemClock.elapsedRealtimeNanos()
                val result = classifier.classify(input)
                val classificationFinishedNanos = SystemClock.elapsedRealtimeNanos()
                val signature = listOf(input.url, input.title, input.headings, input.anchorTexts).hashCode()
                val now = System.currentTimeMillis()
                if (signature == lastSignature && now - lastDecisionAt < 500 && result.decision != "block") {
                    return@execute
                }
                lastSignature = signature
                lastDecisionAt = now
                stateStore.setLastEventNow()
                if (result.decision == "block") {
                    val acquisition = stateStore.acquireIntervention(
                        reasonCode = result.reasonCode,
                        modelVersion = result.modelVersion,
                        rulesetVersion = result.rulesetVersion,
                    )
                    if (!acquisition.created) return@execute
                    phase4Evidence?.begin(
                        acquisition.intervention.id,
                        Phase4LatencyStart(
                            scanStartedNanos = scanStartedNanos,
                            inputReadyNanos = inputReadyNanos,
                            classificationStartedNanos = classificationStartedNanos,
                            classificationFinishedNanos = classificationFinishedNanos,
                            timings = result.timings,
                            modelVersion = result.modelVersion,
                            rulesetVersion = result.rulesetVersion,
                        ),
                    )
                    // Prioritize the accepted block and native overlay over
                    // follow-up browser accessibility scans. Those scans are
                    // best-effort and must not delay the protection boundary.
                    mainHandler.postAtFrontOfQueue {
                        executeBlockAndIntervention(acquisition.intervention)
                    }
                } else {
                    stateStore.setStatus("active")
                    ProtectionBridge.emit(this, snapshotEvent())
                }
            }
        }
        pendingScan = runnable
        // Accessibility already coalesces events for 150ms. Keep only a small
        // settle window so local protection does not add another 300ms.
        mainHandler.postDelayed(runnable, 50)
    }

    private fun isTabSwitcherEvent(event: AccessibilityEvent): Boolean {
        if (isTabSwitcherClassName(event.className?.toString().orEmpty())) return true
        val sourceViewId = event.source?.viewIdResourceName?.toString().orEmpty().lowercase()
        if (isTabSwitcherResourceId(sourceViewId) ||
            TAB_SWITCHER_CONTROL_RESOURCE_MARKERS.any { sourceViewId.contains(it) }
        ) {
            return true
        }
        return false
    }

    private fun extractSignals(
        event: AccessibilityEvent,
        root: AccessibilityNodeInfo?,
    ): ClassificationInput? {
        if (root == null) return null
        val samsungInternet = isSamsungInternetPackage(event.packageName?.toString().orEmpty())
        var url = ""
        for (resourceId in URL_RESOURCE_IDS) {
            val node = root.findAccessibilityNodeInfosByViewId(resourceId).firstOrNull()
            val value = normalizeAccessibilityText(node?.text?.toString().orEmpty())
            if (value.isNotEmpty()) {
                url = value
                break
            }
        }
        val headings = mutableListOf<String>()
        val anchors = mutableListOf<String>()
        val bodyTexts = mutableListOf<String>()
        var fallbackUrlCandidate = ""
        val queue = ArrayDeque<QueuedBrowserNode>()
        queue.add(
            QueuedBrowserNode(
                node = root,
                insideWebContent = isBrowserWebContentClassName(root.className?.toString().orEmpty()) ||
                    (samsungInternet && isSamsungInternetPageContentResourceId(
                        root.viewIdResourceName?.toString().orEmpty(),
                    )),
            ),
        )
        var pageTextCount = 0
        var visited = 0
        while (queue.isNotEmpty() && visited < 500) {
            val queued = queue.removeFirst()
            val node = queued.node
            visited++
            if (isTabSwitcherResourceId(node.viewIdResourceName?.toString().orEmpty()) ||
                isTabSwitcherClassName(node.className?.toString().orEmpty())
            ) {
                // Tab cards are stale browser chrome, not a committed page.
                // Return before collecting their text for local classification.
                return null
            }
            val viewId = node.viewIdResourceName?.lowercase().orEmpty()
            val samsungPageRoot = samsungInternet && isSamsungInternetPageContentResourceId(viewId)
            val samsungBrowserChrome = samsungInternet &&
                !samsungPageRoot &&
                isSamsungInternetChromeResourceId(viewId)
            val rawText = normalizeAccessibilityText(
                node.text?.toString() ?: node.contentDescription?.toString().orEmpty(),
            )
            val text = rawText.take(256)
            val insideWebContent = queued.insideWebContent ||
                isBrowserWebContentClassName(node.className?.toString().orEmpty()) ||
                samsungPageRoot

            if (viewId.contains("url") || viewId.contains("location") || viewId.contains("search_box") || viewId.contains("address")) {
                if (rawText.isNotEmpty() && isBetterUrlCandidate(rawText, fallbackUrlCandidate)) {
                    fallbackUrlCandidate = rawText
                }
            } else if (rawText.isNotEmpty() && looksLikeUrl(rawText) && isBetterUrlCandidate(rawText, fallbackUrlCandidate)) {
                fallbackUrlCandidate = rawText
            }

            if (insideWebContent && !samsungBrowserChrome && text.isNotEmpty()) {
                pageTextCount++
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
                node.getChild(index)?.let {
                    queue.add(
                        QueuedBrowserNode(
                            it,
                            insideWebContent && !samsungBrowserChrome,
                        ),
                    )
                }
            }
        }

        val resolvedUrl = when {
            url.isNotEmpty() -> url
            looksLikeUrl(fallbackUrlCandidate) -> fallbackUrlCandidate
            fallbackUrlCandidate.isNotEmpty() -> fallbackUrlCandidate
            else -> ""
        }

        val title = sequenceOf(
            event.contentDescription?.toString(),
            event.text.firstOrNull()?.toString(),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) root.paneTitle?.toString() else null,
            headings.firstOrNull(),
        ).map { normalizeAccessibilityText(it.orEmpty()) }
            .firstOrNull { it.isNotEmpty() && !looksLikeUrl(it) }
            .orEmpty()
            .take(512)

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
            hasDomContent = pageTextCount > 0,
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
            "supports_controlled_removal" to BuildConfig.SUPPORTS_CONTROLLED_REMOVAL,
            "device_admin_active" to deviceAdminActive(),
            "degraded_reason_code" to stateStore.degradedReason(),
            "last_event_at" to stateStore.lastEventAt(),
        )
    }

    /**
     * Research exposes Device Admin as the OS-supported uninstall guard. Keep
     * this helper in the shared service so the Research-only subclass can
     * re-check the guard without adding any removal behavior to the Play
     * flavor.
     */
    protected fun isDeviceAdminActiveForResearch(): Boolean {
        if (!BuildConfig.SUPPORTS_CONTROLLED_REMOVAL) return false
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
        return runCatching {
            dpm.isAdminActive(
                android.content.ComponentName(packageName, "com.gamblock.gamblock_ai_apps.ProtectionDeviceAdminReceiver"),
            )
        }.getOrDefault(false)
    }

    private fun deviceAdminActive(): Boolean = isDeviceAdminActiveForResearch()

    override fun onInterrupt() = Unit

    /** Bridge surface for [ProtectionBridgeProvider] (same protection process). */
    fun snapshotMap(): Map<String, Any?> = snapshotEvent()

    /** Bridge surface for [ProtectionBridgeProvider] (same protection process). */
    fun claimFlutterVisibility(interventionId: String): InterventionVisibilityClaim {
        val claim = stateStore.claimFlutterVisibility(interventionId)
        if (claim.newlyVisible) {
            phase4Evidence?.complete(
                interventionId,
                SystemClock.elapsedRealtimeNanos(),
                "flutter_fallback",
            )
        }
        return claim
    }

    /** Bridge surface for [ProtectionBridgeProvider] (same protection process). */
    fun completeIntervention(interventionId: String): Boolean {
        return stateStore.completeIntervention(interventionId)
    }

    private fun executeBlockAndIntervention(intervention: PendingIntervention) {
        val blockActionStartedNanos = SystemClock.elapsedRealtimeNanos()
        val backAccepted = performGlobalAction(GLOBAL_ACTION_BACK)
        val navigationAccepted = if (backAccepted) {
            stateStore.setStatus("active")
            true
        } else {
            val homeAccepted = performGlobalAction(GLOBAL_ACTION_HOME)
            stateStore.setStatus(
                "degraded",
                if (homeAccepted) "browser_back_failed" else "browser_block_action_failed",
            )
            ProtectionBridge.emit(this, snapshotEvent())
            homeAccepted
        }
        phase4Evidence?.recordBlockAction(
            intervention.id,
            blockActionStartedNanos,
            SystemClock.elapsedRealtimeNanos(),
            navigationAccepted,
        )
        if (navigationAccepted) {
            // Count only after Android accepts the blocking navigation action.
            aggregateStore.increment("block_count_sync")
        }

        // This process already owns the Accessibility window token. Showing the
        // native overlay first avoids waiting for a cold Flutter engine.
        showNativeIntervention(intervention.id)
        scheduleInterventionExpiry(intervention)
    }

    private fun restorePendingIntervention() {
        val stored = stateStore.activeIntervention() ?: return
        val pending = if (
            stored.owner == "flutter_visible" &&
            !ProtectionBridge.uiRegistered
        ) {
            stateStore.releaseFlutterOwnershipForReplay(stored.id) ?: stored
        } else {
            stored
        }
        ProtectionBridge.emit(this, pending.event())
        when (pending.owner) {
            "native_pending", "native_visible" -> {
                showNativeIntervention(pending.id)
                scheduleInterventionExpiry(pending)
            }
            "flutter_visible" -> scheduleInterventionExpiry(pending)
            else -> {
                runCatching {
                    startActivity(
                        Intent(this, MainActivity::class.java).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        },
                    )
                }
                scheduleNativeFallback(pending)
                scheduleInterventionExpiry(pending)
            }
        }
    }

    private fun scheduleNativeFallback(intervention: PendingIntervention) {
        nativeFallback?.let(mainHandler::removeCallbacks)
        val runnable = Runnable {
            nativeFallback = null
            val active = stateStore.activeIntervention()
            if (active?.id == intervention.id && active.owner == "none") {
                showNativeIntervention(intervention.id)
            }
        }
        nativeFallback = runnable
        val delay = (intervention.ackDeadlineWallMs - System.currentTimeMillis()).coerceAtLeast(0L)
        mainHandler.postDelayed(runnable, delay)
    }

    private fun scheduleInterventionExpiry(intervention: PendingIntervention) {
        interventionExpiry?.let(mainHandler::removeCallbacks)
        val runnable = Runnable {
            interventionExpiry = null
            stateStore.expireIntervention(intervention.id)
            phase4Evidence?.fail(intervention.id, "expired")
            nativeFallback?.let(mainHandler::removeCallbacks)
            nativeFallback = null
            overlay.dismissIntervention(intervention.id)
        }
        interventionExpiry = runnable
        val delay = (intervention.expiresWallMs - System.currentTimeMillis()).coerceAtLeast(0L) + 1L
        mainHandler.postDelayed(runnable, delay)
    }

    private fun showNativeIntervention(interventionId: String) {
        if (!stateStore.claimNativeOwnership(interventionId)) return
        try {
            overlay.showIntervention(
                interventionId = interventionId,
                onCommitted = { firstFrameNanos ->
                    if (stateStore.markNativeVisible(interventionId)) {
                        aggregateStore.increment("intervention_shown")
                        phase4Evidence?.complete(
                            interventionId,
                            firstFrameNanos,
                            "native",
                        )
                    }
                },
                onCompleted = {
                    stateStore.completeIntervention(interventionId)
                    onExternalInterventionCompleted(interventionId)
                },
            )
        } catch (_: Exception) {
            overlay.dismissIntervention(interventionId)
            stateStore.releaseUncommittedNativeOwnership(interventionId)
            val pending = stateStore.activeIntervention()
            if (pending != null) {
                ProtectionBridge.emit(this, pending.event())
                val flutterLaunchAccepted = runCatching {
                    startActivity(
                        Intent(this, MainActivity::class.java).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        },
                    )
                }.isSuccess
                if (flutterLaunchAccepted) scheduleNativeFallback(pending)
            }
            stateStore.setStatus("degraded", "intervention_overlay_failed")
            ProtectionBridge.emit(this, snapshotEvent())
        }
    }

    private fun cancelNativeFallback(interventionId: String) {
        if (stateStore.activeIntervention()?.id != interventionId) return
        nativeFallback?.let(mainHandler::removeCallbacks)
        nativeFallback = null
    }

    private fun onExternalInterventionCompleted(interventionId: String) {
        nativeFallback?.let(mainHandler::removeCallbacks)
        nativeFallback = null
        interventionExpiry?.let(mainHandler::removeCallbacks)
        interventionExpiry = null
        overlay.dismissIntervention(interventionId)
    }

    private fun onFlutterPresentationLost(interventionId: String) {
        val pending = stateStore.activeIntervention()
        if (pending?.id != interventionId || pending.owner != "none") return
        ProtectionBridge.emit(this, pending.event())
        scheduleNativeFallback(pending)
        scheduleInterventionExpiry(pending)
    }

    override fun onDestroy() {
        onProtectionServiceDestroyed()
        pendingScan?.let(mainHandler::removeCallbacks)
        mainHandler.removeCallbacksAndMessages(null)
        overlay.destroy()
        if (activeService === this) {
            activeService = null
        }
        stateStore.setRuntimeConnected(false)
        worker.shutdownNow()
        if (isAccessibilityComponentDisabled()) {
            aggregateStore.increment("permission_revoked")
            ProtectionKeepAliveService.stop(this)
        }
        stateStore.setStatus("inactive", "accessibility_disabled")
        ProtectionBridge.emit(this, snapshotEvent())
        super.onDestroy()
    }

    /**
     * Only a real disable (Settings toggle, force-stop semantics) removes the
     * component from the enabled list. Process restarts and task removals must
     * not be counted as permission revocation.
     */
    private fun isAccessibilityComponentDisabled(): Boolean {
        val manager = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        return manager.getEnabledAccessibilityServiceList(
            AccessibilityServiceInfo.FEEDBACK_ALL_MASK,
        ).none {
            it.resolveInfo.serviceInfo.packageName == packageName &&
                it.resolveInfo.serviceInfo.name == javaClass.name
        }
    }
}
