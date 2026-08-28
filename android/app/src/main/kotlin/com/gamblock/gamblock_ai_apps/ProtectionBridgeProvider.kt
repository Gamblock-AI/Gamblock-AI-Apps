package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityServiceInfo
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.accessibility.AccessibilityManager
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/**
 * Bridge between the Flutter UI process and the dedicated `:protection`
 * process. Runs only in `:protection` (manifest `android:process`), so every
 * protection operation and event stays in the process that owns blocking.
 *
 * The Flutter side calls through ContentResolver.call(); heavy or
 * service-bound operations are marshalled onto the protection main thread
 * with a bounded wait.
 */
class ProtectionBridgeProvider : ContentProvider() {
    companion object {
        private const val WAIT_TIMEOUT_MS = 1_000L
        private val mainHandler = Handler(Looper.getMainLooper())
    }

    private lateinit var stateStore: ProtectionStateStore
    private lateinit var aggregates: DailyAggregateStore
    private var watchedUiToken: IBinder? = null

    override fun onCreate(): Boolean {
        stateStore = ProtectionStateStore(context!!)
        aggregates = DailyAggregateStore(context!!)
        return true
    }

    override fun call(method: String, arg: String?, extras: Bundle?): Bundle? {
        return try {
            dispatch(method, arg, extras)
        } catch (_: Exception) {
            null
        }
    }

    private fun dispatch(method: String, arg: String?, extras: Bundle?): Bundle? {
        return when (method) {
            "register_ui" -> {
                watchedUiToken?.unlinkToDeath(uiDeath, 0)
                val token = extras?.getBinder("token")
                if (token != null) {
                    watchedUiToken = token
                    runCatching { token.linkToDeath(uiDeath, 0) }
                }
                ProtectionBridge.uiRegistered = true
                // The service may have connected before Flutter finished
                // attaching its EventChannel listener. Replay the current
                // snapshot now so startup cannot leave a stale cached status
                // in the dashboard.
                ProtectionBridge.emit(context!!, snapshot())
                null
            }
            "unregister_ui" -> {
                watchedUiToken?.unlinkToDeath(uiDeath, 0)
                watchedUiToken = null
                ProtectionBridge.uiRegistered = false
                null
            }
            "ui_presentation_lost" -> {
                onMain {
                    stateStore.activeIntervention()?.let { pending ->
                        val released = stateStore.releaseFlutterOwnershipForReplay(pending.id)
                            ?: pending
                        BrowserProtectionAccessibilityService.notifyFlutterPresentationLost(
                            released.id,
                        )
                    }
                }
                null
            }
            "get_snapshot" -> ProtectionBridge.mapToBundle(snapshot())
            "get_pending_events" -> Bundle().apply {
                putParcelableArrayList("events", pendingEvents())
            }
            "ack_intervention_visible" -> {
                val accepted = ackInterventionVisible(arg.orEmpty())
                Bundle().apply { putBoolean("value", accepted) }
            }
            "complete_intervention" -> {
                val completed = completeIntervention(arg.orEmpty())
                Bundle().apply { putBoolean("value", completed) }
            }
            "set_device_id" -> Bundle().apply {
                putBoolean("value", stateStore.setDeviceId(arg.orEmpty()))
            }
            "grant_key_enrollment" -> {
                val deviceId = extras?.getString("device_id").orEmpty()
                val challengeToken = extras?.getString("challenge_token").orEmpty()
                val enrollment = stateStore.grantKeyEnrollment(deviceId, challengeToken)
                if (enrollment == null) {
                    null
                } else {
                    Bundle().apply {
                        putString("public_jwk", enrollment["public_jwk"] ?: "")
                        putString("jwk_thumbprint", enrollment["jwk_thumbprint"] ?: "")
                        putString("proof", enrollment["proof"] ?: "")
                    }
                }
            }
            "store_grant" -> Bundle().apply {
                putBoolean("value", stateStore.storeGrant(arg.orEmpty()))
            }
            "begin_approved_removal" -> Bundle().apply {
                putBoolean("value", beginApprovedRemoval())
            }
            "drain_daily_aggregates" -> aggregatesBundle(aggregates.completedDays())
            "get_current_daily_aggregates" -> aggregatesBundle(aggregates.currentDay())
            "ack_daily_aggregates" -> {
                aggregates.acknowledge(extras?.getStringArrayList("keys") ?: emptyList())
                null
            }
            "ensure_background_protection" -> Bundle().apply {
                putBoolean("value", ensureBackgroundProtection())
            }
            else -> null
        }
    }

    private val uiDeath = IBinder.DeathRecipient {
        mainHandler.post { ProtectionBridge.uiRegistered = false }
    }

    private fun ackInterventionVisible(interventionId: String): Boolean {
        val service = BrowserProtectionAccessibilityService.current() ?: return false
        return onMain {
            val claim = service.claimFlutterVisibility(interventionId)
            if (claim.accepted) {
                BrowserProtectionAccessibilityService.notifyFlutterVisibilityClaimed(
                    interventionId,
                )
            }
            if (claim.newlyVisible) {
                aggregates.increment("intervention_shown")
            }
            claim.accepted
        }
    }

