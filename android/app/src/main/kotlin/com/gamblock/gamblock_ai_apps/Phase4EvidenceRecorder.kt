package com.gamblock.gamblock_ai_apps

import android.content.Context
import org.json.JSONObject
import java.io.File
import java.util.concurrent.atomic.AtomicLong

data class Phase4LatencySample(
    val scanStartedNanos: Long,
    val inputReadyNanos: Long,
    val classificationStartedNanos: Long,
    val classificationFinishedNanos: Long,
    val visibleNanos: Long,
    val modelVersion: String,
    val rulesetVersion: String,
)

/**
 * Opt-in, device-local Phase 4 timing evidence.
 *
 * The recorder is disabled unless a completed config exists in the app's
 * private files directory. Records intentionally contain no URL, DOM, score,
 * reason code, wall-clock browsing timestamp, or account/device identifier.
 */
class Phase4EvidenceRecorder(context: Context) {
    companion object {
        private const val MAX_EVIDENCE_BYTES = 5L * 1024L * 1024L
        private val safeLabel = Regex("^[A-Za-z0-9_-]{1,64}$")
        private val sequence = AtomicLong(0)
    }

    private val directory = File(context.filesDir, "phase4-evidence")
    private val configFile = File(directory, "config.json")
    private val latencyFile = File(directory, "latency.jsonl")

    @Synchronized
    fun recordLatency(sample: Phase4LatencySample) {
        val config = readConfig() ?: return
        runCatching {
            if (latencyFile.isFile && latencyFile.length() >= MAX_EVIDENCE_BYTES) return
            directory.mkdirs()
            val nanosPerMillisecond = 1_000_000.0
            val record = JSONObject().apply {
                put("schema_version", 1)
                put("platform", "android")
                put("run_id", config.getString("run_id"))
                put(
                    "sample_id",
                    "android_${sample.visibleNanos}_${sequence.incrementAndGet()}",
                )
                put("device_alias", config.getString("device_alias"))
                put("scenario", config.getString("scenario"))
                put("model_version", sample.modelVersion)
                put("ruleset_version", sample.rulesetVersion)
                put(
                    "extraction_ms",
                    (sample.inputReadyNanos - sample.scanStartedNanos) / nanosPerMillisecond,
                )
                put(
                    "queue_ms",
                    (sample.classificationStartedNanos - sample.inputReadyNanos) /
                        nanosPerMillisecond,
                )
                put(
                    "classification_ms",
                    (sample.classificationFinishedNanos - sample.classificationStartedNanos) /
                        nanosPerMillisecond,
                )
                put(
                    "dispatch_to_visible_ms",
                    (sample.visibleNanos - sample.classificationFinishedNanos) /
                        nanosPerMillisecond,
                )
                put(
                    "input_to_visible_ms",
                    (sample.visibleNanos - sample.inputReadyNanos) / nanosPerMillisecond,
                )
                put(
                    "scan_to_visible_ms",
                    (sample.visibleNanos - sample.scanStartedNanos) / nanosPerMillisecond,
                )
            }
            latencyFile.appendText(record.toString() + "\n")
        }
    }

    private fun readConfig(): JSONObject? {
        if (!configFile.isFile) return null
        return runCatching { JSONObject(configFile.readText()) }
            .getOrNull()
            ?.takeIf { config ->
                config.optBoolean("enabled", false) &&
                    safeLabel.matches(config.optString("run_id")) &&
                    safeLabel.matches(config.optString("device_alias")) &&
                    safeLabel.matches(config.optString("scenario"))
            }
    }
}
