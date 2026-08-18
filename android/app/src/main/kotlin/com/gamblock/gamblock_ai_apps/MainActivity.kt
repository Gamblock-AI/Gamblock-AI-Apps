package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityServiceInfo
import android.Manifest
import android.app.AlertDialog
import android.app.NotificationManager
import android.app.admin.DevicePolicyManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Binder
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    companion object {
        private const val METHOD_CHANNEL = "com.gamblock/protection"
        private const val EVENT_CHANNEL = "com.gamblock/intervention"
    }

    private val worker = Executors.newSingleThreadExecutor()
    private lateinit var classifier: HybridClassifier
    private lateinit var consentStore: AccessibilityConsentStore
    private var eventSink: EventChannel.EventSink? = null
    private var protectionReceiver: BroadcastReceiver? = null
    private val uiToken = Binder()

    private fun bridgeUri(): Uri {
        return Uri.parse("content://${packageName}.protection.bridge")
    }

    private fun bridgeCall(method: String, arg: String?, extras: Bundle?): Bundle? {
        return try {
            contentResolver.call(bridgeUri(), method, arg, extras)
        } catch (_: Exception) {
            null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        classifier = HybridClassifier(applicationContext)
        // Model parsing + SHA-256 integrity verification are heavy; run them
        // on the single worker so later tasks (e.g. runLocalSelfTest) start
        // only after the load finishes, while startup stays responsive.
        worker.execute {
            classifier.load()
        }
        consentStore = AccessibilityConsentStore(applicationContext)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL,
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                eventSink = events
                if (protectionReceiver == null) {
                    protectionReceiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context?, intent: Intent?) {
                            val map = ProtectionBridge.bundleToMap(intent?.extras)
                            eventSink?.success(map)
                        }
                    }
                    ContextCompat.registerReceiver(
                        this@MainActivity,
                        protectionReceiver!!,
                        IntentFilter(ProtectionBridge.ACTION_EVENT),
                        ContextCompat.RECEIVER_NOT_EXPORTED,
                    )
                }
                bridgeCall(
                    "register_ui",
                    null,
                    Bundle().apply { putBinder("token", uiToken) },
                )
                // Replay only durable pending actions and keep their original
                // IDs so Dart can deduplicate safely.
                bridgeCall("get_pending_events", null, null)
                    ?.getParcelableArrayList<Bundle>("events")
                    ?.forEach { events.success(ProtectionBridge.bundleToMap(it)) }
            }

            override fun onCancel(arguments: Any?) {
                bridgeCall("unregister_ui", null, null)
                protectionReceiver?.let {
                    runCatching { unregisterReceiver(it) }
                }
                protectionReceiver = null
                eventSink = null
            }
        })

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getProtectionSnapshot" -> background(result) { localSnapshot() }
                "openPlatformSetup" -> openAccessibilitySetupWithDisclosure(result)
                "runLocalSelfTest" -> background(result) {
                    jsonToFlutter(classifier.runSelfTest())
                }
                "setHealthNotifications" -> background(result) {
                    val enabled = call.argument<Boolean>("enabled") == true
                    HealthNotificationPreferences.setEnabled(this@MainActivity, enabled)
                    if (enabled) {
                        requestNotificationPermissionIfNeeded()
                        HealthNotificationPreferences.show(this@MainActivity)
                        bridgeCall("ensure_background_protection", null, null)
                    } else {
                        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                        manager.cancel(BrowserProtectionAccessibilityService.NOTIFICATION_ID)
                        bridgeCall("ensure_background_protection", null, null)
                    }
                    true
                }
                "ensureBackgroundProtection" -> background(result) {
                    bridgeCall("ensure_background_protection", null, null)
                        ?.getBoolean("value", false) ?: false
                }
                "requestBatteryOptimizationExemption" -> {
                    result.success(requestBatteryOptimizationExemption())
                }
                "getDeviceAdminStatus" -> background(result) {
                    isDeviceAdminActive()
                }
                "requestDeviceAdminActivation" -> {
                    result.success(requestDeviceAdminActivation())
                }
                "setDeviceId" -> background(result) {
                    bridgeCall("set_device_id", call.argument<String>("device_id").orEmpty(), null)
                        ?.getBoolean("value", false) ?: false
                }
                "getGrantKeyEnrollment" -> background(result) {
                    val deviceId = call.argument<String>("device_id").orEmpty()
                    val challengeToken = call.argument<String>("challenge_token").orEmpty()
                    val bundle = bridgeCall(
                        "grant_key_enrollment",
                        null,
                        Bundle().apply {
                            putString("device_id", deviceId)
                            putString("challenge_token", challengeToken)
                        },
                    ) ?: return@background null
                    mapOf(
                        "public_jwk" to (bundle.getString("public_jwk") ?: ""),
                        "jwk_thumbprint" to (bundle.getString("jwk_thumbprint") ?: ""),
                        "proof" to (bundle.getString("proof") ?: ""),
                    )
                }
                "ackInterventionVisible" -> background(result) {
                    bridgeCall(
                        "ack_intervention_visible",
                        call.argument<String>("intervention_id").orEmpty(),
                        null,
                    )?.getBoolean("value", false) ?: false
                }
                "completeIntervention" -> background(result) {
                    bridgeCall(
                        "complete_intervention",
                        call.argument<String>("intervention_id").orEmpty(),
                        null,
                    )?.getBoolean("value", false) ?: false
                }
                "beginApprovedRemoval" -> background(result) {
                    bridgeCall("begin_approved_removal", null, null)
                        ?.getBoolean("value", false) ?: false
                }
                "drainDailyAggregates" -> background(result) {
                    bridgeAggregateRows("drain_daily_aggregates")
                }
                "getCurrentDailyAggregates" -> background(result) {
                    bridgeAggregateRows("get_current_daily_aggregates")
                }
                "ackDailyAggregates" -> background(result) {
                    bridgeCall(
                        "ack_daily_aggregates",
                        null,
                        Bundle().apply {
                            putStringArrayList(
                                "keys",
                                ArrayList(call.argument<List<String>>("keys") ?: emptyList()),
                            )
                        },
                    )
                    null
                }
                "storeProtectionGrant" -> background(result) {
                    val grantToken = call.argument<String>("grant_token").orEmpty()
                    if (grantToken.isBlank()) {
                        false
                    } else {
                        bridgeCall("store_grant", grantToken, null)
                            ?.getBoolean("value", false) ?: false
                    }
                }
                "getPairingToken", "rotatePairingToken" -> result.success(null)
                else -> result.notImplemented()
            }
        }
    }

    private fun bridgeAggregateRows(method: String): List<Map<String, Any?>> {
        val bundle = bridgeCall(method, null, null) ?: return emptyList()
        return bundle.getParcelableArrayList<Bundle>("rows")
            ?.map(ProtectionBridge::bundleToMap)
            ?: emptyList()
    }

    private fun localSnapshot(): Map<String, Any?> {
        val bridgeSnapshot = bridgeCall("get_snapshot", null, null)
        if (bridgeSnapshot != null) return ProtectionBridge.bundleToMap(bridgeSnapshot)
        // Protection process unreachable: report the truthful local view.
        val enabled = isAccessibilityEnabled()
        return mapOf(
            "platform" to "android",
            "status" to "inactive",
            "service_running" to false,
            "sensor_status" to "disconnected",
            "permission_status" to if (enabled) "granted" else "revoked",
            "model_version" to classifier.modelVersion,
            "ruleset_version" to classifier.rulesetVersion,
            "supports_controlled_removal" to BuildConfig.SUPPORTS_CONTROLLED_REMOVAL,
            "device_admin_active" to isDeviceAdminActive(),
            "degraded_reason_code" to if (enabled) "service_not_running" else "accessibility_disabled",
            "last_event_at" to null,
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntentEvents(intent)
    }

    override fun onResume() {
        super.onResume()
        handleIntentEvents(intent)
    }

    private fun handleIntentEvents(incomingIntent: Intent?) {
        val action = incomingIntent?.getStringExtra("approval_action")?.takeIf { it.isNotBlank() }
        if (action != null) {
            incomingIntent.removeExtra("approval_action")
            val event = mapOf(
                "type" to "approval_required",
                "tamper_action" to action,
                "action_id" to (incomingIntent.getStringExtra("approval_id") ?: java.util.UUID.randomUUID().toString()),
            )
            runOnUiThread { eventSink?.success(event) }
        } else {
            worker.execute {
                val pending = bridgeCall("get_pending_events", null, null)
                    ?.getParcelableArrayList<Bundle>("events")
                if (!pending.isNullOrEmpty()) {
                    runOnUiThread {
                        pending.forEach { eventSink?.success(ProtectionBridge.bundleToMap(it)) }
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        protectionReceiver?.let {
            runCatching { unregisterReceiver(it) }
        }
        protectionReceiver = null
        if (!isChangingConfigurations) {
            bridgeCall("ui_presentation_lost", null, null)
            bridgeCall("unregister_ui", null, null)
        }
        worker.shutdownNow()
        super.onDestroy()
    }

    private fun isAccessibilityEnabled(): Boolean {
        val manager = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        return manager.getEnabledAccessibilityServiceList(
            AccessibilityServiceInfo.FEEDBACK_ALL_MASK,
        ).any {
            it.resolveInfo.serviceInfo.packageName == packageName &&
                (it.resolveInfo.serviceInfo.name.contains("AccessibilityService") ||
                    it.resolveInfo.serviceInfo.name.contains("Gamblock"))
        }
    }

    private fun deviceAdminComponent(): ComponentName {
        return ComponentName(packageName, "com.gamblock.gamblock_ai_apps.ProtectionDeviceAdminReceiver")
    }

    private fun isDeviceAdminActive(): Boolean {
        if (!BuildConfig.SUPPORTS_CONTROLLED_REMOVAL) return false
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        return runCatching { dpm.isAdminActive(deviceAdminComponent()) }.getOrDefault(false)
    }

    private fun requestDeviceAdminActivation(): Boolean {
        if (!BuildConfig.SUPPORTS_CONTROLLED_REMOVAL) return false
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        if (dpm.isAdminActive(deviceAdminComponent())) return true
        return runCatching {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, deviceAdminComponent())
                putExtra(
                    DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                    getString(R.string.device_admin_explanation),
                )
            }
            startActivity(intent)
            true
        }.getOrDefault(false)
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                2001,
            )
        }
    }

    private fun requestBatteryOptimizationExemption(): Boolean {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        if (powerManager.isIgnoringBatteryOptimizations(packageName)) return true
        return runCatching {
            startActivity(
                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                    .setData(Uri.parse("package:$packageName")),
            )
            true
        }.getOrDefault(false)
    }

    private fun openAccessibilitySetupWithDisclosure(result: MethodChannel.Result) {
        if (consentStore.hasCurrentConsent()) {
            startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
            result.success(true)
            return
        }
        var completed = false
        fun complete(value: Boolean) {
            if (completed) return
            completed = true
            result.success(value)
        }
        AlertDialog.Builder(this)
            .setTitle(R.string.accessibility_disclosure_title)
            .setMessage(R.string.accessibility_disclosure_body)
            .setPositiveButton(R.string.accessibility_disclosure_accept) { _, _ ->
                if (consentStore.recordDecision(accepted = true)) {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    complete(true)
                } else {
                    complete(false)
                }
            }
            .setNegativeButton(R.string.accessibility_disclosure_decline) { _, _ ->
                consentStore.recordDecision(accepted = false)
                complete(false)
            }
            .setOnCancelListener {
                consentStore.recordDecision(accepted = false)
                complete(false)
            }
            .show()
    }

    private fun jsonToFlutter(value: Any?): Any? = when (value) {
        is org.json.JSONObject -> value.keys().asSequence().associateWith { jsonToFlutter(value.opt(it)) }
        is org.json.JSONArray -> (0 until value.length()).map { jsonToFlutter(value.opt(it)) }
        org.json.JSONObject.NULL -> null
        else -> value
    }

    private fun background(
        result: MethodChannel.Result,
        action: () -> Any?,
    ) {
        worker.execute {
            try {
                val value = action()
                runOnUiThread { result.success(value) }
            } catch (error: Exception) {
                runOnUiThread {
                    result.error(
                        error.message ?: "native_error",
                        "Native protection action failed",
                        null,
                    )
                }
            }
        }
    }
}
