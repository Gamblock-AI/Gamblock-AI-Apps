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
                hasDomContent = false,
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
                hasDomContent = true,
            ),
        )
        assertEquals("block", result.decision)
        assertTrue(result.modelScore >= 0.5)
    }

    @Test
    fun urlShapeOnlyDoesNotBlockOpaqueShortLink() {
        val urlShapeModel = model.copy(
            bias = -1.0,
            unigramWeights = emptyMap(),
            bigramWeights = emptyMap(),
            urlFeatures = listOf(
                UrlFeatureSpec(
                    name = "url_has_number",
                    offset = 0.0,
                    scale = 1.0,
                    weight = 2.0,
                ),
            ),
        )
        val result = HybridDecisionEngine.classify(
            raw = ClassificationInput(
                url = "https://share.google/dhxRArcuBGBvAx4vw",
                title = "",
                headings = emptyList(),
                anchorTexts = emptyList(),
                hasDomContent = false,
            ),
            model = urlShapeModel,
            rules = rules,
            modelVersion = "gamblock-lr-test",
            rulesetVersion = "gambling-keywords-test",
        )
        assertEquals("allow", result.decision)
        assertEquals(0.0, result.ruleScore, 0.0)
        assertTrue(result.modelScore > 0.5)
    }

    @Test
    fun modelOnlyDecisionStillBlocksWithCommittedDom() {
        val modelOnlyModel = model.copy(
            unigramWeights = mapOf("casino" to 2.4),
            bigramWeights = emptyMap(),
            urlFeatures = emptyList(),
        )
        val result = HybridDecisionEngine.classify(
            raw = ClassificationInput(
                url = "https://dynamic.invalid/",
                title = "casino",
                headings = emptyList(),
                anchorTexts = emptyList(),
                hasDomContent = true,
            ),
            model = modelOnlyModel,
            rules = rules,
            modelVersion = "gamblock-lr-test",
            rulesetVersion = "gambling-keywords-test",
        )
        assertEquals("block", result.decision)
        assertEquals(0.0, result.ruleScore, 0.0)
        assertEquals("model_threshold", result.reasonCode)
    }

    @Test
    fun urlShapeScoreDoesNotOverrideBenignCommittedDom() {
        val urlShapeModel = model.copy(
            bias = -1.0,
            unigramWeights = emptyMap(),
            bigramWeights = emptyMap(),
            urlFeatures = listOf(
                UrlFeatureSpec(
                    name = "url_has_number",
                    offset = 0.0,
                    scale = 1.0,
                    weight = 2.0,
                ),
            ),
        )
        val result = HybridDecisionEngine.classify(
            raw = ClassificationInput(
                url = "https://share.google/dhxRArcuBGBvAx4vw",
                title = "Google shared link",
                headings = listOf("Continue to shared content"),
                anchorTexts = emptyList(),
                hasDomContent = true,
            ),
            model = urlShapeModel,
            rules = rules,
            modelVersion = "gamblock-lr-test",
            rulesetVersion = "gambling-keywords-test",
        )
        assertEquals("allow", result.decision)
        assertTrue(result.modelScore > 0.5)
    }

    @Test
    fun benignEducationControlAllows() {
        val result = classify(
            ClassificationInput(
                url = "https://kampus.ac.id/",
                title = "penelitian universitas",
                headings = emptyList(),
                anchorTexts = emptyList(),
                hasDomContent = true,
            ),
        )
        assertEquals("allow", result.decision)
    }
}
