package com.gamblock.gamblock_ai_apps

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent

/**
 * Research-only device administrator. While this admin is active Android
 * refuses uninstall until the admin is removed, so unilateral removal must
 * go through a controlled flow: a partner `uninstall_detected` grant or a
 * two-admin `emergency_access` grant is consumed before the app deactivates
 * its own admin and starts ACTION_DELETE.
 * No password policies are requested; the admin is a blocker only.
 */
class ProtectionDeviceAdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        val stateStore = ProtectionStateStore(context.applicationContext)
        if (stateStore.degradedReason() == "device_admin_inactive") {
            stateStore.setStatus(
                when {
                    stateStore.activeGrantAllowsProtectionPause() -> "paused"
                    stateStore.runtimeConnected() -> "active"
                    else -> "inactive"
                },
            )
        }
        ProtectionBridge.emit(context, mapOf("type" to "protection_status"))
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence {
        recordUnapprovedDisable(context)
        return context.getString(R.string.device_admin_disable_warning)
    }

    override fun onDisabled(context: Context, intent: Intent) {
        // Some OEM Settings flows skip the Accessibility event and disable the
        // administrator immediately before continuing with removal. Persist the
        // attempt from the Device Admin callback as a second, OS-level signal.
        // A valid removal grant is the only approved path and must not create a
        // stale approval request if the user cancels the uninstall dialog.
        val stateStore = ProtectionStateStore(context.applicationContext)
        if (stateStore.hasApprovedRemovalPending()) {
            stateStore.clearPendingTamperAction()
            stateStore.setStatus("degraded", "approved_removal_pending")
            ProtectionBridge.emit(context, mapOf("type" to "protection_status"))
            return
        }
        recordUnapprovedDisable(context, stateStore)
    }

    private fun recordUnapprovedDisable(
        context: Context,
        stateStore: ProtectionStateStore = ProtectionStateStore(context.applicationContext),
    ) {
        if (stateStore.hasApprovedRemovalPending()) return
        if (stateStore.recordPendingTamperAction("uninstall")) {
            DailyAggregateStore(context.applicationContext).increment("tamper_detected")
        }
        stateStore.setStatus("degraded", "device_admin_inactive")
    }
}
