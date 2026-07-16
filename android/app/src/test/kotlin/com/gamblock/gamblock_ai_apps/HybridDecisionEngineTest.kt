package com.gamblock.gamblock_ai_apps

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class HybridDecisionEngineTest {
    private val weights = mapOf(
        "judi" to 2.4,
        "slot" to 2.0,
        "casino" to 2.0,
        "taruhan" to 1.8,
        "universitas" to -1.2,
        "penelitian" to -1.0,
    )

    private fun classify(input: ClassificationInput): ClassificationResult {
        return HybridDecisionEngine.classify(
            raw = input,
            bias = -3.2,
            threshold = 0.72,
            weights = weights,
            strongPatterns = listOf("judi", "slot-gacor"),
            mediumPatterns = listOf("bet"),
            strongScore = 0.95,
            mediumScore = 0.65,
            modelVersion = "dummy-lr-v1",
            rulesetVersion = "dummy-rules-v1",
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
        assertEquals("strong_url_rule", result.reasonCode)
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
        assertTrue(result.modelScore >= 0.72)
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
