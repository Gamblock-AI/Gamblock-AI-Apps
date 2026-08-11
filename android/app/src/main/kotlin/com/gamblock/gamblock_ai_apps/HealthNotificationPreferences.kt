package com.gamblock.gamblock_ai_apps

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

object HealthNotificationPreferences {
    private const val PREFS = "gamblock_native_preferences"
    private const val ENABLED_KEY = "health_notifications_enabled"

    fun setEnabled(context: Context, enabled: Boolean) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(ENABLED_KEY, enabled)
            .apply()
    }

    fun isEnabled(context: Context): Boolean {
        return context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getBoolean(ENABLED_KEY, true)
    }

    fun show(context: Context) {
        if (!isEnabled(context)) return
        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    BrowserProtectionAccessibilityService.CHANNEL_ID,
                    "Gamblock protection health",
                    NotificationManager.IMPORTANCE_LOW,
                ).apply {
                    description = "Local protection service and permission status"
                },
            )
        }
        manager.notify(
            BrowserProtectionAccessibilityService.NOTIFICATION_ID,
            NotificationCompat.Builder(
                context,
                BrowserProtectionAccessibilityService.CHANNEL_ID,
            )
                .setContentTitle("Gamblock AI")
                .setContentText("Local protection service is running")
                .setSmallIcon(android.R.drawable.ic_lock_lock)
                .setOngoing(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build(),
        )
    }
}
