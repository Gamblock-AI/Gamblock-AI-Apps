package com.gamblock.gamblock_ai_apps

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/**
 * Foreground keep-alive for the accessibility protection service.
 *
 * The accessibility service shares the default process with the Flutter UI
 * task. When the user removes the app from Recents, Android removes the task
 * and would kill the whole process. A foreground service anchors the process
 * so local classification and blocking keep running while the UI is closed.
 *
 * Keep-alive runs only while protection is enabled and health notifications
 * are allowed, so the ongoing notification is never shown against the user's
 * preference.
 */
class ProtectionKeepAliveService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Once startForegroundService() has been called the service MUST
        // enter the foreground state within a short window, otherwise the
        // system kills the process with ForegroundServiceDidNotStartInTime
        // (which crash-looped the accessibility service). Enter foreground
        // unconditionally first, then decide whether to keep running.
        val enteredForeground = runCatching {
            enterForeground()
            true
        }.getOrDefault(false)
        if (!enteredForeground) {
            stopSelf(startId)
            return START_NOT_STICKY
        }
        if (!isProtectionEnabled() || !HealthNotificationPreferences.isEnabled(this)) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf(startId)
            return START_NOT_STICKY
        }
        return START_STICKY
    }

    private fun enterForeground() {
        HealthNotificationPreferences.ensureChannel(this)
        val notification = HealthNotificationPreferences.buildNotification(this)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                BrowserProtectionAccessibilityService.NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(
                BrowserProtectionAccessibilityService.NOTIFICATION_ID,
                notification,
            )
        }
    }

    private fun isProtectionEnabled(): Boolean {
        val manager = getSystemService(Context.ACCESSIBILITY_SERVICE) as android.view.accessibility.AccessibilityManager
        return manager.getEnabledAccessibilityServiceList(
            android.accessibilityservice.AccessibilityServiceInfo.FEEDBACK_ALL_MASK,
        ).any {
            it.resolveInfo.serviceInfo.packageName == packageName &&
                (it.resolveInfo.serviceInfo.name.contains("AccessibilityService") ||
                    it.resolveInfo.serviceInfo.name.contains("Gamblock"))
        }
    }

    companion object {
        fun start(context: Context) {
            if (!HealthNotificationPreferences.isEnabled(context)) return
            val intent = Intent(context, ProtectionKeepAliveService::class.java)
            runCatching {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, ProtectionKeepAliveService::class.java)
            runCatching { context.stopService(intent) }
        }
    }
}
