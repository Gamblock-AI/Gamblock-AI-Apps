package com.gamblock.gamblock_ai_apps

import java.net.URI
import java.util.Locale
import kotlin.math.exp

private val hybridRuleSeparator = Regex("[^a-z0-9_]+")

private fun normalizeRuleKeyword(value: String): String {
    return value.lowercase(Locale.ROOT).replace(hybridRuleSeparator, " ").trim()
}

data class UrlFeatureSpec(
    val name: String,
    val offset: Double,
    val scale: Double,
    val weight: Double,
)

data class HybridModelConfig(
    val bias: Double,
    val mlWeight: Double,
    val ruleWeight: Double,
    val threshold: Double,
    val unigramWeights: Map<String, Double>,
    val bigramWeights: Map<String, Double>,
    val urlFeatures: List<UrlFeatureSpec>,
)

data class HybridRuleConfig(
    val keywords: List<String>,
    val matchScore: Double,
    val normalizedKeywords: List<String> = keywords.map(::normalizeRuleKeyword),
)

/** Monotonic classifier-stage durations used only by local Phase 4 evidence. */
data class ClassificationTimings(
    val preprocessingNanos: Long,
    val ruleNanos: Long,
    val inferenceNanos: Long,
    val decisionNanos: Long,
)

object HybridDecisionEngine {
    private val tokenRegex = Regex("[a-zA-Z0-9_]+")

    fun classify(
        raw: ClassificationInput,
        model: HybridModelConfig,
        rules: HybridRuleConfig,
        modelVersion: String,
        rulesetVersion: String,
        nowNanos: () -> Long = System::nanoTime,
    ): ClassificationResult {
        val preprocessingStarted = nowNanos()
        val input = bounded(raw)
        val normalizedUrl = normalizeForRules(input.url)
        val document = buildString {
            append(input.title)
            append(' ')
            input.headings.forEach {
                append(it)
                append(' ')
            }
            input.anchorTexts.forEach {
                append(it)
                append(' ')
            }
        }
        val normalizedDocument = normalizeForRules(document)
        val tokens = tokenRegex.findAll(normalizeText(document)).map { it.value }.toList()
        val unigramCounts = tokens.groupingBy { it }.eachCount()
        val bigramCounts = tokens.zipWithNext { left, right -> "$left $right" }
            .groupingBy { it }
            .eachCount()
        val preprocessingFinished = nowNanos()

        val ruleStarted = preprocessingFinished
        val urlKeywordCount = rules.normalizedKeywords.count { keyword ->
            containsPhrase(normalizedUrl, keyword)
        }
        val normalizedRuleInput = "$normalizedUrl $normalizedDocument".trim()
        val hasRuleMatch = rules.normalizedKeywords.any { keyword ->
            containsPhrase(normalizedRuleInput, keyword)
        }
        val ruleScore = if (hasRuleMatch) rules.matchScore else 0.0
        val ruleFinished = nowNanos()

        val inferenceStarted = ruleFinished
        var linear = model.bias
        for ((token, count) in unigramCounts) {
            linear += (model.unigramWeights[token] ?: 0.0) * count
        }
        for ((token, count) in bigramCounts) {
            linear += (model.bigramWeights[token] ?: 0.0) * count
        }

        // Keep a text-only score for model-only decisions. The full score
        // below includes URL-shape features, which are useful supporting
        // evidence but are not reliable evidence of gambling by themselves.
        var contentLinear = model.bias
        for ((token, count) in unigramCounts) {
            contentLinear += (model.unigramWeights[token] ?: 0.0) * count
        }
        for ((token, count) in bigramCounts) {
            contentLinear += (model.bigramWeights[token] ?: 0.0) * count
        }
        val contentModelScore = 1.0 / (1.0 + exp(-contentLinear))

        val featureValues = urlFeatureValues(input.url, urlKeywordCount)
        for (feature in model.urlFeatures) {
            val rawValue = featureValues[feature.name] ?: 0.0
            linear += ((rawValue - feature.offset) * feature.scale) * feature.weight
        }

        val modelScore = 1.0 / (1.0 + exp(-linear))
        val inferenceFinished = nowNanos()

        val decisionStarted = inferenceFinished
        val hybridScore = (model.mlWeight * modelScore) + (model.ruleWeight * ruleScore)
        // URL-shape features are useful as supporting evidence, but they are
        // not sufficient on their own. Short links commonly contain digits
        // and opaque path segments that resemble the trained URL distribution
        // without indicating gambling. Explicit URL rules remain decisive;
        // model-only decisions require committed page/DOM content that is
        // independently suspicious without URL-shape features.
        val block = hybridScore >= model.threshold &&
            (ruleScore > 0.0 || (input.hasDomContent && contentModelScore >= model.threshold))
        val reason = when {
            block && ruleScore > 0.0 -> "hybrid_keyword_match"
            block -> "model_threshold"
            else -> "below_threshold"
        }
        val result = ClassificationResult(
            decision = if (block) "block" else "allow",
            ruleScore = ruleScore,
            modelScore = modelScore,
            reasonCode = reason,
            modelVersion = modelVersion,
            rulesetVersion = rulesetVersion,
        )
        val decisionFinished = nowNanos()
        return result.copy(
            timings = ClassificationTimings(
                preprocessingNanos = (preprocessingFinished - preprocessingStarted).coerceAtLeast(0),
                ruleNanos = (ruleFinished - ruleStarted).coerceAtLeast(0),
                inferenceNanos = (inferenceFinished - inferenceStarted).coerceAtLeast(0),
                decisionNanos = (decisionFinished - decisionStarted).coerceAtLeast(0),
            ),
        )
    }

