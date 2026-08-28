package com.gamblock.gamblock_ai_apps

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class HybridDecisionEngineTest {
    private val model = HybridModelConfig(
        bias = -1.0,
        mlWeight = 0.75,
        ruleWeight = 0.25,
        threshold = 0.4,
        unigramWeights = mapOf(
            "judi" to 2.4,
            "slot" to 2.0,
            "casino" to 2.0,
            "taruhan" to 1.8,
            "universitas" to -1.2,
            "penelitian" to -1.0,
        ),
        bigramWeights = mapOf("slot online" to 1.2),
        urlFeatures = emptyList(),
    )
    private val rules = HybridRuleConfig(listOf("judi", "slot online"), 1.0)

    private fun classify(input: ClassificationInput): ClassificationResult {
        return HybridDecisionEngine.classify(
            raw = input,
            model = model,
            rules = rules,
            modelVersion = "gamblock-lr-test",
            rulesetVersion = "gambling-keywords-test",
        )
    }

    @Test
    fun strongUrlRuleBlocks() {
        val result = classify(
            ClassificationInput(
                url = "https://contoh-judi.invalid/",
                title = "",
                headings = emptyList(),
                anchorTexts = emptyList(),
            ),
        )
        assertEquals("block", result.decision)
        assertEquals("hybrid_keyword_match", result.reasonCode)
        assertTrue(result.timings.preprocessingNanos >= 0)
        assertTrue(result.timings.ruleNanos >= 0)
        assertTrue(result.timings.inferenceNanos >= 0)
        assertTrue(result.timings.decisionNanos >= 0)
    }

    @Test
    fun domLogisticRegressionBlocks() {
        val result = classify(
            ClassificationInput(
                url = "https://dynamic.invalid/",
                title = "casino judi slot",
                headings = listOf("taruhan"),
                anchorTexts = emptyList(),
            ),
        )
        assertEquals("block", result.decision)
        assertTrue(result.modelScore >= 0.5)
    }

    @Test
    fun benignEducationControlAllows() {
        val result = classify(
            ClassificationInput(
                url = "https://kampus.ac.id/",
                title = "penelitian universitas",
                headings = emptyList(),
                anchorTexts = emptyList(),
            ),
        )
        assertEquals("allow", result.decision)
    }
}
