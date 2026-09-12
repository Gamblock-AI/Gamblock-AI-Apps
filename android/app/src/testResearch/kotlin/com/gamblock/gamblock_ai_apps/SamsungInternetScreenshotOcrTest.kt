package com.gamblock.gamblock_ai_apps

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class SamsungInternetScreenshotOcrTest {
    private val eligibleState = SamsungOcrPageState(
        isSamsungPackage = true,
        hasCommittedPageSurface = true,
        isEditingBrowserChrome = false,
        isTabSwitcher = false,
    )

    @Test
    fun invalidToolbarCoordinateFallsBackWithoutReversedRange() {
        val bounds = SamsungOcrCropBoundsResolver.resolve(
            eligibleState.copy(
                toolbarBottoms = listOf(1769),
                bottomBarTops = listOf(1554),
            ),
            frameWidth = 720,
            frameHeight = 1650,
        )

        assertEquals(SamsungOcrBounds(0, 145, 720, 1554), bounds)
    }

    @Test
    fun validPageSurfaceBoundsArePreferred() {
        val bounds = SamsungOcrCropBoundsResolver.resolve(
            eligibleState.copy(
                pageBounds = listOf(SamsungOcrBounds(0, 180, 720, 1500)),
            ),
            frameWidth = 720,
            frameHeight = 1650,
        )

        assertEquals(SamsungOcrBounds(0, 180, 720, 1500), bounds)
    }

    @Test
    fun pageSurfaceIsIntersectedWithScreenshotFrame() {
        val bounds = SamsungOcrCropBoundsResolver.resolve(
            eligibleState.copy(
                pageBounds = listOf(SamsungOcrBounds(-40, 180, 760, 1800)),
            ),
            frameWidth = 720,
            frameHeight = 1650,
        )

        assertEquals(SamsungOcrBounds(0, 180, 720, 1650), bounds)
    }

    @Test
    fun overlappingChromeBoundsUseDeterministicFallback() {
        val bounds = SamsungOcrCropBoundsResolver.resolve(
            eligibleState.copy(
                toolbarBottoms = listOf(1600),
                bottomBarTops = listOf(100),
            ),
            frameWidth = 720,
            frameHeight = 1650,
        )

        assertEquals(SamsungOcrBounds(0, 145, 720, 1554), bounds)
    }

    @Test
    fun implausiblySmallChromeAreaUsesDeterministicFallback() {
        val bounds = SamsungOcrCropBoundsResolver.resolve(
            eligibleState.copy(
                toolbarBottoms = listOf(1500),
                bottomBarTops = listOf(1554),
            ),
            frameWidth = 720,
            frameHeight = 1650,
        )

        assertEquals(SamsungOcrBounds(0, 145, 720, 1554), bounds)
    }

    @Test
    fun fullFramePageSurfaceStillExcludesBrowserChromeByFallback() {
        val bounds = SamsungOcrCropBoundsResolver.resolve(
            eligibleState.copy(
                pageBounds = listOf(SamsungOcrBounds(0, 0, 720, 1650)),
            ),
            frameWidth = 720,
            frameHeight = 1650,
        )

        assertEquals(SamsungOcrBounds(0, 145, 720, 1554), bounds)
    }

    @Test
    fun tinyScreenshotIsRejected() {
        val bounds = SamsungOcrCropBoundsResolver.resolve(
            eligibleState,
            frameWidth = 20,
            frameHeight = 20,
        )

        assertNull(bounds)
    }

    @Test
    fun addressBarEditingAndTabSwitcherAreNotEligible() {
        assertFalse(eligibleState.copy(isEditingBrowserChrome = true).isEligible)
        assertFalse(eligibleState.copy(isTabSwitcher = true).isEligible)
        assertFalse(eligibleState.copy(hasCommittedPageSurface = false).isEligible)
        assertFalse(eligibleState.copy(isSamsungPackage = false).isEligible)
        assertTrue(eligibleState.isEligible)
    }

    @Test
    fun samePageBurstDeliversUsefulActiveResultAndDropsPendingRequest() {
        val coordinator = SamsungOcrLatestRequestCoordinator<String>()
        val first = coordinator.submit("page")!!
        assertNull(coordinator.submit("page"))
        assertNull(coordinator.submit("page"))
        assertTrue(coordinator.isCurrent(first))

        val firstCompletion = coordinator.complete(
            first,
            coalesceSamePagePending = true,
        )
        assertTrue(firstCompletion.shouldDeliver)
        assertNull(firstCompletion.next)
    }

    @Test
    fun samePageBurstPromotesNewestPendingWhenActiveOcrIsNotUseful() {
        val coordinator = SamsungOcrLatestRequestCoordinator<String>()
        val first = coordinator.submit("page")!!
        coordinator.submit("page")

        val firstCompletion = coordinator.complete(
            first,
            coalesceSamePagePending = false,
        )

        assertFalse(firstCompletion.shouldDeliver)
        assertEquals("page", firstCompletion.next?.value)
        assertTrue(coordinator.isCurrent(firstCompletion.next!!))
    }

    @Test
    fun newestDifferentPageRequestReplacesOlderPendingRequest() {
        val coordinator = SamsungOcrLatestRequestCoordinator<String>()
        val first = coordinator.submit("first")!!
        coordinator.submit("second")
        coordinator.submit("third")

        assertFalse(coordinator.isCurrent(first))
        val firstCompletion = coordinator.complete(
            first,
            coalesceSamePagePending = true,
        )
        assertFalse(firstCompletion.shouldDeliver)
        assertEquals("third", firstCompletion.next?.value)

        val lastCompletion = coordinator.complete(firstCompletion.next!!)
        assertTrue(lastCompletion.shouldDeliver)
        assertNull(lastCompletion.next)
    }

    @Test
    fun invalidationDropsActiveAndPendingResults() {
        val coordinator = SamsungOcrLatestRequestCoordinator<String>()
        val first = coordinator.submit("first")!!
        coordinator.submit("second")

        coordinator.invalidate()

        val completion = coordinator.complete(first)
        assertFalse(completion.shouldDeliver)
        assertNull(completion.next)
    }

    @Test
    fun closeDropsInflightResultAndPreventsAnotherStart() {
        val coordinator = SamsungOcrLatestRequestCoordinator<String>()
        val first = coordinator.submit("first")!!

        coordinator.close()

        assertFalse(coordinator.isCurrent(first))
        assertFalse(coordinator.complete(first).shouldDeliver)
        assertNull(coordinator.submit("after-close"))
    }

    @Test
    fun duplicateCompletionCannotReplaceTheCurrentRequest() {
        val coordinator = SamsungOcrLatestRequestCoordinator<String>()
        val first = coordinator.submit("first")!!
        coordinator.submit("second")
        val second = coordinator.complete(first).next!!

        val duplicate = coordinator.complete(first)

        assertFalse(duplicate.shouldDeliver)
        assertNull(duplicate.next)
        assertTrue(coordinator.isCurrent(second))
    }

    @Test
    fun screenshotThrottleWaitsUntilMinimumIntervalHasElapsed() {
        val throttle = SamsungOcrScreenshotThrottle(minimumIntervalMs = 350L)

        assertEquals(0L, throttle.delayBeforeRequest(nowElapsedMs = 1_000L))
        throttle.markRequested(nowElapsedMs = 1_000L)

        assertEquals(350L, throttle.delayBeforeRequest(nowElapsedMs = 1_000L))
        assertEquals(1L, throttle.delayBeforeRequest(nowElapsedMs = 1_349L))
        assertEquals(0L, throttle.delayBeforeRequest(nowElapsedMs = 1_350L))
    }

    @Test
    fun screenshotIntervalFailureGetsOnlyOneBoundedRetry() {
        assertEquals(
            1_000L,
            SamsungOcrScreenshotRetryPolicy.retryDelayMs(
                android.accessibilityservice.AccessibilityService
                    .ERROR_TAKE_SCREENSHOT_INTERVAL_TIME_SHORT,
                intervalRetryCount = 0,
            ),
        )
        assertNull(
            SamsungOcrScreenshotRetryPolicy.retryDelayMs(
                android.accessibilityservice.AccessibilityService
                    .ERROR_TAKE_SCREENSHOT_INTERVAL_TIME_SHORT,
                intervalRetryCount = 1,
            ),
        )
        assertNull(
            SamsungOcrScreenshotRetryPolicy.retryDelayMs(
                android.accessibilityservice.AccessibilityService
                    .ERROR_TAKE_SCREENSHOT_INTERNAL_ERROR,
                intervalRetryCount = 0,
            ),
        )
    }
}