    private fun urlFeatureValues(url: String, keywordCount: Int): Map<String, Double> {
        val parsed = runCatching { URI(url) }.getOrNull()
        val scheme = parsed?.scheme?.lowercase(Locale.ROOT)
        val host = parsed?.host?.lowercase(Locale.ROOT).orEmpty().trimEnd('.')
        val valid = (scheme == "http" || scheme == "https") && host.isNotEmpty()
        val labels = host.split('.').filter(String::isNotEmpty)
        val suffix = labels.lastOrNull().orEmpty()
        val subdomain = if (labels.size > 2) labels.dropLast(2).joinToString(".") else ""
        return mapOf(
            "url_length" to url.length.toDouble(),
            "url_digit_count" to url.count(Char::isDigit).toDouble(),
            "url_dot_count" to url.count { it == '.' }.toDouble(),
            "url_slash_count" to url.count { it == '/' }.toDouble(),
            "url_hyphen_count" to url.count { it == '-' }.toDouble(),
            "url_question_count" to url.count { it == '?' }.toDouble(),
            "url_equal_count" to url.count { it == '=' }.toDouble(),
            "url_keyword_count" to keywordCount.toDouble(),
            "url_has_number" to if (url.any(Char::isDigit)) 1.0 else 0.0,
            "url_has_https" to if (scheme == "https") 1.0 else 0.0,
            "url_is_valid" to if (valid) 1.0 else 0.0,
            "domain_length" to host.length.toDouble(),
            "subdomain_length" to subdomain.length.toDouble(),
            "suffix_length" to suffix.length.toDouble(),
        )
    }

    private fun bounded(input: ClassificationInput): ClassificationInput {
        return ClassificationInput(
            url = input.url.take(2048),
            title = input.title.take(512),
            headings = input.headings.take(32).map { it.take(256) },
            anchorTexts = input.anchorTexts.take(64).map { it.take(256) },
            hasDomContent = input.hasDomContent,
        )
    }

    private fun normalizeText(value: String): String {
        return value.lowercase(Locale.ROOT)
    }

    private fun normalizeForRules(value: String): String {
        return normalizeRuleKeyword(value)
    }

    private fun containsPhrase(haystack: String, needle: String): Boolean {
        return needle.isNotEmpty() && " $haystack ".contains(" $needle ")
    }
}
