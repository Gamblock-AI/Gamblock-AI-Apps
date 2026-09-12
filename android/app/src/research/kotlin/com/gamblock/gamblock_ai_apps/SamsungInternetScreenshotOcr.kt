package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityService
import android.graphics.Bitmap
import android.graphics.Rect
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.view.Display
import android.view.accessibility.AccessibilityNodeInfo
import androidx.core.content.ContextCompat
import com.google.mlkit.common.MlKit
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import java.util.ArrayDeque

internal data class SamsungOcrBounds(
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int,
) {
    val width: Int get() = right - left
    val height: Int get() = bottom - top
    val area: Long get() = width.toLong() * height.toLong()

    fun intersect(frameWidth: Int, frameHeight: Int): SamsungOcrBounds? {
        val clipped = SamsungOcrBounds(
            left = left.coerceIn(0, frameWidth),
            top = top.coerceIn(0, frameHeight),
            right = right.coerceIn(0, frameWidth),
            bottom = bottom.coerceIn(0, frameHeight),
        )
        return clipped.takeIf { it.width > 0 && it.height > 0 }
    }
}

internal data class SamsungOcrPageState(
    val isSamsungPackage: Boolean,
    val hasCommittedPageSurface: Boolean,
    val isEditingBrowserChrome: Boolean,
    val isTabSwitcher: Boolean,
    val pageBounds: List<SamsungOcrBounds> = emptyList(),
    val toolbarBottoms: List<Int> = emptyList(),
    val bottomBarTops: List<Int> = emptyList(),
) {
    val isEligible: Boolean
        get() = isSamsungPackage &&
            hasCommittedPageSurface &&
            !isEditingBrowserChrome &&
            !isTabSwitcher
}

internal object SamsungOcrCropBoundsResolver {
    private const val MIN_PAGE_DIMENSION_PX = 32
    private const val FALLBACK_TOP_RATIO = 0.088f
    private const val FALLBACK_BOTTOM_RATIO = 0.942f

    fun resolve(
        state: SamsungOcrPageState,
        frameWidth: Int,
        frameHeight: Int,
    ): SamsungOcrBounds? {
        if (frameWidth < MIN_PAGE_DIMENSION_PX || frameHeight < MIN_PAGE_DIMENSION_PX) {
            return null
        }

        val toolbarBottom = state.toolbarBottoms
            .filter { it in 1 until frameHeight }
            .maxOrNull()
        val bottomBarTop = state.bottomBarTops
            .filter { it in 1..frameHeight }
            .minOrNull()

        val pageBounds = state.pageBounds
            .mapNotNull { it.intersect(frameWidth, frameHeight) }
            .map { bounds ->
                SamsungOcrBounds(
                    left = bounds.left,
                    top = toolbarBottom?.let { maxOf(bounds.top, it) } ?: bounds.top,
                    right = bounds.right,
                    bottom = bottomBarTop?.let { minOf(bounds.bottom, it) } ?: bounds.bottom,
                )
            }
            .filter { isLargeEnough(it, frameWidth, frameHeight) }
            .filterNot { it.covers(frameWidth, frameHeight) }
            .maxByOrNull(SamsungOcrBounds::area)
        if (pageBounds != null) return pageBounds

        val fallback = fallbackBounds(frameWidth, frameHeight) ?: return null
        val chromeBounds = SamsungOcrBounds(
            left = 0,
            top = toolbarBottom ?: fallback.top,
            right = frameWidth,
            bottom = bottomBarTop ?: fallback.bottom,
        )
        return chromeBounds.takeIf { isLargeEnough(it, frameWidth, frameHeight) } ?: fallback
    }

    private fun fallbackBounds(frameWidth: Int, frameHeight: Int): SamsungOcrBounds? {
        val bounds = SamsungOcrBounds(
            left = 0,
            top = (frameHeight * FALLBACK_TOP_RATIO).toInt().coerceIn(0, frameHeight),
            right = frameWidth,
            bottom = (frameHeight * FALLBACK_BOTTOM_RATIO).toInt().coerceIn(0, frameHeight),
        )
        return bounds.takeIf { isLargeEnough(it, frameWidth, frameHeight) }
    }

