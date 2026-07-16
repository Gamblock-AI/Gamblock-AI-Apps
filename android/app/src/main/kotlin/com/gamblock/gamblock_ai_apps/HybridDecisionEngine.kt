package com.gamblock.gamblock_ai_apps

import java.text.Normalizer
import kotlin.math.exp

object HybridDecisionEngine {
    private val tokenRegex = Regex("[\\p{L}\\p{N}]+")

    fun classify(
        raw: ClassificationInput,
        bias: Double,
        threshold: Double,
        weights: Map<String, Double>,
        strongPatterns: List<String>,
        mediumPatterns: List<String>,
        strongScore: Double,
        mediumScore: Double,
        modelVersion: String,
        rulesetVersion: String,
    ): ClassificationResult {
        val input = bounded(raw)
        val normalizedUrl = normalize(input.url)
        val ruleScore = when {
            strongPatterns.any(normalizedUrl::contains) -> strongScore
            mediumPatterns.any(normalizedUrl::contains) -> mediumScore
            else -> 0.0
        }
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
        val counts = tokenRegex.findAll(normalize(document))
            .map { it.value }
            .groupingBy { it }
            .eachCount()
        var linear = bias
        for ((token, count) in counts) {
            linear += (weights[token] ?: 0.0) * count.coerceAtMost(3)
        }
        val modelScore = 1.0 / (1.0 + exp(-linear))
        val block = ruleScore >= 0.95 ||
            modelScore >= threshold ||
            (ruleScore >= 0.55 && modelScore >= 0.55)
        val reason = when {
            ruleScore >= 0.95 -> "strong_url_rule"
            modelScore >= threshold -> "dummy_lr_threshold"
            block -> "hybrid_combination"
            else -> "below_threshold"
        }
        return ClassificationResult(
            decision = if (block) "block" else "allow",
            ruleScore = ruleScore,
            modelScore = modelScore,
            reasonCode = reason,
            modelVersion = modelVersion,
            rulesetVersion = rulesetVersion,
        )
    }

    private fun bounded(input: ClassificationInput): ClassificationInput {
        return ClassificationInput(
            url = input.url.take(2048),
            title = input.title.take(512),
            headings = input.headings.take(32).map { it.take(256) },
            anchorTexts = input.anchorTexts.take(64).map { it.take(256) },
        )
    }

    private fun normalize(value: String): String {
        return Normalizer.normalize(value, Normalizer.Form.NFKC)
            .lowercase()
            .replace(Regex("\\s+"), " ")
            .trim()
    }
}
