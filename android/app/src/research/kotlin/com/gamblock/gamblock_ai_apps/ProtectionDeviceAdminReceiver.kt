package com.gamblock.gamblock_ai_apps

import android.app.admin.DeviceAdminReceiver

/**
 * Research-only device administrator. While this admin is active Android
 * refuses uninstall until the admin is removed, so unilateral removal must
 * go through the partner approval flow: a valid `uninstall_detected` grant
 * lets the app deactivate its own admin before starting ACTION_DELETE.
 * No password policies are requested; the admin is a blocker only.
 */
class ProtectionDeviceAdminReceiver : DeviceAdminReceiver()
