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

    @Test
    fun browserTabGridIsRecognizedAsTabSwitcherUi() {
        val result = BrowserProtectionAccessibilityService.isTabSwitcherUi(
            viewIds = listOf("com.android.chrome:id/tab_grid_view"),
            classNames = emptyList(),
        )
        assertEquals(true, result)
    }

    @Test
    fun browserTabSwitcherClassIsRecognizedAsTabSwitcherUi() {
        val result = BrowserProtectionAccessibilityService.isTabSwitcherUi(
            viewIds = emptyList(),
            classNames = listOf("org.chromium.chrome.browser.tab.TabListView"),
        )
        assertEquals(true, result)
    }

    @Test
    fun browserTabSwitcherButtonAloneIsNotTheTabSwitcherSurface() {
        val result = BrowserProtectionAccessibilityService.isTabSwitcherUi(
            viewIds = listOf("com.android.chrome:id/tab_switcher_button"),
            classNames = listOf("android.widget.ImageButton"),
        )
        assertEquals(false, result)
    }

    @Test
    fun ordinaryBrowserContentIsNotRecognizedAsTabSwitcherUi() {
        val result = BrowserProtectionAccessibilityService.isTabSwitcherUi(
            viewIds = listOf("com.android.chrome:id/url_bar"),
            classNames = listOf("android.webkit.WebView"),
        )
        assertEquals(false, result)
    }

    @Test
    fun samsungBrowserWebViewSubclassIsRecognizedAsPageContent() {
        val result = BrowserProtectionAccessibilityService.isBrowserWebContentClassName(
            "com.sec.android.app.sbrowser.browser.SamsungWebView",
        )
        assertEquals(true, result)
    }

    @Test
    fun ordinaryBrowserViewIsNotRecognizedAsPageContent() {
        val result = BrowserProtectionAccessibilityService.isBrowserWebContentClassName(
            "android.widget.FrameLayout",
        )
        assertEquals(false, result)
    }
}