    private fun isLargeEnough(
        bounds: SamsungOcrBounds,
        frameWidth: Int,
        frameHeight: Int,
    ): Boolean {
        val minimumWidth = maxOf(MIN_PAGE_DIMENSION_PX, frameWidth / 4)
        val minimumHeight = maxOf(MIN_PAGE_DIMENSION_PX, frameHeight / 5)
        return bounds.width >= minimumWidth && bounds.height >= minimumHeight
    }

    private fun SamsungOcrBounds.covers(frameWidth: Int, frameHeight: Int): Boolean {
        return left == 0 && top == 0 && right == frameWidth && bottom == frameHeight
    }
}

internal data class SamsungOcrRequestTicket<T>(
    internal val id: Long,
    internal val generation: Long,
    val value: T,
)

internal data class SamsungOcrRequestCompletion<T>(
    val shouldDeliver: Boolean,
    val next: SamsungOcrRequestTicket<T>?,
)

/** Keeps one active request and coalesces bursts without starving useful OCR. */
internal class SamsungOcrLatestRequestCoordinator<T>(
    private val representsSamePage: (T, T) -> Boolean = { left, right -> left == right },
) {
    private var sequence = 0L
    private var generation = 0L
    private var active: SamsungOcrRequestTicket<T>? = null
    private var pending: SamsungOcrRequestTicket<T>? = null
    private var closed = false

    @Synchronized
    fun submit(value: T): SamsungOcrRequestTicket<T>? {
        if (closed) return null
        val ticket = SamsungOcrRequestTicket(++sequence, generation, value)
        if (active == null) {
            active = ticket
            return ticket
        }
        pending = ticket
        return null
    }

    @Synchronized
    fun invalidate() {
        if (closed) return
        generation++
        pending = null
    }

    @Synchronized
    fun isCurrent(ticket: SamsungOcrRequestTicket<T>): Boolean {
        if (closed || active?.id != ticket.id || ticket.generation != generation) {
            return false
        }
        val queued = pending ?: return true
        return queued.generation != generation || representsSamePage(ticket.value, queued.value)
    }

    @Synchronized
    fun complete(
        ticket: SamsungOcrRequestTicket<T>,
        coalesceSamePagePending: Boolean = false,
    ): SamsungOcrRequestCompletion<T> {
        if (active?.id != ticket.id) {
            return SamsungOcrRequestCompletion(shouldDeliver = false, next = null)
        }
        active = null
        val valid = !closed && ticket.generation == generation
        val queued = if (closed) null else pending
        val coalesceQueued = valid &&
            coalesceSamePagePending &&
            queued != null &&
            queued.generation == generation &&
            representsSamePage(ticket.value, queued.value)
        val shouldDeliver = valid && (queued == null || coalesceQueued)
        val next = if (coalesceQueued) null else queued
        pending = null
        active = next
        return SamsungOcrRequestCompletion(shouldDeliver, next)
    }

    @Synchronized
    fun close() {
        closed = true
        active = null
        pending = null
    }
}

internal class SamsungOcrScreenshotThrottle(
    private val minimumIntervalMs: Long,
) {
    private var lastRequestAtElapsedMs: Long? = null

    fun delayBeforeRequest(nowElapsedMs: Long): Long {
        val lastRequestAt = lastRequestAtElapsedMs ?: return 0L
        return (minimumIntervalMs - (nowElapsedMs - lastRequestAt)).coerceAtLeast(0L)
    }

    fun markRequested(nowElapsedMs: Long) {
        lastRequestAtElapsedMs = nowElapsedMs
    }
}

internal object SamsungOcrScreenshotRetryPolicy {
    private const val LEGACY_INTERVAL_RETRY_DELAY_MS = 1_000L
    private const val MAX_INTERVAL_RETRIES = 1

    fun retryDelayMs(errorCode: Int, intervalRetryCount: Int): Long? {
        return LEGACY_INTERVAL_RETRY_DELAY_MS.takeIf {
            errorCode == AccessibilityService.ERROR_TAKE_SCREENSHOT_INTERVAL_TIME_SHORT &&
                intervalRetryCount < MAX_INTERVAL_RETRIES
        }
    }
}

