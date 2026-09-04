package com.gamblock.gamblock_ai_apps

import android.content.Context
import org.json.JSONObject
import java.io.File
import java.util.concurrent.atomic.AtomicLong

data class Phase4LatencyStart(
    val scanStartedNanos: Long,
    val inputReadyNanos: Long,
    val classificationStartedNanos: Long,
    val classificationFinishedNanos: Long,
    val timings: ClassificationTimings,
    val modelVersion: String,
    val rulesetVersion: String,
)

/**
 * Opt-in, device-local Phase 4 timing evidence.
 *
 * A sample starts only after a new positive decision allocates an opaque
 * intervention ID. It completes only after the accepted blocking action and
 * the first visible Pattern Interrupt frame. Records intentionally contain no
 * URL, DOM, score, reason code, wall-clock browsing timestamp, or account ID.
 */
class Phase4EvidenceRecorder(context: Context) {
    companion object {
        private const val MAX_EVIDENCE_BYTES = 5L * 1024L * 1024L
        private const val MAX_PENDING_SAMPLES = 256
        private const val PENDING_TTL_NANOS = 120L * 1_000_000_000L
        private val safeLabel = Regex("^[A-Za-z0-9_-]{1,64}$")
        private val sequence = AtomicLong(0)
    }

    private data class Config(
        val runId: String,
        val deviceAlias: String,
        val scenario: String,
        val browserFamily: String,
        val buildMode: String,
    )

    private data class PendingSample(
        val config: Config,
        val start: Phase4LatencyStart,
        var blockActionStartedNanos: Long? = null,
        var blockActionFinishedNanos: Long? = null,
        var blockSucceeded: Boolean? = null,
    )

    private val directory = File(context.filesDir, "phase4-evidence")
    private val configFile = File(directory, "config.json")
    private val latencyFile = File(directory, "latency.jsonl")
    private val pending = LinkedHashMap<String, PendingSample>()

    @Synchronized
    fun begin(interventionId: String, start: Phase4LatencyStart) {
        val config = readConfig() ?: return
        if (interventionId.isBlank()) return
        prune(start.classificationFinishedNanos)
        if (pending.size >= MAX_PENDING_SAMPLES || pending.containsKey(interventionId)) return
        pending[interventionId] = PendingSample(config, start)
    }

    @Synchronized
    fun recordBlockAction(
        interventionId: String,
        startedNanos: Long,
        finishedNanos: Long,
        succeeded: Boolean,
    ) {
        val sample = pending[interventionId] ?: return
        sample.blockActionStartedNanos = startedNanos
        sample.blockActionFinishedNanos = finishedNanos
        sample.blockSucceeded = succeeded
    }

    @Synchronized
    fun complete(interventionId: String, visibleNanos: Long, presentationPath: String) {
        val sample = pending.remove(interventionId) ?: return
        write(
            sample = sample,
            outcome = if (sample.blockSucceeded == true) "visible" else "block_failed",
            presentationPath = presentationPath,
            visibleNanos = visibleNanos,
        )
    }

    @Synchronized
    fun fail(interventionId: String, outcome: String) {
        val sample = pending.remove(interventionId) ?: return
        write(sample, outcome, "none", null)
    }

    private fun prune(nowNanos: Long) {
        val iterator = pending.iterator()
        while (iterator.hasNext()) {
            val (_, sample) = iterator.next()
            if (nowNanos - sample.start.inputReadyNanos > PENDING_TTL_NANOS) {
                write(sample, "expired", "none", null)
                iterator.remove()
            }
        }
    }

    private fun write(
        sample: PendingSample,
        outcome: String,
        presentationPath: String,
        visibleNanos: Long?,
    ) {
        runCatching {
            if (latencyFile.isFile && latencyFile.length() >= MAX_EVIDENCE_BYTES) return
            directory.mkdirs()
            val nanosPerMillisecond = 1_000_000.0
            fun duration(start: Long, end: Long?) = end?.let {
                ((it - start).coerceAtLeast(0)) / nanosPerMillisecond
            }
            val record = JSONObject().apply {
                put("schema_version", 3)
                put("platform", "android")
                put("run_id", sample.config.runId)
                put("sample_id", "android_${sequence.incrementAndGet()}")
                put("device_alias", sample.config.deviceAlias)
                put("scenario", sample.config.scenario)
                put("browser_family", sample.config.browserFamily)
                put("build_mode", sample.config.buildMode)
                put("product_flavor", BuildConfig.FLAVOR)
                put("model_version", sample.start.modelVersion)
                put("ruleset_version", sample.start.rulesetVersion)
                put("outcome", outcome)
                put("presentation_path", presentationPath)
                put("block_succeeded", sample.blockSucceeded == true)
                put(
                    "extraction_ms",
                    duration(sample.start.scanStartedNanos, sample.start.inputReadyNanos),
                )
                put(
                    "queue_ms",
                    duration(sample.start.inputReadyNanos, sample.start.classificationStartedNanos),
                )
                put("preprocessing_ms", sample.start.timings.preprocessingNanos / nanosPerMillisecond)
                put("rule_ms", sample.start.timings.ruleNanos / nanosPerMillisecond)
                put("inference_ms", sample.start.timings.inferenceNanos / nanosPerMillisecond)
                put("decision_ms", sample.start.timings.decisionNanos / nanosPerMillisecond)
                put(
                    "classification_ms",
                    duration(sample.start.classificationStartedNanos, sample.start.classificationFinishedNanos),
                )
                duration(sample.blockActionStartedNanos ?: 0, sample.blockActionFinishedNanos)
                    ?.let { put("block_action_ms", it) }
                if (visibleNanos != null) {
                    put(
                        "dispatch_to_visible_ms",
                        duration(sample.start.classificationFinishedNanos, visibleNanos),
                    )
                    put(
                        "input_to_visible_ms",
                        duration(sample.start.inputReadyNanos, visibleNanos),
                    )
                    put(
                        "scan_to_visible_ms",
                        duration(sample.start.scanStartedNanos, visibleNanos),
                    )
                }
            }
            latencyFile.appendText(record.toString() + "\n")
        }
    }

    private fun readConfig(): Config? {
        if (!configFile.isFile) return null
        return runCatching { JSONObject(configFile.readText()) }
            .getOrNull()
            ?.takeIf { config ->
                config.optBoolean("enabled", false) &&
                    safeLabel.matches(config.optString("run_id")) &&
                    safeLabel.matches(config.optString("device_alias")) &&
                    safeLabel.matches(config.optString("scenario")) &&
                    safeLabel.matches(config.optString("browser_family")) &&
                    safeLabel.matches(config.optString("build_mode")) &&
                    config.optString("build_mode") == BuildConfig.BUILD_TYPE
            }
            ?.let {
                Config(
                    it.getString("run_id"),
                    it.getString("device_alias"),
                    it.getString("scenario"),
                    it.getString("browser_family"),
                    it.getString("build_mode"),
                )
            }
    }
}
