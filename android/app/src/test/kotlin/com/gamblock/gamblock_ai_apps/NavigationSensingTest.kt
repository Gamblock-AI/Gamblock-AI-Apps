package com.gamblock.gamblock_ai_apps

import android.view.accessibility.AccessibilityEvent
import org.junit.Assert.assertEquals
import org.junit.Test

class NavigationSensingTest {
    @Test
    fun subtreeTypeIsNavigationLike() {
        val result = BrowserProtectionAccessibilityService.isNavigationContentChange(
            AccessibilityEvent.CONTENT_CHANGE_TYPE_SUBTREE,
        )
        assertEquals(true, result)
    }

    @Test
    fun paneAppearedTypeIsNavigationLike() {
        val result = BrowserProtectionAccessibilityService.isNavigationContentChange(
            AccessibilityEvent.CONTENT_CHANGE_TYPE_PANE_APPEARED,
        )
        assertEquals(true, result)
    }

    @Test
    fun paneDisappearedTypeIsNavigationLike() {
        val result = BrowserProtectionAccessibilityService.isNavigationContentChange(
            AccessibilityEvent.CONTENT_CHANGE_TYPE_PANE_DISAPPEARED,
        )
        assertEquals(true, result)
    }

    @Test
    fun plainTextEditIsNotNavigationLike() {
        val result = BrowserProtectionAccessibilityService.isNavigationContentChange(
            AccessibilityEvent.CONTENT_CHANGE_TYPE_TEXT,
        )
        assertEquals(false, result)
    }

    @Test
    fun combinedSubtreeWithTextIsNavigationLike() {
        val result = BrowserProtectionAccessibilityService.isNavigationContentChange(
            AccessibilityEvent.CONTENT_CHANGE_TYPE_TEXT or
                AccessibilityEvent.CONTENT_CHANGE_TYPE_SUBTREE,
        )
        assertEquals(true, result)
    }
}
