package com.gamblock.gamblock_ai_apps

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent

/**
 * Research-only device administrator. While this admin is active Android
 * refuses uninstall until the admin is removed, so unilateral removal must
 * go through the partner approval flow: a valid `uninstall_detected` grant
 * lets the app deactivate its own admin before starting ACTION_DELETE.
 * No password policies are requested; the admin is a blocker only.
 */
class ProtectionDeviceAdminReceiver : DeviceAdminReceiver() {
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
        if (stateStore.activeGrantAllowsControlledRemoval()) {
            stateStore.clearPendingTamperAction()
            stateStore.setStatus("inactive", "approved_removal")
            return
        }
        recordUnapprovedDisable(context, stateStore)
    }

    private fun recordUnapprovedDisable(
        context: Context,
        stateStore: ProtectionStateStore = ProtectionStateStore(context.applicationContext),
    ) {
        if (stateStore.activeGrantAllowsControlledRemoval()) return
        if (stateStore.recordPendingTamperAction("uninstall")) {
            DailyAggregateStore(context.applicationContext).increment("tamper_detected")
        }
        stateStore.setStatus("degraded", "device_admin_inactive")
    }
}
