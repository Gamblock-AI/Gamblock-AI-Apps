package com.gamblock.gamblock_ai_apps

import android.view.accessibility.AccessibilityNodeInfo
import java.util.ArrayDeque

/** Research distribution: browser protection plus transparent removal friction. */
class GamblockAccessibilityService : BrowserProtectionAccessibilityService() {
    companion object {
        private val TAMPER_SUSPICIOUS_PACKAGES = setOf(
            // Android Core & Package Managers
            "com.android.settings",
            "com.android.packageinstaller",
            "com.google.android.packageinstaller",
            "com.android.vending",

            // Xiaomi / Redmi / Poco (MIUI & HyperOS)
            "com.miui.home",
            "com.mi.android.globallauncher",
            "com.miui.securitycenter",
            "com.miui.packageinstaller",
            "com.miui.cleanmaster",
            "com.miui.mihome2",

            // Samsung (One UI)
            "com.sec.android.app.launcher",
            "com.samsung.android.packageinstaller",
            "com.samsung.android.settings.intelligence",
            "com.samsung.android.app.cocktailbarservice",

            // Oppo & Realme (ColorOS & Realme UI)
            "com.oppo.launcher",
            "com.coloros.launcher",
            "com.heytap.launcher",
            "com.coloros.packageinstaller",
            "com.heytap.packageinstaller",
            "com.coloros.safecenter",
            "com.coloros.securityguard",

            // Vivo & iQOO (Funtouch OS & OriginOS)
            "com.bbk.launcher2",
            "com.vivo.launcher",
            "com.vivo.packageinstaller",
            "com.iqoo.secure",

            // Transsion (Infinix, Tecno, itel - XOS & HiOS)
            "com.transsion.XOSLauncher",
            "com.transsion.hilauncher",
            "com.transsion.packageinstaller",
            "com.transsion.phonemaster",

            // Popular Third-party & AOSP Launchers
            "com.google.android.apps.nexuslauncher",
            "com.android.launcher3",
            "com.teslacoilsw.launcher",
            "com.microsoft.launcher",
            "com.actionlauncher.playstore",
            "com.smartlauncher.smartlauncher",
        )

        private val NON_STANDARD_BROWSERS = setOf(
            "com.opera.browser",
            "com.opera.mini.native",
            "com.uc.browser",
            "org.mozilla.firefox",
        )

        private val DANGEROUS_KEYWORDS = listOf(
            // Indonesian
            "uninstall",
            "copot pemasangan",
            "copot",
            "hapus aplikasi",
            "hapus",
            "buang",
            "bongkar",
            "paksa berhenti",
            "berhenti paksa",
            "nonaktifkan",
            "aksesibilitas",
            "batalkan pemasangan",
            "layanan terunduh",
            // English
            "force stop",
            "disable",
            "accessibility",
            "delete",
            "remove",
            "deactivate",
        )
    }

    override val additionalObservedPackages: Set<String> = TAMPER_SUSPICIOUS_PACKAGES
    override val additionalBrowserPackages: Set<String> = NON_STANDARD_BROWSERS
    private lateinit var tamperOverlay: TamperWarningOverlay

    override fun onProtectionServiceConnected() {
        tamperOverlay = TamperWarningOverlay(this)
    }

    override fun onProtectionServiceDestroyed() {
        if (::tamperOverlay.isInitialized) tamperOverlay.dismiss()
    }

    override fun handleAdditionalAccessibilityEvent(sourcePackage: String) {
        if (!isTamperTargetPackage(sourcePackage)) return
        inspectTamperScreen()
    }

    private fun isTamperTargetPackage(pkg: String): Boolean {
        if (pkg in TAMPER_SUSPICIOUS_PACKAGES) return true
        val lower = pkg.lowercase()
        return lower.contains("launcher") ||
            lower.contains("packageinstaller") ||
            lower.contains("settings") ||
            lower.contains("safecenter") ||
            lower.contains("securitycenter") ||
            lower.contains("phonemaster")
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
        val dangerous = DANGEROUS_KEYWORDS.any(combined::contains)
        if (!targetsGamblock || !dangerous) return
        if (stateStore.activeGrantAllowsSettingsAction()) return
        aggregateStore.increment("tamper_detected")
        performGlobalAction(GLOBAL_ACTION_BACK)
        tamperOverlay.show()
        NativeEventBus.emit(mapOf("type" to "approval_required"))
    }
}
