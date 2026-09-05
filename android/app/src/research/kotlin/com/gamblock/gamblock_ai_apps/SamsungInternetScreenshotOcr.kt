package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityService
import android.graphics.Bitmap
import android.graphics.Rect
import android.os.Build
import android.view.Display
import android.view.accessibility.AccessibilityNodeInfo
import androidx.core.content.ContextCompat
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import java.util.ArrayDeque
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Research-only Samsung fallback for browser versions that expose pixels but
 * no renderer nodes through Accessibility. The bitmap and OCR result remain
 * transient in this process and are never persisted or sent to the backend.
 */
class SamsungInternetScreenshotOcr(
    private val service: AccessibilityService,
) {
    private val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
    private val inFlight = AtomicBoolean(false)

    fun request(
        root: AccessibilityNodeInfo?,
        input: ClassificationInput,
        onReady: (ClassificationInput) -> Unit,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R ||
            !inFlight.compareAndSet(false, true)
        ) {
            onReady(input)
            return
        }

        try {
            service.takeScreenshot(
                Display.DEFAULT_DISPLAY,
                ContextCompat.getMainExecutor(service),
                object : AccessibilityService.TakeScreenshotCallback {
                    override fun onSuccess(result: AccessibilityService.ScreenshotResult) {
                        val bitmap = screenshotBitmap(result, root)
                        if (bitmap == null) {
                            complete(input, onReady)
                            return
                        }
                        recognizer.process(InputImage.fromBitmap(bitmap, 0))
                            .addOnSuccessListener { text ->
                                val enriched = enrich(input, text.text)
                                bitmap.recycle()
                                complete(enriched, onReady)
                            }
                            .addOnFailureListener {
                                bitmap.recycle()
                                complete(input, onReady)
                            }
                    }

                    override fun onFailure(errorCode: Int) {
                        complete(input, onReady)
                    }
                },
            )
        } catch (_: RuntimeException) {
            complete(input, onReady)
        }
    }

    fun close() {
        recognizer.close()
    }

    private fun complete(
        input: ClassificationInput,
        onReady: (ClassificationInput) -> Unit,
    ) {
        inFlight.set(false)
        onReady(input)
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
        root: AccessibilityNodeInfo?,
    ): Bitmap? {
        val hardwareBuffer = result.hardwareBuffer
        return try {
            val hardwareBitmap = Bitmap.wrapHardwareBuffer(
                hardwareBuffer,
                result.colorSpace,
            ) ?: return null
            val bitmap = hardwareBitmap.copy(Bitmap.Config.ARGB_8888, false)
            hardwareBitmap.recycle()
            bitmap?.let { cropToPage(it, root) }
        } finally {
            hardwareBuffer.close()
        }
    }

    private fun cropToPage(bitmap: Bitmap, root: AccessibilityNodeInfo?): Bitmap {
        val bounds = pageBounds(root, bitmap.width, bitmap.height)
        if (bounds.left == 0 && bounds.top == 0 &&
            bounds.right == bitmap.width && bounds.bottom == bitmap.height
        ) {
            return bitmap
        }
        val cropped = Bitmap.createBitmap(
            bitmap,
            bounds.left,
            bounds.top,
            bounds.width(),
            bounds.height(),
        )
        bitmap.recycle()
        return cropped
    }

    private fun pageBounds(
        root: AccessibilityNodeInfo?,
        width: Int,
        height: Int,
    ): Rect {
        var toolbarBottom = (height * 0.088f).toInt()
        var bottomBarTop = (height * 0.942f).toInt()
        if (root != null) {
            val queue = ArrayDeque<AccessibilityNodeInfo>()
            queue.add(root)
            var visited = 0
            while (queue.isNotEmpty() && visited < 500) {
                val node = queue.removeFirst()
                visited++
                val viewId = node.viewIdResourceName?.toString()?.lowercase().orEmpty()
                val bounds = Rect()
                node.getBoundsInScreen(bounds)
                if (viewId.contains(":id/toolbar") && bounds.bottom > toolbarBottom) {
                    toolbarBottom = bounds.bottom
                }
                if (viewId.contains(":id/bottombar") && bounds.top < bottomBarTop) {
                    bottomBarTop = bounds.top
                }
                for (index in 0 until node.childCount) {
                    node.getChild(index)?.let(queue::add)
                }
            }
        }
        return Rect(
            0,
            toolbarBottom.coerceIn(0, height - 1),
            width,
            bottomBarTop.coerceIn(toolbarBottom + 1, height),
        )
    }
}
