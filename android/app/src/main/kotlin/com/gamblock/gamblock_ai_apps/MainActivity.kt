package com.gamblock.gamblock_ai_apps

import android.accessibilityservice.AccessibilityServiceInfo
import android.Manifest
import android.app.AlertDialog
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
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

        @Volatile
        private var flutterPresentationAvailable = false

        fun isFlutterPresentationAvailable(): Boolean = flutterPresentationAvailable
    }

    private val worker = Executors.newSingleThreadExecutor()
    private lateinit var classifier: HybridClassifier
    private lateinit var aggregates: DailyAggregateStore
    private lateinit var stateStore: ProtectionStateStore
    private lateinit var consentStore: AccessibilityConsentStore
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterPresentationAvailable = true
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
                // EventChannel listeners are created after a cold Flutter
                // engine starts. Replay only durable pending actions and keep
                // their original IDs so Dart can deduplicate safely.
                stateStore.activeIntervention()?.event()?.let(NativeEventBus::emit)
                stateStore.pendingApprovalEvent()?.let(NativeEventBus::emit)
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
                        if (isAccessibilityEnabled()) {
                            ProtectionKeepAliveService.start(this)
                        }
                    } else {
                        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                        manager.cancel(BrowserProtectionAccessibilityService.NOTIFICATION_ID)
                        ProtectionKeepAliveService.stop(this)
                    }
                    result.success(true)
                }
                "ensureBackgroundProtection" -> {
                    val enabled = isAccessibilityEnabled()
                    if (enabled) {
                        ProtectionKeepAliveService.start(this)
                    } else {
                        ProtectionKeepAliveService.stop(this)
                    }
                    result.success(enabled)
                }
                "requestBatteryOptimizationExemption" -> {
                    result.success(requestBatteryOptimizationExemption())
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
                "ackInterventionVisible" -> {
                    val interventionId = call.argument<String>("intervention_id").orEmpty()
                    val claim = stateStore.claimFlutterVisibility(interventionId)
                    if (claim.accepted) {
                        BrowserProtectionAccessibilityService.notifyFlutterVisibilityClaimed(
                            interventionId,
                        )
                    }
                    if (claim.newlyVisible) {
                        aggregates.increment("intervention_shown")
                    }
                    result.success(claim.accepted)
                }
                "completeIntervention" -> {
                    val interventionId = call.argument<String>("intervention_id").orEmpty()
                    val completed = stateStore.completeIntervention(interventionId)
                    if (completed) {
                        BrowserProtectionAccessibilityService.notifyInterventionCompleted(
                            interventionId,
                        )
                    }
                    result.success(completed)
                }
                "beginApprovedRemoval" -> result.success(beginApprovedRemoval())
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
    }

    override fun onDestroy() {
        flutterPresentationAvailable = false
        NativeEventBus.remove(eventSink)
        if (!isChangingConfigurations && ::stateStore.isInitialized) {
            stateStore.activeIntervention()?.let { pending ->
                val released = stateStore.releaseFlutterOwnershipForReplay(pending.id)
                if (released != null) {
                    BrowserProtectionAccessibilityService.notifyFlutterPresentationLost(
                        released.id,
                    )
                }
            }
        }
        worker.shutdownNow()
        super.onDestroy()
    }

    private fun snapshot(): Map<String, Any?> {
        val enabled = isAccessibilityEnabled()
        val serviceBound = BrowserProtectionAccessibilityService.isRunning()
        val storedStatus = stateStore.status()
        val status = when {
            !enabled -> "inactive"
            !serviceBound -> "inactive"
            stateStore.activeGrantAllowsProtectionPause() -> "paused"
            storedStatus == "degraded" -> "degraded"
            else -> "active"
        }
        val degradedReason = when {
            !enabled -> "accessibility_disabled"
            !serviceBound -> "service_not_running"
            status == "degraded" -> stateStore.degradedReason()
            else -> null
        }
        val isHealthy = enabled && serviceBound && status != "degraded"
        return mapOf(
            "platform" to "android",
            "status" to status,
            "service_running" to (enabled && serviceBound),
            "sensor_status" to if (isHealthy) "connected" else if (enabled) "degraded" else "disconnected",
            "permission_status" to if (enabled) "granted" else "revoked",
            "model_version" to classifier.modelVersion,
            "ruleset_version" to classifier.rulesetVersion,
            "supports_controlled_removal" to BuildConfig.SUPPORTS_CONTROLLED_REMOVAL,
            "degraded_reason_code" to degradedReason,
            "last_event_at" to stateStore.lastEventAt(),
        )
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

    private fun beginApprovedRemoval(): Boolean {
        if (!BuildConfig.SUPPORTS_CONTROLLED_REMOVAL) return false
        if (!stateStore.activeGrantAllowsControlledRemoval()) return false
        val removalIntent = Intent(
            Intent.ACTION_DELETE,
            Uri.parse("package:$packageName"),
        )
        val handlerPackage = removalIntent.resolveActivity(packageManager)
            ?.packageName
            ?.takeIf(String::isNotBlank)
            ?: return false
        removalIntent.setPackage(handlerPackage)
        return runCatching {
            startActivity(removalIntent)
            stateStore.clearPendingTamperAction()
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