    private fun completeIntervention(interventionId: String): Boolean {
        val service = BrowserProtectionAccessibilityService.current() ?: return false
        return onMain {
            val completed = service.completeIntervention(interventionId)
            if (completed) {
                BrowserProtectionAccessibilityService.notifyInterventionCompleted(
                    interventionId,
                )
            }
            completed
        }
    }

    private fun snapshot(): Map<String, Any?> {
        val service = BrowserProtectionAccessibilityService.current()
        if (service != null) {
            return service.snapshotMap()
        }
        val enabled = isAccessibilityEnabled()
        val runtimeConnected = enabled && stateStore.runtimeConnected()
        val storedStatus = stateStore.status()
        return mapOf(
            "platform" to "android",
            "status" to if (runtimeConnected) storedStatus else "inactive",
            "service_running" to runtimeConnected,
            "sensor_status" to if (runtimeConnected) "connected" else "disconnected",
            "permission_status" to if (enabled) "granted" else "revoked",
            "model_version" to HybridClassifier.DEFAULT_MODEL_VERSION,
            "ruleset_version" to HybridClassifier.DEFAULT_RULESET_VERSION,
            "supports_controlled_removal" to BuildConfig.SUPPORTS_CONTROLLED_REMOVAL,
            "device_admin_active" to isDeviceAdminActive(),
            "degraded_reason_code" to when {
                runtimeConnected -> stateStore.degradedReason()
                enabled -> "service_not_running"
                else -> "accessibility_disabled"
            },
            "last_event_at" to stateStore.lastEventAt(),
        )
    }

    private fun pendingEvents(): ArrayList<Bundle> {
        val events = ArrayList<Bundle>()
        onMain {
            stateStore.activeIntervention()?.event()?.let {
                events.add(ProtectionBridge.mapToBundle(it))
            }
            stateStore.pendingApprovalEvent()?.let {
                events.add(ProtectionBridge.mapToBundle(it))
            }
        }
        return events
    }

    private fun aggregatesBundle(rows: List<Map<String, Any>>): Bundle {
        val list = ArrayList<Bundle>()
        rows.forEach { row -> list.add(ProtectionBridge.mapToBundle(row)) }
        return Bundle().apply { putParcelableArrayList("rows", list) }
    }

    private fun beginApprovedRemoval(): Boolean {
        if (!BuildConfig.SUPPORTS_CONTROLLED_REMOVAL) return false
        if (!stateStore.activeGrantAllowsControlledRemoval()) return false
        // Partner-approved removal: deactivate our own device administrator
        // first so Android allows the uninstall.
        val dpm = context!!.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        runCatching {
            dpm.removeActiveAdmin(
                ComponentName(context!!.packageName, "com.gamblock.gamblock_ai_apps.ProtectionDeviceAdminReceiver"),
            )
        }
        val removalIntent = Intent(
            Intent.ACTION_DELETE,
            Uri.parse("package:${context!!.packageName}"),
        )
        val handlerPackage = removalIntent.resolveActivity(context!!.packageManager)
            ?.packageName
            ?.takeIf(String::isNotBlank)
            ?: return false
        removalIntent.setPackage(handlerPackage)
        removalIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return runCatching {
            context!!.startActivity(removalIntent)
            stateStore.clearPendingTamperAction()
            true
        }.getOrDefault(false)
    }

    private fun isDeviceAdminActive(): Boolean {
        if (!BuildConfig.SUPPORTS_CONTROLLED_REMOVAL) return false
        val dpm = context!!.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        return runCatching {
            dpm.isAdminActive(
                ComponentName(context!!.packageName, "com.gamblock.gamblock_ai_apps.ProtectionDeviceAdminReceiver"),
            )
        }.getOrDefault(false)
    }

    private fun ensureBackgroundProtection(): Boolean {
        val enabled = isAccessibilityEnabled()
        if (enabled) {
            ProtectionKeepAliveService.start(context!!)
        } else {
            ProtectionKeepAliveService.stop(context!!)
        }
        return enabled
    }

    private fun isAccessibilityEnabled(): Boolean {
        val manager = context!!.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        return manager.getEnabledAccessibilityServiceList(
            AccessibilityServiceInfo.FEEDBACK_ALL_MASK,
        ).any {
            it.resolveInfo.serviceInfo.packageName == context!!.packageName &&
                (it.resolveInfo.serviceInfo.name.contains("AccessibilityService") ||
                    it.resolveInfo.serviceInfo.name.contains("Gamblock"))
        }
    }

    private fun <T> onMain(action: () -> T): T {
        if (Looper.myLooper() == Looper.getMainLooper()) return action()
        val latch = CountDownLatch(1)
        var result: Any? = null
        var thrown: Throwable? = null
        mainHandler.post {
            try {
                result = action()
            } catch (error: Throwable) {
                thrown = error
            }
            latch.countDown()
        }
        if (!latch.await(WAIT_TIMEOUT_MS, TimeUnit.MILLISECONDS)) {
            throw IllegalStateException("protection bridge timed out")
        }
        thrown?.let { throw it }
        @Suppress("UNCHECKED_CAST")
        return result as T
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?,
    ): Cursor? = null

    override fun getType(uri: Uri): String? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<out String>?,
    ): Int = 0
}
