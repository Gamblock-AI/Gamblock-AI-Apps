package com.gamblock.gamblock_ai_apps

import org.junit.Assert.assertEquals
import org.junit.Test

class UrlFallbackTest {
    @Test
    fun httpUrlLooksLikeUrl() {
        assertEquals(true, BrowserProtectionAccessibilityService.looksLikeUrl("http://judi-online.example/"))
    }

    @Test
    fun httpsUrlLooksLikeUrl() {
        assertEquals(true, BrowserProtectionAccessibilityService.looksLikeUrl("https://judi-online.example/"))
    }

    @Test
    fun bareDomainLooksLikeUrl() {
        assertEquals(true, BrowserProtectionAccessibilityService.looksLikeUrl("judi-online.example"))
    }

    @Test
    fun plainSentenceDoesNotLookLikeUrl() {
        assertEquals(false, BrowserProtectionAccessibilityService.looksLikeUrl("slot online terpercaya"))
    }

    @Test
    fun emptyCurrentAcceptsFirstCandidate() {
        assertEquals(
            true,
            BrowserProtectionAccessibilityService.isBetterUrlCandidate("cari di sini", ""),
        )
    }

    @Test
    fun urlCandidateBeatsPlainText() {
        assertEquals(
            true,
            BrowserProtectionAccessibilityService.isBetterUrlCandidate(
                "https://judi-online.example/",
                "cari di sini",
            ),
        )
        assertEquals(
            false,
            BrowserProtectionAccessibilityService.isBetterUrlCandidate(
                "cari di sini",
                "https://judi-online.example/",
            ),
        )
    }

    @Test
    fun schemeCandidateBeatsBareDomain() {
        assertEquals(
            true,
            BrowserProtectionAccessibilityService.isBetterUrlCandidate(
                "https://judi-online.example/",
                "judi-online.example",
            ),
        )
    }

    @Test
    fun longerCandidateWinsWhenEquivalent() {
        assertEquals(
            true,
            BrowserProtectionAccessibilityService.isBetterUrlCandidate(
                "https://judi-online.example/login",
                "https://judi-online.example/",
            ),
        )
    }
}
