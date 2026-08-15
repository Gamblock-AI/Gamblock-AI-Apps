package com.gamblock.gamblock_ai_apps

import android.view.accessibility.AccessibilityNodeInfo
import java.util.ArrayDeque

/** Research distribution: browser protection plus transparent removal friction. */
class GamblockAccessibilityService : BrowserProtectionAccessibilityService() {
    companion object {
        private val SETTINGS_PACKAGES = setOf(
            "com.android.settings",
            "com.google.android.packageinstaller",
            "com.android.packageinstaller",
        )
        private val NON_STANDARD_BROWSERS = setOf(
            "com.opera.browser",
            "com.opera.mini.native",
            "com.uc.browser",
            "org.mozilla.firefox",
        )
    }

    override val additionalObservedPackages: Set<String> = SETTINGS_PACKAGES
    override val additionalBrowserPackages: Set<String> = NON_STANDARD_BROWSERS
    private lateinit var tamperOverlay: TamperWarningOverlay

    override fun onProtectionServiceConnected() {
        tamperOverlay = TamperWarningOverlay(this)
    }

    override fun onProtectionServiceDestroyed() {
        if (::tamperOverlay.isInitialized) tamperOverlay.dismiss()
    }

    override fun handleAdditionalAccessibilityEvent(sourcePackage: String) {
        if (sourcePackage !in SETTINGS_PACKAGES) return
        inspectTamperScreen()
    }

    private fun inspectTamperScreen() {
        val root = rootInActiveWindow ?: return
        val texts = mutableListOf<String>()
        val queue = ArrayDeque<AccessibilityNodeInfo>()
        queue.add(root)
        var visited = 0
        while (queue.isNotEmpty() && visited < 300) {
            val node = queue.removeFirst()
            visited++
            node.text?.toString()?.takeIf(String::isNotBlank)?.let(texts::add)
            node.contentDescription?.toString()?.takeIf(String::isNotBlank)?.let(texts::add)
            for (index in 0 until node.childCount) {
                node.getChild(index)?.let(queue::add)
            }
        }
        val combined = texts.joinToString(" ").lowercase()
        val targetsGamblock = combined.contains("gamblock") || combined.contains(packageName.lowercase())
        val dangerous = listOf(
            "uninstall",
            "copot",
            "hapus aplikasi",
            "force stop",
            "paksa berhenti",
            "disable",
            "nonaktifkan",
            "accessibility",
            "aksesibilitas",
        ).any(combined::contains)
        if (!targetsGamblock || !dangerous) return
        if (stateStore.activeGrantAllowsSettingsAction()) return
        aggregateStore.increment("tamper_detected")
        performGlobalAction(GLOBAL_ACTION_BACK)
        tamperOverlay.show()
        NativeEventBus.emit(mapOf("type" to "approval_required"))
    }
}