/**
 * Research-only Samsung fallback for browser versions that expose pixels but
 * no renderer nodes through Accessibility. The bitmap and OCR result remain
 * transient in this process and are never persisted or sent to the backend.
 */
internal class SamsungInternetScreenshotOcr private constructor(
    private val service: AccessibilityService,
    private val recognizer: TextRecognizer,
) {
    companion object {
        private const val TAG = "GamblockSamsungOcr"
        private const val MAX_ACCESSIBILITY_NODES = 500
        private const val MIN_SCREENSHOT_INTERVAL_MS = 350L
        private val ADDRESS_BAR_RESOURCE_MARKERS = listOf(
            ":id/location_bar",
            ":id/url_bar",
            ":id/search_box",
            ":id/toolbar_url",
            ":id/address",
        )
        private val BOTTOM_BAR_RESOURCE_MARKERS = listOf(
            ":id/bottombar",
            ":id/bottom_bar",
        )
        private var mlKitReadyInProcess = false

        /**
         * The Accessibility Service runs in :protection, where the default
         * process provider does not initialize ML Kit. Initialize once per
         * protection process, then create a fresh recognizer for each service
         * instance. Recognizer creation remains the final capability check.
         */
        @Synchronized
        fun createOrNull(service: AccessibilityService): SamsungInternetScreenshotOcr? {
            var initializationFailure: RuntimeException? = null
            if (!mlKitReadyInProcess) {
                try {
                    MlKit.initialize(service.applicationContext)
                    mlKitReadyInProcess = true
                    Log.d(TAG, "ML Kit initialized in protection process")
                } catch (error: RuntimeException) {
                    initializationFailure = error
                }
            }

            return try {
                val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
                if (!mlKitReadyInProcess) {
                    // Another component may have initialized the process first.
                    // A usable recognizer is the authoritative capability check.
                    mlKitReadyInProcess = true
                    Log.d(TAG, "ML Kit was already available in protection process")
                }
                SamsungInternetScreenshotOcr(service, recognizer)
            } catch (error: RuntimeException) {
                initializationFailure?.let {
                    Log.w(TAG, "ML Kit initialization failed: ${it.javaClass.simpleName}")
                }
                Log.w(TAG, "Samsung Internet recognizer unavailable: ${error.javaClass.simpleName}")
                null
            }
        }

        fun capturePageState(
            root: AccessibilityNodeInfo?,
            expectedPackageName: String,
            clickedNode: AccessibilityNodeInfo? = null,
        ): SamsungOcrPageState {
            if (root == null) {
                return SamsungOcrPageState(
                    isSamsungPackage = false,
                    hasCommittedPageSurface = false,
                    isEditingBrowserChrome = false,
                    isTabSwitcher = false,
                )
            }

            val rootPackage = root.packageName?.toString().orEmpty()
            val packageMatches =
                BrowserProtectionAccessibilityService.isSamsungInternetPackage(expectedPackageName) &&
                    (rootPackage.isBlank() ||
                        BrowserProtectionAccessibilityService.isSamsungInternetPackage(rootPackage))
            var hasCommittedPageSurface = false
            var isEditingBrowserChrome = clickedNode?.let(::isAddressBarNode) == true
            var isTabSwitcher = false
            val pageBounds = mutableListOf<SamsungOcrBounds>()
            val toolbarBottoms = mutableListOf<Int>()
            val bottomBarTops = mutableListOf<Int>()
            val queue = ArrayDeque<AccessibilityNodeInfo>()
            queue.add(root)
            var visited = 0
            while (queue.isNotEmpty() && visited < MAX_ACCESSIBILITY_NODES) {
                val node = queue.removeFirst()
                visited++
                val viewId = node.viewIdResourceName?.toString()?.lowercase().orEmpty()
                val className = node.className?.toString().orEmpty()
                val nodeBounds = Rect()
                node.getBoundsInScreen(nodeBounds)
                val immutableBounds = SamsungOcrBounds(
                    nodeBounds.left,
                    nodeBounds.top,
                    nodeBounds.right,
                    nodeBounds.bottom,
                )

                val isPageSurface =
                    BrowserProtectionAccessibilityService.isSamsungInternetPageContentResourceId(viewId) ||
                        BrowserProtectionAccessibilityService.isBrowserWebContentClassName(className)
                if (isPageSurface) {
                    hasCommittedPageSurface = true
                    if (immutableBounds.width > 0 && immutableBounds.height > 0) {
                        pageBounds.add(immutableBounds)
                    }
                }
                if (BrowserProtectionAccessibilityService.isTabSwitcherResourceId(viewId) ||
                    BrowserProtectionAccessibilityService.isTabSwitcherClassName(className)
                ) {
                    isTabSwitcher = true
                }
                if (isAddressBarNode(node) && node.isFocused) {
                    isEditingBrowserChrome = true
                }
                if (viewId.contains(":id/toolbar") && nodeBounds.bottom > nodeBounds.top) {
                    toolbarBottoms.add(nodeBounds.bottom)
                }
                if (BOTTOM_BAR_RESOURCE_MARKERS.any(viewId::contains) &&
                    nodeBounds.bottom > nodeBounds.top
                ) {
                    bottomBarTops.add(nodeBounds.top)
                }

                for (index in 0 until node.childCount) {
                    node.getChild(index)?.let(queue::add)
                }
            }

            return SamsungOcrPageState(
                isSamsungPackage = packageMatches,
                hasCommittedPageSurface = hasCommittedPageSurface,
                isEditingBrowserChrome = isEditingBrowserChrome,
                isTabSwitcher = isTabSwitcher,
                pageBounds = pageBounds,
                toolbarBottoms = toolbarBottoms,
                bottomBarTops = bottomBarTops,
            )
        }

        private fun isAddressBarNode(node: AccessibilityNodeInfo): Boolean {
            val viewId = node.viewIdResourceName?.toString()?.lowercase().orEmpty()
            return ADDRESS_BAR_RESOURCE_MARKERS.any(viewId::contains)
        }
    }

    private data class Request(
        val pageState: SamsungOcrPageState,
        val input: ClassificationInput,
        val onReady: (ClassificationInput) -> Unit,
        var intervalRetryCount: Int = 0,
    )

    private val requests = SamsungOcrLatestRequestCoordinator<Request>(::representsSamePage)
    private val screenshotThrottle = SamsungOcrScreenshotThrottle(MIN_SCREENSHOT_INTERVAL_MS)
    private val mainHandler = Handler(Looper.getMainLooper())
    private val mainExecutor = ContextCompat.getMainExecutor(service)
    private val scheduledStarts = mutableMapOf<Long, Runnable>()

    fun request(
        pageState: SamsungOcrPageState,
        input: ClassificationInput,
        onReady: (ClassificationInput) -> Unit,
    ) {
        if (!pageState.isEligible) {
            invalidate()
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            safelyDeliver(input, onReady)
            return
        }

        val ticket = requests.submit(Request(pageState, input, onReady))
        if (ticket == null) {
            Log.d(TAG, "newest Samsung screenshot request queued")
            return
        }
        start(ticket)
    }

    fun invalidate() {
        requests.invalidate()
    }

    fun close() {
        requests.close()
        scheduledStarts.values.forEach(mainHandler::removeCallbacks)
        scheduledStarts.clear()
        try {
            recognizer.close()
        } catch (error: RuntimeException) {
            Log.w(TAG, "recognizer close failed: ${error.javaClass.simpleName}")
        }
    }

    private fun start(
        ticket: SamsungOcrRequestTicket<Request>,
        minimumDelayMs: Long = 0L,
    ) {
        if (!requests.isCurrent(ticket) || !currentPageIsEligible()) {
            finish(ticket, null)
            return
        }
        val nowElapsedMs = SystemClock.elapsedRealtime()
        val delayMs = maxOf(
            minimumDelayMs,
            screenshotThrottle.delayBeforeRequest(nowElapsedMs),
        )
        if (delayMs > 0L) {
            scheduleStart(ticket, delayMs)
            return
        }
        try {
            screenshotThrottle.markRequested(nowElapsedMs)
            Log.d(TAG, "requesting Samsung screenshot")
            service.takeScreenshot(
                Display.DEFAULT_DISPLAY,
                mainExecutor,
                object : AccessibilityService.TakeScreenshotCallback {
                    override fun onSuccess(result: AccessibilityService.ScreenshotResult) {
                        handleScreenshot(ticket, result)
                    }

                    override fun onFailure(errorCode: Int) {
                        Log.w(TAG, "screenshot failed code=$errorCode")
                        val retryDelayMs = SamsungOcrScreenshotRetryPolicy.retryDelayMs(
                            errorCode,
                            ticket.value.intervalRetryCount,
                        )
                        if (retryDelayMs != null && requests.isCurrent(ticket)) {
                            ticket.value.intervalRetryCount++
                            Log.d(TAG, "screenshot interval retry scheduled")
                            start(ticket, retryDelayMs)
                        } else {
                            finish(
                                ticket,
                                ticket.value.input.takeIf { requests.isCurrent(ticket) },
                            )
                        }
                    }
                },
            )
        } catch (error: RuntimeException) {
            Log.w(TAG, "screenshot request threw ${error.javaClass.simpleName}")
            finish(ticket, ticket.value.input)
        }
    }

    private fun handleScreenshot(
        ticket: SamsungOcrRequestTicket<Request>,
        result: AccessibilityService.ScreenshotResult,
    ) {
        if (!requests.isCurrent(ticket) || !currentPageIsEligible()) {
            closeHardwareBuffer(result)
            finish(ticket, null)
            return
        }

        val bitmap = try {
            screenshotBitmap(result, ticket.value.pageState)
        } catch (error: RuntimeException) {
            Log.w(TAG, "screenshot conversion failed: ${error.javaClass.simpleName}")
            finish(ticket, ticket.value.input)
            return
        }
        if (bitmap == null) {
            Log.w(TAG, "screenshot returned no safe page bitmap")
            finish(ticket, ticket.value.input)
            return
        }
        Log.d(TAG, "screenshot captured")

        try {
            val image = InputImage.fromBitmap(bitmap, 0)
            recognizer.process(image).addOnCompleteListener(mainExecutor) { task ->
                val output = try {
                    if (task.isSuccessful) {
                        val enriched = enrich(ticket.value.input, task.result?.text.orEmpty())
                        Log.d(
                            TAG,
                            "ocr complete lines=${enriched.anchorTexts.size - ticket.value.input.anchorTexts.size}",
                        )
                        enriched
                    } else {
                        Log.w(
                            TAG,
                            "ocr failed: ${task.exception?.javaClass?.simpleName ?: "unknown"}",
                        )
                        ticket.value.input
                    }
                } catch (error: RuntimeException) {
                    Log.w(TAG, "ocr callback failed: ${error.javaClass.simpleName}")
                    ticket.value.input
                } finally {
                    recycleSafely(bitmap)
                }
                finish(ticket, output)
            }
        } catch (error: RuntimeException) {
            recycleSafely(bitmap)
            Log.w(TAG, "ocr request threw ${error.javaClass.simpleName}")
            finish(ticket, ticket.value.input)
        }
    }

    private fun finish(
        ticket: SamsungOcrRequestTicket<Request>,
        output: ClassificationInput?,
    ) {
        scheduledStarts.remove(ticket.id)?.let(mainHandler::removeCallbacks)
        val currentPageEligible = output != null && currentPageIsEligible()
        val completion = requests.complete(
            ticket,
            coalesceSamePagePending = currentPageEligible && output?.hasDomContent == true,
        )
        if (completion.shouldDeliver && currentPageEligible) {
            Log.d(TAG, "OCR result delivered to classifier")
            safelyDeliver(output, ticket.value.onReady)
        }
        completion.next?.let(::start)
    }

    private fun scheduleStart(ticket: SamsungOcrRequestTicket<Request>, delayMs: Long) {
        scheduledStarts.remove(ticket.id)?.let(mainHandler::removeCallbacks)
        val runnable = Runnable {
            scheduledStarts.remove(ticket.id)
            start(ticket)
        }
        scheduledStarts[ticket.id] = runnable
        Log.d(TAG, "Samsung screenshot delayed for interval safety")
        mainHandler.postDelayed(runnable, delayMs)
    }

    private fun representsSamePage(left: Request, right: Request): Boolean {
        val leftUrl = BrowserProtectionAccessibilityService.normalizeAccessibilityText(left.input.url)
        val rightUrl = BrowserProtectionAccessibilityService.normalizeAccessibilityText(right.input.url)
        if (leftUrl.isNotEmpty() || rightUrl.isNotEmpty()) {
            return leftUrl.isNotEmpty() && rightUrl.isNotEmpty() && leftUrl == rightUrl
        }
        val leftTitle = BrowserProtectionAccessibilityService.normalizeAccessibilityText(left.input.title)
        val rightTitle = BrowserProtectionAccessibilityService.normalizeAccessibilityText(right.input.title)
        return leftTitle.isNotEmpty() && rightTitle.isNotEmpty() &&
            leftTitle.equals(rightTitle, ignoreCase = true)
    }

    private fun safelyDeliver(
        input: ClassificationInput,
        onReady: (ClassificationInput) -> Unit,
    ) {
        try {
            onReady(input)
        } catch (error: RuntimeException) {
            Log.w(TAG, "OCR handoff failed: ${error.javaClass.simpleName}")
        }
    }

    private fun currentPageIsEligible(): Boolean {
        return try {
            val root = service.rootInActiveWindow ?: return false
            val packageName = root.packageName?.toString().orEmpty()
            capturePageState(root, packageName).isEligible
        } catch (error: RuntimeException) {
            Log.w(TAG, "current Samsung page unavailable: ${error.javaClass.simpleName}")
            false
        }
    }

    private fun enrich(input: ClassificationInput, recognizedText: String): ClassificationInput {
        val lines = recognizedText
            .lines()
            .map { BrowserProtectionAccessibilityService.normalizeAccessibilityText(it) }
            .filter { it.isNotEmpty() && !BrowserProtectionAccessibilityService.looksLikeUrl(it) }
            .distinct()
            .take(64)
        if (lines.isEmpty()) return input
        return input.copy(
            anchorTexts = (input.anchorTexts + lines).take(64),
            // OCR is committed page content, even though Samsung did not
            // expose the DOM node tree. This enables the existing local
            // text-only model gate without weakening URL-only protection.
            hasDomContent = true,
        )
    }

    private fun screenshotBitmap(
        result: AccessibilityService.ScreenshotResult,
        pageState: SamsungOcrPageState,
    ): Bitmap? {
        val hardwareBuffer = result.hardwareBuffer
        var softwareBitmap: Bitmap? = null
        return try {
            val hardwareBitmap = Bitmap.wrapHardwareBuffer(
                hardwareBuffer,
                result.colorSpace,
            ) ?: return null
            val copiedBitmap = try {
                hardwareBitmap.copy(Bitmap.Config.ARGB_8888, false)
            } finally {
                recycleSafely(hardwareBitmap)
            } ?: return null
            softwareBitmap = copiedBitmap
            val pageBitmap = cropToPage(copiedBitmap, pageState)
            softwareBitmap = null
            pageBitmap
        } catch (error: RuntimeException) {
            softwareBitmap?.let(::recycleSafely)
            throw error
        } finally {
            try {
                hardwareBuffer.close()
            } catch (error: RuntimeException) {
                Log.w(TAG, "hardware buffer cleanup failed: ${error.javaClass.simpleName}")
            }
        }
    }

    private fun cropToPage(
        bitmap: Bitmap,
        pageState: SamsungOcrPageState,
    ): Bitmap? {
        val bounds = SamsungOcrCropBoundsResolver.resolve(
            pageState,
            bitmap.width,
            bitmap.height,
        ) ?: run {
            recycleSafely(bitmap)
            return null
        }
        val cropped = Bitmap.createBitmap(
            bitmap,
            bounds.left,
            bounds.top,
            bounds.width,
            bounds.height,
        )
        if (cropped !== bitmap) recycleSafely(bitmap)
        return cropped
    }

    private fun closeHardwareBuffer(result: AccessibilityService.ScreenshotResult) {
        try {
            result.hardwareBuffer.close()
        } catch (error: RuntimeException) {
            Log.w(TAG, "stale screenshot cleanup failed: ${error.javaClass.simpleName}")
        }
    }

    private fun recycleSafely(bitmap: Bitmap) {
        if (bitmap.isRecycled) return
        try {
            bitmap.recycle()
        } catch (error: RuntimeException) {
            Log.w(TAG, "bitmap cleanup failed: ${error.javaClass.simpleName}")
        }
    }
}
