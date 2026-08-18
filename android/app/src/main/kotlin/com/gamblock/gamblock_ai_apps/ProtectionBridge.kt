package com.gamblock.gamblock_ai_apps

import android.content.Context
import android.content.Intent
import android.os.Bundle

/**
 * Cross-process event and registration state for protection.
 *
 * The accessibility service and keep-alive live in the dedicated
 * `:protection` process; the Flutter UI lives in the default process. Events
 * flow service -> UI through an app-internal broadcast, and the UI registers
 * its presentation availability through [ProtectionBridgeProvider] (which
 * tracks binder death so a killed UI task is detected immediately).
 */
object ProtectionBridge {
    const val ACTION_EVENT = "com.gamblock.gamblock_ai_apps.PROTECTION_EVENT"

    /** True while the Flutter UI process is alive and listening. */
    @Volatile
    var uiRegistered: Boolean = false

    fun emit(context: Context, event: Map<String, Any?>) {
        runCatching {
            val intent = Intent(ACTION_EVENT).setPackage(context.packageName)
            event.forEach { (key, value) -> putAny(intent, key, value) }
            context.sendBroadcast(intent)
        }
    }

    fun mapToBundle(map: Map<String, Any?>): Bundle {
        val bundle = Bundle()
        map.forEach { (key, value) -> putAny(bundle, key, value) }
        return bundle
    }

    fun bundleToMap(bundle: Bundle?): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        bundle ?: return map
        for (key in bundle.keySet()) {
            map[key] = bundle.get(key)
        }
        return map
    }

    private fun putAny(target: Any, key: String, value: Any?) {
        when (value) {
            null -> Unit
            is String -> when (target) {
                is Intent -> target.putExtra(key, value)
                is Bundle -> target.putString(key, value)
            }
            is Boolean -> when (target) {
                is Intent -> target.putExtra(key, value)
                is Bundle -> target.putBoolean(key, value)
            }
            is Int -> when (target) {
                is Intent -> target.putExtra(key, value)
                is Bundle -> target.putInt(key, value)
            }
            is Long -> when (target) {
                is Intent -> target.putExtra(key, value)
                is Bundle -> target.putLong(key, value)
            }
            is Double -> when (target) {
                is Intent -> target.putExtra(key, value)
                is Bundle -> target.putDouble(key, value)
            }
        }
    }
}
