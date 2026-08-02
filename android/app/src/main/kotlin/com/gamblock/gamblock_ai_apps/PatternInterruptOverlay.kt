package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityService
import android.animation.ValueAnimator
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.ViewTreeObserver
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Locale

class PatternInterruptOverlay(
    private val service: AccessibilityService,
    private val webBaseUrl: String,
) {
    private val windowManager = service.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val handler = Handler(Looper.getMainLooper())
    private var root: View? = null
    private var animator: ValueAnimator? = null

    fun showIntervention(onCommitted: (() -> Unit)? = null) {
        if (root != null) return
        val locale = if (Locale.getDefault().language == "en") "en" else "id"
        val isEnglish = locale == "en"
        val container = LinearLayout(service).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(24), dp(32), dp(24), dp(32))
            setBackgroundColor(Color.rgb(13, 27, 53))
        }
        val breathing = View(service).apply {
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.TRANSPARENT)
                setStroke(dp(4), Color.rgb(191, 233, 245))
            }
            contentDescription = if (isEnglish) "Slow breathing guide" else "Panduan napas perlahan"
        }
        val title = text(
            if (isEnglish) "Take a pause before continuing" else "Ambil jeda sebelum melanjutkan",
            26f,
            Color.WHITE,
        )
        val body = text(
            if (isEnglish) {
                "Breathe slowly. This brief pause is here to help you choose your next step."
            } else {
                "Tarik napas perlahan. Jeda singkat ini membantu Anda memilih langkah berikutnya."
            },
            17f,
            Color.argb(210, 255, 255, 255),
        )
        val countdown = text("7", 18f, Color.rgb(191, 233, 245))
        val continueButton = button(
            if (isEnglish) "Continue to recovery" else "Lanjut ke pemulihan",
        ) {
            openWeb("$locale/post-intervention?source=pattern_interrupt")
            dismiss()
        }.apply { isEnabled = false }
        val groundingButton = button(
            if (isEnglish) "Offline grounding" else "Grounding offline",
        ) {
            title.text = if (isEnglish) "Notice five things around you" else "Perhatikan lima hal di sekitar Anda"
            body.text = if (isEnglish) {
                "Name five things you see, four you feel, three you hear, two you smell, and one thing you want to protect today."
            } else {
                "Sebutkan lima hal yang terlihat, empat yang terasa, tiga yang terdengar, dua yang tercium, dan satu hal yang ingin Anda lindungi hari ini."
            }
            breathing.visibility = View.GONE
            continueButton.text = if (isEnglish) "Finish" else "Selesai"
            continueButton.setOnClickListener { dismiss() }
        }.apply { isEnabled = false }
        val helpButton = button(if (isEnglish) "I need help" else "Butuh bantuan") {
            openWeb("$locale/help")
        }
        val laterButton = button(if (isEnglish) "Return to protection" else "Kembali ke proteksi") {
            dismiss()
        }.apply { isEnabled = false }

        listOf(breathing, title, body, countdown, continueButton, groundingButton, helpButton, laterButton)
            .forEach { view ->
                container.addView(
                    view,
                    LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        if (view == breathing) dp(180) else LinearLayout.LayoutParams.WRAP_CONTENT,
                    ).apply {
                        topMargin = if (view == breathing) 0 else dp(12)
                    },
                )
            }
        onCommitted?.let { callback ->
            container.viewTreeObserver.addOnDrawListener(
                object : ViewTreeObserver.OnDrawListener {
                    private var delivered = false

                    override fun onDraw() {
                        if (delivered) return
                        delivered = true
                        container.post {
                            if (container.viewTreeObserver.isAlive) {
                                container.viewTreeObserver.removeOnDrawListener(this)
                            }
                            callback()
                        }
                    }
                },
            )
        }
        attach(container)
        if (!reducedMotion()) {
            animator = ValueAnimator.ofFloat(0.88f, 1.0f).apply {
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
        var remaining = 7
        fun tick() {
            if (root == null) return
            countdown.text = remaining.toString()
            if (remaining == 0) {
                countdown.text = if (isEnglish) "Choose your next step" else "Pilih langkah berikutnya"
                continueButton.isEnabled = true
                groundingButton.isEnabled = true
                laterButton.isEnabled = true
                return
            }
            remaining--
            handler.postDelayed(::tick, 1000)
        }
        tick()
    }

    fun showTamperWarning() {
        if (root != null) return
        val isEnglish = Locale.getDefault().language == "en"
        val container = LinearLayout(service).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(24), dp(32), dp(24), dp(32))
            setBackgroundColor(Color.rgb(13, 27, 53))
        }
        container.addView(
            text(
                if (isEnglish) "Partner approval required" else "Persetujuan pendamping diperlukan",
                26f,
                Color.WHITE,
            ),
        )
        container.addView(
            text(
                if (isEnglish) {
                    "Open Gamblock AI to request a pause, disable, or removal window for this device."
                } else {
                    "Buka Gamblock AI untuk meminta jeda, penonaktifan, atau jendela pencopotan pada perangkat ini."
                },
                17f,
                Color.argb(210, 255, 255, 255),
            ),
        )
        container.addView(
            button(if (isEnglish) "Open Gamblock AI" else "Buka Gamblock AI") {
                service.startActivity(
                    Intent(service, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        putExtra("open_approval", true)
                    },
                )
                dismiss()
            },
        )
        container.addView(
            button(if (isEnglish) "Go back" else "Kembali") { dismiss() },
        )
        attach(container)
    }

    fun dismiss() {
        handler.removeCallbacksAndMessages(null)
        animator?.cancel()
        animator = null
        root?.let {
            try {
                windowManager.removeView(it)
            } catch (_: Exception) {
            }
        }
        root = null
    }

    private fun attach(view: View) {
        root = view
        windowManager.addView(
            view,
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT,
            ),
        )
    }

    private fun text(value: String, size: Float, color: Int): TextView {
        return TextView(service).apply {
            text = value
            textSize = size
            setTextColor(color)
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.25f)
        }
    }

    private fun button(label: String, action: () -> Unit): Button {
        return Button(service).apply {
            text = label
            minHeight = dp(52)
            isAllCaps = false
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
