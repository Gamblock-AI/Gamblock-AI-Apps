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
        const val CONTRACT_VERSION = "hybrid-v2"
        const val DEFAULT_MODEL_VERSION = "gamblock-lr-bfafb725511a"
        const val DEFAULT_RULESET_VERSION = "gambling-keywords-b4f2932a7647"
        private const val ASSET_ROOT = "flutter_assets/assets/protection"
    }

    private var model = HybridModelConfig(
        bias = 0.0,
        mlWeight = 0.75,
        ruleWeight = 0.25,
        threshold = 0.4,
        unigramWeights = emptyMap(),
        bigramWeights = emptyMap(),
        urlFeatures = emptyList(),
    )
    private var rules = HybridRuleConfig(emptyList(), 1.0)

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
                context.assets.open("$ASSET_ROOT/gamblock-lr-v2.json")
                    .bufferedReader()
                    .use { it.readText() },
            )
            val rules = JSONObject(
                context.assets.open("$ASSET_ROOT/gamblock-rules-v2.json")
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
        val unigramWeights = model.getJSONObject("unigram_weights").toDoubleMap()
        val bigramWeights = model.getJSONObject("bigram_weights").toDoubleMap()
        val features = model.getJSONArray("url_features")
        val urlFeatures = List(features.length()) { index ->
            val feature = features.getJSONObject(index)
            UrlFeatureSpec(
                name = feature.getString("name"),
                offset = feature.getDouble("offset"),
                scale = feature.getDouble("scale"),
                weight = feature.getDouble("weight"),
            )
        }
        require(unigramWeights.isNotEmpty() && bigramWeights.isNotEmpty())
        require(urlFeatures.size == 14)
        this.model = HybridModelConfig(
            bias = model.getDouble("bias"),
            mlWeight = model.getDouble("ml_weight"),
            ruleWeight = model.getDouble("rule_weight"),
            threshold = model.getDouble("threshold"),
            unigramWeights = unigramWeights,
            bigramWeights = bigramWeights,
            urlFeatures = urlFeatures,
        )
        this.rules = HybridRuleConfig(
            keywords = rules.getJSONArray("keywords").toStringList(),
            matchScore = rules.getDouble("match_score"),
        )
        require(this.rules.keywords.isNotEmpty())
        modelVersion = model.getString("version")
        rulesetVersion = rules.getString("version")
    }

    @Synchronized
    fun classify(raw: ClassificationInput): ClassificationResult {
        return HybridDecisionEngine.classify(
            raw = raw,
            model = model,
            rules = rules,
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
        val fixtureText = context.assets.open("$ASSET_ROOT/hybrid-v2-fixtures.json")
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
        val fixtureText = context.assets.open("$ASSET_ROOT/hybrid-v2-fixtures.json")
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
                "$ASSET_ROOT/gamblock-lr-v2.json",
                manifest.getJSONObject("model").getString("sha256"),
            ) && verifyAsset(
                "$ASSET_ROOT/gamblock-rules-v2.json",
                manifest.getJSONObject("ruleset").getString("sha256"),
            ) && verifyAsset(
                "$ASSET_ROOT/hybrid-v2-fixtures.json",
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

private fun JSONObject.toDoubleMap(): Map<String, Double> {
    val values = mutableMapOf<String, Double>()
    val iterator = keys()
    while (iterator.hasNext()) {
        val key = iterator.next()
        values[key] = getDouble(key)
    }
    return values
}

private fun ByteArray.sha256(): String {
    return MessageDigest.getInstance("SHA-256")
        .digest(this)
        .joinToString("") { "%02x".format(it) }
}
