package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import androidx.core.app.NotificationCompat

/**
 * Gamblock Accessibility Service
 * - Prevents app uninstall/modification
 * - Monitors package installs for gambling apps
 * - Prevents force-stop of Gamblock
 */
class GamblockAccessibilityService : AccessibilityService() {

    companion object {
        const val CHANNEL_ID = "gamblock_protection"
        const val NOTIFICATION_ID = 1001
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                         AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                         AccessibilityEvent.TYPE_VIEW_CLICKED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        }
        serviceInfo = info
        showPersistentNotification()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                // Check if user is trying to open app settings to uninstall
                checkUninstallAttempt(event)
                // Check opened app for gambling
                checkGamblingApp(event)
            }
            AccessibilityEvent.TYPE_VIEW_CLICKED -> {
                // Intercept clicks on "Uninstall" / "Force Stop" buttons
                interceptDangerousClicks(event)
            }
        }
    }

    private fun checkUninstallAttempt(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString() ?: return
        // Block access to Settings > Apps for Gamblock and partner apps
        if (packageName == "com.android.settings" ||
            packageName == "com.google.android.packageinstaller") {
            // Monitor for our package in uninstall screens
            val root = rootInActiveWindow ?: return
            findAndBlockDangerousButtons(root)
        }
    }

    private fun findAndBlockDangerousButtons(node: AccessibilityNodeInfo) {
        val dangerousTexts = listOf("Uninstall", "Force stop", "Clear data", "Disable")
        for (dangerous in dangerousTexts) {
            val buttons = node.findAccessibilityNodeInfosByText(dangerous)
            for (button in buttons) {
                // Check if this button targets Gamblock
                val parent = button.parent
                if (parent != null) {
                    val contentDesc = parent.contentDescription?.toString() ?: ""
                    if (contentDesc.contains("Gamblock", true) ||
                        contentDesc.contains("gamblock", true)) {
                        // Block the action and show warning
                        button.isClickable = false
                        button.isEnabled = false
                        showBlockNotification("Tindakan '$dangerous' diblokir. Hubungi Kepala grup Anda.")
                        performGlobalAction(GLOBAL_ACTION_BACK)
                        return
                    }
                }
            }
        }
    }

    private fun checkGamblingApp(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString() ?: return
        val pm = packageManager

        try {
            val appInfo = pm.getApplicationInfo(packageName, 0)
            val appName = pm.getApplicationLabel(appInfo).toString()

            if (isGamblingApp(packageName, appName)) {
                // Immediately close the gambling app
                performGlobalAction(GLOBAL_ACTION_BACK)
                performGlobalAction(GLOBAL_ACTION_HOME)

                // Show Pattern Interrupt
                val intent = Intent(this, MainActivity::class.java).apply {
                    putExtra("pattern_interrupt", true)
                    putExtra("blocked_package", packageName)
                    putExtra("blocked_app", appName)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }
                startActivity(intent)
            }
        } catch (e: PackageManager.NameNotFoundException) {
            // Package not installed — ignore
        }
    }

    private fun isGamblingApp(packageName: String, appName: String): Boolean {
        val gamblingKeywords = listOf(
            "slot", "casino", "poker", "judi", "togel", "betting",
            "sportbook", "bandar", "domino", "ceme", "gaple",
            "sbobet", "maxbet", "ioncasino", "pragmatic"
        )
        val lower = (packageName + appName).lowercase()
        return gamblingKeywords.any { lower.contains(it) }
    }

    private fun interceptDangerousClicks(event: AccessibilityEvent) {
        val source = event.source ?: return
        val text = source.text?.toString() ?: ""
        val desc = source.contentDescription?.toString() ?: ""

        if (text.contains("Uninstall", true) || desc.contains("Uninstall", true) ||
            text.contains("Force stop", true) || desc.contains("Force stop", true)) {
            source.isClickable = false
            showBlockNotification("Tindakan ini memerlukan izin Kepala grup.")
        }
    }

    private fun showPersistentNotification() {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "Gamblock Protection",
                NotificationManager.IMPORTANCE_LOW
            ).apply { description = "Perlindungan aktif" }
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Gamblock AI Aktif")
            .setContentText("Perlindungan judi online berjalan")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun showBlockNotification(message: String) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Gamblock AI")
            .setContentText(message)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setAutoCancel(true)
            .build()
        manager.notify(NOTIFICATION_ID + 1, notification)
    }

    override fun onInterrupt() {}
}
