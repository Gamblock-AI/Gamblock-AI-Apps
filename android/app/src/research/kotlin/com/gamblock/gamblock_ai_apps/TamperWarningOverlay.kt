package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Locale

/** Research-only partner-approval notice for protected settings changes. */
class TamperWarningOverlay(private val service: AccessibilityService) {
    private val windowManager = service.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var root: View? = null

    val isShowing: Boolean
        get() = root != null

    fun show() {
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
                    "Open Gamblock-AI Research to request an approved pause or removal window."
                } else {
                    "Buka Gamblock-AI Research untuk meminta jeda atau jendela pencopotan yang disetujui."
                },
                17f,
                Color.argb(210, 255, 255, 255),
            ),
        )
        container.addView(
            button(if (isEnglish) "Open Gamblock-AI" else "Buka Gamblock-AI") {
                service.startActivity(
                    Intent(service, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        putExtra("open_approval", true)
                    },
                )
                dismiss()
            },
        )
        container.addView(button(if (isEnglish) "Go back" else "Kembali") { dismiss() })
        root = container
        windowManager.addView(
            container,
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT,
            ),
        )
    }

    fun dismiss() {
        root?.let {
            runCatching { windowManager.removeView(it) }
        }
        root = null
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

    private fun dp(value: Int): Int {
        return (value * service.resources.displayMetrics.density).toInt()
    }
}
