package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityService
import android.animation.ValueAnimator
import android.content.Context
import android.content.Intent
import android.content.res.AssetFileDescriptor
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.PixelFormat
import android.graphics.SurfaceTexture
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.RippleDrawable
import android.content.res.ColorStateList
import android.media.MediaPlayer
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.Surface
import android.view.TextureView
import android.view.View
import android.view.ViewTreeObserver
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import io.flutter.FlutterInjector
import java.util.Locale

class PatternInterruptOverlay(
    private val service: AccessibilityService,
    private val webBaseUrl: String,
) {
    private val windowManager = service.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val handler = Handler(Looper.getMainLooper())
    private var root: FrameLayout? = null
    private var prepared = false
    private var animator: ValueAnimator? = null
    private var activeInterventionId: String? = null
    private var completion: (() -> Unit)? = null
    private var mediaPlayer: MediaPlayer? = null
    private var videoSurface: Surface? = null
    private var textureView: TextureView? = null

    private data class ForegroundContent(
        val view: LinearLayout,
        val breathing: View,
        val title: TextView,
        val body: TextView,
        val countdownBadge: TextView,
        val continueButton: Button,
        val groundingButton: Button,
        val laterButton: TextView,
        val buttonBackground: (Boolean, Boolean) -> GradientDrawable,
    )

    /**
     * Allocate the accessibility window while the service is idle. Android can
     * then reuse the surface for a block instead of creating a new overlay in
     * the latency-critical path.
     */
    fun prepare() {
        if (root != null) return
        val preparedRoot = FrameLayout(service).apply {
            setBackgroundColor(Color.TRANSPARENT)
            visibility = View.INVISIBLE
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }
        val params = windowParams(idle = true)
        runCatching {
            windowManager.addView(preparedRoot, params)
            root = preparedRoot
            prepared = true
        }
    }

    fun showIntervention(
        interventionId: String,
        onCommitted: ((Long) -> Unit)? = null,
        onCompleted: (() -> Unit)? = null,
    ) {
        if (activeInterventionId == interventionId) return
        if (activeInterventionId != null) dismiss()
        activeInterventionId = interventionId
        completion = onCompleted
        val locale = if (Locale.getDefault().language == "en") "en" else "id"
        val isEnglish = locale == "en"

        // Root container covering full screen
        val rootLayout = (root ?: FrameLayout(service)).apply {
            removeAllViews()
            setBackgroundColor(Color.rgb(11, 19, 43))
        }

        // Gradient Scrim Layer: Dark at top & bottom for legibility, translucent in center
        val scrim = View(service).apply {
            background = GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                intArrayOf(
                    Color.argb(175, 5, 10, 20),
                    Color.argb(45, 5, 10, 20),
                    Color.argb(55, 5, 10, 20),
                    Color.argb(230, 9, 9, 11),
                ),
            )
        }
        rootLayout.addView(
            scrim,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        // Foreground UI is lazy so the first native frame does not pay for
        // constructing controls that are not needed to establish visibility.
        val foregroundContent by lazy {
        // Foreground UI: Floating Header at Top, Empty Center Viewport, Action Dock at Bottom
        val foreground = LinearLayout(service).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(20), dp(44), dp(20), dp(28))
        }

        // --- Top Floating Header ---
        val headerLayout = LinearLayout(service).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
        }

        val breathing = View(service).apply {
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.argb(35, 56, 189, 248))
                setStroke(dp(3), Color.rgb(186, 230, 253))
            }
            contentDescription = if (isEnglish) "Slow breathing guide" else "Panduan napas perlahan"
        }
        headerLayout.addView(
            breathing,
            LinearLayout.LayoutParams(dp(68), dp(68)).apply {
                gravity = Gravity.CENTER_HORIZONTAL
                bottomMargin = dp(12)
            },
        )

        val title = text(
            if (isEnglish) "Take a pause before continuing" else "Ambil jeda sebelum melanjutkan",
            21f,
            Color.WHITE,
            isBold = true,
        ).apply {
            setShadowLayer(10f, 0f, 2f, Color.argb(200, 0, 0, 0))
        }
        headerLayout.addView(
            title,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
                bottomMargin = dp(6)
            },
        )

        val body = text(
            if (isEnglish) {
                "Breathe slowly. This brief pause is here to help you choose your next step."
            } else {
                "Tarik napas perlahan. Jeda singkat ini membantu Anda memilih langkah berikutnya."
            },
            13f,
            Color.argb(230, 241, 245, 249),
            isBold = false,
        ).apply {
            setShadowLayer(8f, 0f, 1f, Color.argb(180, 0, 0, 0))
        }
        headerLayout.addView(
            body,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
            },
        )

        foreground.addView(
            headerLayout,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )

        // --- Center Open Viewport (Spacer) ---
        // Keeps the middle screen open so the calm intervention video loop is completely unobstructed
        val centerSpacer = View(service)
        foreground.addView(
            centerSpacer,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                0,
                1.0f,
            ),
        )

        // --- Bottom Floating Action Dock ---
        val dockLayout = LinearLayout(service).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            background = GradientDrawable().apply {
                setColor(Color.argb(185, 15, 23, 42))
                cornerRadius = dp(22).toFloat()
                setStroke(dp(1), Color.argb(50, 255, 255, 255))
            }
            setPadding(dp(16), dp(16), dp(16), dp(12))
        }

        val countdownBadge = TextView(service).apply {
            text = if (isEnglish) {
                "Wait ${ProtectionTimingContract.PATTERN_INTERRUPT_SECONDS} seconds"
            } else {
                "Tunggu ${ProtectionTimingContract.PATTERN_INTERRUPT_SECONDS} detik"
            }
            textSize = 12f
            setTypeface(typeface, Typeface.BOLD)
            setTextColor(Color.rgb(186, 230, 253))
            gravity = Gravity.CENTER
            setPadding(dp(14), dp(6), dp(14), dp(6))
            background = GradientDrawable().apply {
                setColor(Color.argb(60, 56, 189, 248))
                cornerRadius = dp(999).toFloat()
                setStroke(dp(1), Color.argb(120, 56, 189, 248))
            }
        }
        dockLayout.addView(
            countdownBadge,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
                bottomMargin = dp(14)
            },
        )

        fun buttonBackground(enabled: Boolean, isPrimary: Boolean): GradientDrawable {
            return GradientDrawable().apply {
                cornerRadius = dp(999).toFloat()
                if (enabled) {
                    if (isPrimary) {
                        setColor(Color.rgb(2, 132, 199))
                        setStroke(dp(1), Color.argb(100, 255, 255, 255))
                    } else {
                        setColor(Color.argb(35, 255, 255, 255))
                        setStroke(dp(1), Color.argb(90, 255, 255, 255))
                    }
                } else {
                    setColor(Color.argb(20, 255, 255, 255))
                    setStroke(dp(1), Color.argb(25, 255, 255, 255))
                }
            }
        }

        val continueButton = button(
            if (isEnglish) "Continue to recovery" else "Lanjut ke pemulihan",
            isPrimary = true,
        ) {
            runCatching { openWeb("$locale/post-intervention?source=pattern_interrupt") }
            completeAndDismiss()
        }.apply {
            isEnabled = false
            background = buttonBackground(enabled = false, isPrimary = true)
            setTextColor(Color.argb(100, 255, 255, 255))
        }
        dockLayout.addView(
            continueButton,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(46),
            ).apply {
                bottomMargin = dp(10)
            },
        )

        val groundingButton = button(
            if (isEnglish) "Offline grounding" else "Grounding offline",
            isPrimary = false,
        ) {
            title.text = if (isEnglish) "Notice five things around you" else "Perhatikan lima hal di sekitar Anda"
            body.text = if (isEnglish) {
                "Name five things you see, four you feel, three you hear, two you smell, and one thing you want to protect today."
            } else {
                "Sebutkan lima hal yang terlihat, empat yang terasa, tiga yang terdengar, dua yang tercium, dan satu hal yang ingin Anda lindungi hari ini."
            }
            breathing.visibility = View.GONE
            countdownBadge.visibility = View.GONE
            continueButton.text = if (isEnglish) "Finish" else "Selesai"
            continueButton.isEnabled = true
            continueButton.background = buttonBackground(enabled = true, isPrimary = true)
            continueButton.setTextColor(Color.WHITE)
            continueButton.setOnClickListener { completeAndDismiss() }
        }.apply {
            isEnabled = false
            background = buttonBackground(enabled = false, isPrimary = false)
            setTextColor(Color.argb(90, 255, 255, 255))
        }
        dockLayout.addView(
            groundingButton,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(42),
            ).apply {
                bottomMargin = dp(6)
            },
        )

        val bottomRow = LinearLayout(service).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        val helpButton = textAction(if (isEnglish) "I need help" else "Butuh bantuan") {
            runCatching { openWeb("$locale/help") }
        }
        bottomRow.addView(
            helpButton,
            LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.0f).apply {
                gravity = Gravity.START
            },
        )

        val laterButton = textAction(if (isEnglish) "Return to protection" else "Kembali ke proteksi") {
            completeAndDismiss()
        }.apply {
            alpha = 0f
            isEnabled = false
        }
        bottomRow.addView(
            laterButton,
            LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.0f).apply {
                gravity = Gravity.END
            },
        )

        dockLayout.addView(
            bottomRow,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )

        foreground.addView(
            dockLayout,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )

        ForegroundContent(
            view = foreground,
            breathing = breathing,
            title = title,
            body = body,
            countdownBadge = countdownBadge,
            continueButton = continueButton,
            groundingButton = groundingButton,
            laterButton = laterButton,
            buttonBackground = ::buttonBackground,
        )
        }

        val foregroundParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT,
        )

        // Keep the first committed frame intentionally small. The protection
        // boundary only needs an opaque, recognisable pause shell; the full
        // action dock and its controls can be attached immediately after that
        // frame is drawn without delaying native visibility acknowledgement.
        val firstFrameShell = text(
            if (isEnglish) "Take a pause" else "Ambil jeda",
            21f,
            Color.WHITE,
            isBold = true,
        ).apply {
            setPadding(dp(24), dp(24), dp(24), dp(24))
            setShadowLayer(10f, 0f, 2f, Color.argb(200, 0, 0, 0))
        }
        val firstFrameParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT,
            Gravity.CENTER,
        )
        if (onCommitted == null) {
            rootLayout.addView(foregroundContent.view, foregroundParams)
        } else {
            rootLayout.addView(firstFrameShell, firstFrameParams)
        }

        var runCountdownAfterCommit: (() -> Unit)? = null
        onCommitted?.let { callback ->
            rootLayout.viewTreeObserver.addOnDrawListener(
                object : ViewTreeObserver.OnDrawListener {
                    private var delivered = false

                    override fun onDraw() {
                        if (delivered) return
                        delivered = true
                        // Capture the first frame boundary before dispatching
                        // state and file I/O back through the UI queue.
                        val firstFrameNanos = SystemClock.elapsedRealtimeNanos()
                        rootLayout.post {
                            if (rootLayout.viewTreeObserver.isAlive) {
                                rootLayout.viewTreeObserver.removeOnDrawListener(this)
                            }
                            if (root !== rootLayout) return@post
                            // A small opaque shell has already been drawn. Record
                            // that boundary before constructing the full UI.
                            callback(firstFrameNanos)
                            if (root !== rootLayout) return@post
                            rootLayout.removeView(firstFrameShell)
                            val content = foregroundContent
                            rootLayout.addView(content.view, foregroundParams)
                            startBreathingAnimation(content.breathing)
                            // Video initialization is intentionally deferred:
                            // the opaque first frame is the latency boundary.
                            setupVideoBackground(rootLayout)
                            runCountdownAfterCommit?.invoke()
                        }
                    }
                },
            )
        }

        attach(rootLayout)

        if (onCommitted == null) {
            startBreathingAnimation(foregroundContent.breathing)
        }

        var remaining = ProtectionTimingContract.PATTERN_INTERRUPT_SECONDS
        fun tick() {
            if (root == null) return
            val content = foregroundContent
            if (remaining > 0) {
                content.countdownBadge.text = if (isEnglish) "Wait $remaining seconds" else "Tunggu $remaining detik"
            } else {
                content.countdownBadge.text = if (isEnglish) "Choose your next step" else "Pilih langkah berikutnya"
                content.countdownBadge.setTextColor(Color.rgb(167, 243, 208))
                content.countdownBadge.background = GradientDrawable().apply {
                    setColor(Color.argb(70, 16, 185, 129))
                    cornerRadius = dp(999).toFloat()
                    setStroke(dp(1), Color.argb(130, 52, 211, 153))
                }

                content.continueButton.isEnabled = true
                content.continueButton.background = content.buttonBackground(true, true)
                content.continueButton.setTextColor(Color.WHITE)

                content.groundingButton.isEnabled = true
                content.groundingButton.background = content.buttonBackground(true, false)
                content.groundingButton.setTextColor(Color.WHITE)

                content.laterButton.isEnabled = true
                content.laterButton.animate().alpha(1.0f).setDuration(250).start()
                return
            }
            remaining--
            handler.postDelayed(::tick, 1000)
        }
        runCountdownAfterCommit = { tick() }
        if (onCommitted == null) tick()
    }

    private fun startBreathingAnimation(breathing: View) {
        if (reducedMotion()) return
        animator = ValueAnimator.ofFloat(0.88f, 1.06f).apply {
            duration = 4000
            repeatMode = ValueAnimator.REVERSE
            repeatCount = ValueAnimator.INFINITE
            interpolator = AccelerateDecelerateInterpolator()
            addUpdateListener {
                val scale = it.animatedValue as Float
                breathing.scaleX = scale
                breathing.scaleY = scale
            }
            start()
        }
    }

    private fun setupVideoBackground(rootLayout: FrameLayout) {
        if (reducedMotion()) return

        val afd = openVideoAssetFd() ?: return
        try {
            val mp = MediaPlayer().apply {
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                isLooping = true
                setVolume(0f, 0f)
            }
            mediaPlayer = mp

            val tv = TextureView(service).apply {
                surfaceTextureListener = object : TextureView.SurfaceTextureListener {
                    override fun onSurfaceTextureAvailable(surfaceTexture: SurfaceTexture, width: Int, height: Int) {
                        runCatching {
                            val surface = Surface(surfaceTexture)
                            videoSurface = surface
                            mp.setSurface(surface)
                            mp.setOnPreparedListener { player ->
                                runCatching {
                                    adjustAspectRatio(this@apply, player.videoWidth, player.videoHeight)
                                    player.start()
                                }
                            }
                            mp.setOnVideoSizeChangedListener { _, vw, vh ->
                                runCatching {
                                    adjustAspectRatio(this@apply, vw, vh)
                                }
                            }
                            mp.prepareAsync()
                        }
                    }

                    override fun onSurfaceTextureSizeChanged(surfaceTexture: SurfaceTexture, width: Int, height: Int) {
                        runCatching {
                            if (mp.isPlaying) {
                                adjustAspectRatio(this@apply, mp.videoWidth, mp.videoHeight)
                            }
                        }
                    }

                    override fun onSurfaceTextureDestroyed(surfaceTexture: SurfaceTexture): Boolean {
                        // These callbacks can fire after dismiss() already
                        // released the player; a released MediaPlayer throws
                        // IllegalStateException on any call, which would crash
                        // the protection process.
                        runCatching { mp.setSurface(null) }
                        runCatching { videoSurface?.release() }
                        videoSurface = null
                        return true
                    }

                    override fun onSurfaceTextureUpdated(surfaceTexture: SurfaceTexture) {}
                }
            }
            textureView = tv
            rootLayout.addView(
                tv,
                0,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT,
                ),
            )
        } catch (_: Exception) {
            runCatching { afd.close() }
        }
    }

    private fun openVideoAssetFd(): AssetFileDescriptor? {
        return try {
            val loader = FlutterInjector.instance().flutterLoader()
            val key = loader.getLookupKeyForAsset("assets/videos/intervention-android.mp4")
            service.assets.openFd(key)
        } catch (_: Exception) {
            try {
                service.assets.openFd("flutter_assets/assets/videos/intervention-android.mp4")
            } catch (_: Exception) {
                null
            }
        }
    }

    private fun adjustAspectRatio(tv: TextureView, videoWidth: Int, videoHeight: Int) {
        val viewWidth = tv.width
        val viewHeight = tv.height
        if (viewWidth == 0 || viewHeight == 0 || videoWidth == 0 || videoHeight == 0) return

        val viewRatio = viewWidth.toFloat() / viewHeight.toFloat()
        val videoRatio = videoWidth.toFloat() / videoHeight.toFloat()
        val scaleX: Float
        val scaleY: Float

        if (viewRatio > videoRatio) {
            scaleX = 1f
            scaleY = (viewWidth.toFloat() / videoWidth.toFloat()) / (viewHeight.toFloat() / videoHeight.toFloat())
        } else {
            scaleX = (viewHeight.toFloat() / videoHeight.toFloat()) / (viewWidth.toFloat() / videoWidth.toFloat())
            scaleY = 1f
        }

        val matrix = Matrix()
        matrix.setScale(scaleX, scaleY, viewWidth / 2f, viewHeight / 2f)
        tv.setTransform(matrix)
    }

    fun dismiss() {
        handler.removeCallbacksAndMessages(null)
        animator?.cancel()
        animator = null
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
        } catch (_: Exception) {
        }
        mediaPlayer = null
        videoSurface?.release()
        videoSurface = null
        textureView = null
        root?.let {
            if (prepared) {
                it.removeAllViews()
                it.setBackgroundColor(Color.TRANSPARENT)
                it.importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
                it.visibility = View.INVISIBLE
                updateWindow(it, idle = true)
            } else {
                try {
                    windowManager.removeView(it)
                } catch (_: Exception) {
                }
                root = null
            }
        }
        activeInterventionId = null
        completion = null
    }

    /** Release the pre-warmed window when the Accessibility service is destroyed. */
    fun destroy() {
        dismiss()
        root?.let {
            runCatching { windowManager.removeView(it) }
        }
        root = null
        prepared = false
    }

    fun dismissIntervention(interventionId: String) {
        if (activeInterventionId == interventionId) dismiss()
    }

    private fun completeAndDismiss() {
        val callback = completion
        dismiss()
        callback?.invoke()
    }

    private fun attach(view: FrameLayout) {
        if (prepared && root === view) {
            view.importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_AUTO
            view.visibility = View.VISIBLE
            updateWindow(view, idle = false)
            return
        }
        val params = windowParams(idle = false)
        windowManager.addView(view, params)
        root = view
    }

    private fun updateWindow(view: View, idle: Boolean) {
        val params = windowParams(idle)
        runCatching { windowManager.updateViewLayout(view, params) }
    }

    private fun windowParams(idle: Boolean): WindowManager.LayoutParams {
        val flags = WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            if (idle) {
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
            } else {
                0
            }
        return WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            flags,
            PixelFormat.TRANSLUCENT,
        )
    }

    private fun text(value: String, size: Float, color: Int, isBold: Boolean = false): TextView {
        return TextView(service).apply {
            text = value
            textSize = size
            setTextColor(color)
            if (isBold) setTypeface(typeface, Typeface.BOLD)
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.25f)
        }
    }

    private fun button(label: String, isPrimary: Boolean, action: () -> Unit): Button {
        return Button(service).apply {
            text = label
            textSize = if (isPrimary) 14f else 13.5f
            setTypeface(typeface, Typeface.BOLD)
            isAllCaps = false
            setOnClickListener { action() }
            stateListAnimator = null
        }
    }

    private fun textAction(label: String, action: () -> Unit): TextView {
        return TextView(service).apply {
            text = label
            textSize = 12.5f
            setTextColor(Color.argb(200, 255, 255, 255))
            setPadding(dp(8), dp(6), dp(8), dp(6))
            isClickable = true
            isFocusable = true
            setOnClickListener { action() }
        }
    }

    private fun openWeb(relative: String) {
        val base = webBaseUrl.trimEnd('/')
        service.startActivity(
            Intent(Intent.ACTION_VIEW, Uri.parse("$base/$relative")).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
        )
    }

    private fun reducedMotion(): Boolean {
        return try {
            Settings.Global.getFloat(
                service.contentResolver,
                Settings.Global.ANIMATOR_DURATION_SCALE,
                1f,
            ) == 0f
        } catch (_: Exception) {
            false
        }
    }

    private fun dp(value: Int): Int {
        return (value * service.resources.displayMetrics.density).toInt()
    }
}
