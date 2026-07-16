package com.gamblock.gamblock_ai_apps

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.security.MessageDigest

data class ClassificationInput(
    val url: String,
    val title: String,
    val headings: List<String>,
    val anchorTexts: List<String>,
)

data class ClassificationResult(
    val decision: String,
    val ruleScore: Double,
    val modelScore: Double,
    val reasonCode: String,
    val modelVersion: String,
    val rulesetVersion: String,
)

class HybridClassifier(private val context: Context) {
    companion object {
        const val CONTRACT_VERSION = "hybrid-v1"
        const val DEFAULT_MODEL_VERSION = "dummy-lr-v1"
        const val DEFAULT_RULESET_VERSION = "dummy-rules-v1"
        const val MODEL_THRESHOLD = 0.72
        private const val ASSET_ROOT = "flutter_assets/assets/protection"
    }

    private var bias = -3.2
    private var threshold = MODEL_THRESHOLD
    private var weights = emptyMap<String, Double>()
    private var strongPatterns = emptyList<String>()
    private var mediumPatterns = emptyList<String>()
    private var strongScore = 0.95
    private var mediumScore = 0.65

    @Volatile
    var modelVersion: String = DEFAULT_MODEL_VERSION
        private set

    @Volatile
    var rulesetVersion: String = DEFAULT_RULESET_VERSION
        private set

    @Synchronized
    fun load(): Boolean {
        val modelFile = File(context.filesDir, "protection/model.json")
        val rulesFile = File(context.filesDir, "protection/rules.json")
        if (modelFile.isFile && rulesFile.isFile) {
            try {
                applyArtifacts(
                    JSONObject(modelFile.readText()),
                    JSONObject(rulesFile.readText()),
                )
                if (fixtureFailures().length() == 0) return true
            } catch (_: Exception) {
                // Retain the bundled last-known-good pair below.
            }
        }
        return try {
            require(verifyBundledIntegrity())
            val model = JSONObject(
                context.assets.open("$ASSET_ROOT/dummy-lr-v1.json")
                    .bufferedReader()
                    .use { it.readText() },
            )
            val rules = JSONObject(
                context.assets.open("$ASSET_ROOT/dummy-rules-v1.json")
                    .bufferedReader()
                    .use { it.readText() },
            )
            applyArtifacts(model, rules)
            fixtureFailures().length() == 0
        } catch (_: Exception) {
            false
        }
    }

    private fun applyArtifacts(model: JSONObject, rules: JSONObject) {
            require(model.optString("contract_version") == CONTRACT_VERSION)
            require(rules.optString("contract_version") == CONTRACT_VERSION)
            bias = model.getDouble("bias")
            threshold = model.optDouble("threshold", MODEL_THRESHOLD)
            modelVersion = model.getString("version")
            rulesetVersion = rules.getString("version")
            weights = model.getJSONObject("weights").keys().asSequence().associateWith {
                model.getJSONObject("weights").getDouble(it)
            }
            strongPatterns = rules.getJSONArray("strong_url_patterns").toStringList()
            mediumPatterns = rules.getJSONArray("medium_url_patterns").toStringList()
            strongScore = rules.optDouble("strong_score", 0.95)
            mediumScore = rules.optDouble("medium_score", 0.65)
    }

    fun classify(raw: ClassificationInput): ClassificationResult {
        return HybridDecisionEngine.classify(
            raw = raw,
            bias = bias,
            threshold = threshold,
            weights = weights,
            strongPatterns = strongPatterns,
            mediumPatterns = mediumPatterns,
            strongScore = strongScore,
            mediumScore = mediumScore,
            modelVersion = modelVersion,
            rulesetVersion = rulesetVersion,
        )
    }

    fun runSelfTest(): JSONObject {
        val failures = fixtureFailures()
        val integrity = verifyBundledIntegrity()
        return JSONObject().apply {
            put("passed", failures.length() == 0 && integrity)
            put(
                "reason_code",
                when {
                    !integrity -> "artifact_integrity_failed"
                    failures.length() > 0 -> "fixture_mismatch"
                    else -> "fixtures_passed"
                },
            )
            put("fixture_count", fixtureCount())
            put("failures", failures)
            put("model_version", modelVersion)
            put("ruleset_version", rulesetVersion)
        }
    }

    private fun fixtureFailures(): JSONArray {
        val fixtureText = context.assets.open("$ASSET_ROOT/hybrid-v1-fixtures.json")
            .bufferedReader()
            .use { it.readText() }
        val fixtures = JSONArray(fixtureText)
        val failures = JSONArray()
        for (index in 0 until fixtures.length()) {
            val fixture = fixtures.getJSONObject(index)
            val result = classify(
                ClassificationInput(
                    url = fixture.optString("url"),
                    title = fixture.optString("title"),
                    headings = fixture.optJSONArray("headings")?.toStringList() ?: emptyList(),
                    anchorTexts = fixture.optJSONArray("anchorTexts")?.toStringList() ?: emptyList(),
                ),
            )
            if (result.decision != fixture.getString("expected")) {
                failures.put(fixture.getString("name"))
            }
        }
        return failures
    }

    private fun fixtureCount(): Int {
        val fixtureText = context.assets.open("$ASSET_ROOT/hybrid-v1-fixtures.json")
            .bufferedReader()
            .use { it.readText() }
        return JSONArray(fixtureText).length()
    }

    private fun verifyBundledIntegrity(): Boolean {
        return try {
            val manifest = JSONObject(
                context.assets.open("$ASSET_ROOT/manifest.json")
                    .bufferedReader()
                    .use { it.readText() },
            )
            verifyAsset(
                "$ASSET_ROOT/dummy-lr-v1.json",
                manifest.getJSONObject("model").getString("sha256"),
            ) && verifyAsset(
                "$ASSET_ROOT/dummy-rules-v1.json",
                manifest.getJSONObject("ruleset").getString("sha256"),
            ) && verifyAsset(
                "$ASSET_ROOT/hybrid-v1-fixtures.json",
                manifest.getJSONObject("fixtures").getString("sha256"),
            )
        } catch (_: Exception) {
            false
        }
    }

    private fun verifyAsset(path: String, expected: String): Boolean {
        val bytes = context.assets.open(path).use { it.readBytes() }
        return bytes.sha256() == expected.lowercase()
    }

}

private fun JSONArray.toStringList(): List<String> {
    return List(length()) { index -> optString(index) }
}

private fun ByteArray.sha256(): String {
    return MessageDigest.getInstance("SHA-256")
        .digest(this)
        .joinToString("") { "%02x".format(it) }
}
