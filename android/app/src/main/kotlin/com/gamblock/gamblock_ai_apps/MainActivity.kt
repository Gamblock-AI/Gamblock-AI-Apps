package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityServiceInfo
import android.Manifest
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
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        classifier = HybridClassifier(applicationContext).also { it.load() }
        aggregates = DailyAggregateStore(applicationContext)
        stateStore = ProtectionStateStore(applicationContext)

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
                "openPlatformSetup" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                }
                "runLocalSelfTest" -> background(result) {
                    jsonToFlutter(classifier.runSelfTest())
                }
                "checkArtifactUpdates" -> background(result) {
                    val baseUrl = call.argument<String>("base_url")
                        ?: NativeConfig.apiBaseUrl(this)
                    val passed = ArtifactUpdater(this, classifier, aggregates).check(baseUrl)
                    mapOf("checked" to passed)
                }
                "setHealthNotifications" -> {
                    val enabled = call.argument<Boolean>("enabled") == true
                    HealthNotificationPreferences.setEnabled(this, enabled)
                    if (enabled) {
                        requestNotificationPermissionIfNeeded()
                        HealthNotificationPreferences.show(this)
                    } else {
                        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                        manager.cancel(GamblockAccessibilityService.NOTIFICATION_ID)
                    }
                    result.success(true)
                }
                "setDeviceId" -> {
                    stateStore.setDeviceId(call.argument<String>("device_id").orEmpty())
                    result.success(null)
                }
                "drainDailyAggregates" -> result.success(aggregates.completedDays())
                "getCurrentDailyAggregates" -> result.success(aggregates.currentDay())
                "ackDailyAggregates" -> {
                    aggregates.acknowledge(call.argument<List<String>>("keys") ?: emptyList())
                    result.success(null)
                }
                "storeProtectionGrant" -> {
                    val grant = call.argument<Map<String, Any?>>("grant")
                    if (grant == null) {
                        result.success(false)
                    } else {
                        result.success(stateStore.storeGrant(JSONObject(grant)))
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
        val grant = stateStore.activeGrant()
        val status = when {
            !enabled -> "inactive"
            grant != null -> "paused"
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
