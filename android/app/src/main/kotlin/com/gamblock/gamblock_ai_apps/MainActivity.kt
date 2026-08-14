package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityServiceInfo
import android.Manifest
import android.app.AlertDialog
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    companion object {
        private const val METHOD_CHANNEL = "com.gamblock/protection"
        private const val EVENT_CHANNEL = "com.gamblock/intervention"
    }

    private val worker = Executors.newSingleThreadExecutor()
    private lateinit var classifier: HybridClassifier
    private lateinit var aggregates: DailyAggregateStore
    private lateinit var stateStore: ProtectionStateStore
    private lateinit var consentStore: AccessibilityConsentStore
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        classifier = HybridClassifier(applicationContext)
        // Model parsing + SHA-256 integrity verification are heavy; run them
        // on the single worker so later tasks (e.g. runLocalSelfTest) start
        // only after the load finishes, while startup stays responsive.
        worker.execute {
            classifier.load()
        }
        aggregates = DailyAggregateStore(applicationContext)
        stateStore = ProtectionStateStore(applicationContext)
        consentStore = AccessibilityConsentStore(applicationContext)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL,
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                eventSink = events
                NativeEventBus.add(events)
            }

            override fun onCancel(arguments: Any?) {
                NativeEventBus.remove(eventSink)
                eventSink = null
            }
        })

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getProtectionSnapshot" -> result.success(snapshot())
                "openPlatformSetup" -> openAccessibilitySetupWithDisclosure(result)
                "runLocalSelfTest" -> background(result) {
                    jsonToFlutter(classifier.runSelfTest())
                }
                "setHealthNotifications" -> {
                    val enabled = call.argument<Boolean>("enabled") == true
                    HealthNotificationPreferences.setEnabled(this, enabled)
                    if (enabled) {
                        requestNotificationPermissionIfNeeded()
                        HealthNotificationPreferences.show(this)
                    } else {
                        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                        manager.cancel(BrowserProtectionAccessibilityService.NOTIFICATION_ID)
                    }
                    result.success(true)
                }
                "setDeviceId" -> {
                    result.success(
                        stateStore.setDeviceId(call.argument<String>("device_id").orEmpty()),
                    )
                }
                "getGrantKeyEnrollment" -> background(result) {
                    val deviceId = call.argument<String>("device_id").orEmpty()
                    val challengeToken = call.argument<String>("challenge_token").orEmpty()
                    stateStore.grantKeyEnrollment(deviceId, challengeToken)
                }
                "recordInterventionCommitted" -> result.success(true)
                "drainDailyAggregates" -> result.success(aggregates.completedDays())
                "getCurrentDailyAggregates" -> result.success(aggregates.currentDay())
                "ackDailyAggregates" -> {
                    aggregates.acknowledge(call.argument<List<String>>("keys") ?: emptyList())
                    result.success(null)
                }
                "storeProtectionGrant" -> {
                    val grantToken = call.argument<String>("grant_token").orEmpty()
                    if (grantToken.isBlank()) {
                        result.success(false)
                    } else {
                        background(result) { stateStore.storeGrant(grantToken) }
                    }
                }
                "getPairingToken", "rotatePairingToken" -> result.success(null)
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getBooleanExtra("open_approval", false)) {
            NativeEventBus.emit(mapOf("type" to "approval_required"))
        }
    }

    override fun onResume() {
        super.onResume()
        if (intent.getBooleanExtra("open_approval", false)) {
            NativeEventBus.emit(mapOf("type" to "approval_required"))
            intent.removeExtra("open_approval")
        }
    }

    override fun onDestroy() {
        NativeEventBus.remove(eventSink)
        worker.shutdownNow()
        super.onDestroy()
    }

    private fun snapshot(): Map<String, Any?> {
        val enabled = isAccessibilityEnabled()
        val status = when {
            !enabled -> "inactive"
            stateStore.activeGrantAllowsProtectionPause() -> "paused"
            else -> stateStore.status()
        }
        return mapOf(
            "platform" to "android",
            "status" to status,
            "service_running" to enabled,
            "sensor_status" to if (enabled) "connected" else "disconnected",
            "permission_status" to if (enabled) "granted" else "revoked",
            "model_version" to classifier.modelVersion,
            "ruleset_version" to classifier.rulesetVersion,
            "degraded_reason_code" to if (enabled) stateStore.degradedReason() else "accessibility_disabled",
            "last_event_at" to stateStore.lastEventAt(),
        )
    }

    private fun isAccessibilityEnabled(): Boolean {
        val manager = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        return manager.getEnabledAccessibilityServiceList(
            AccessibilityServiceInfo.FEEDBACK_ALL_MASK,
        ).any {
            it.resolveInfo.serviceInfo.packageName == packageName &&
                it.resolveInfo.serviceInfo.name.contains("GamblockAccessibilityService")
        }
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
        is JSONObject -> value.keys().asSequence().associateWith { jsonToFlutter(value.opt(it)) }
        is JSONArray -> (0 until value.length()).map { jsonToFlutter(value.opt(it)) }
        JSONObject.NULL -> null
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
