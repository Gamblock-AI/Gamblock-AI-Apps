package com.gamblock.gamblock_ai_apps

import org.junit.Assert.assertTrue
import org.junit.Test

class ResearchBrowserPackagesTest {
    @Test
    fun upxBrowserPackageIsObservedByResearchAccessibilityService() {
        assertTrue(
            ResearchBrowserPackages.UPX_BROWSER_PACKAGE in
                ResearchBrowserPackages.additionalBrowserPackages,
        )
    }
}
