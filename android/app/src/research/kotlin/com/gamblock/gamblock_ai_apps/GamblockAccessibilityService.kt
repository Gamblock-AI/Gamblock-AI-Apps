package com.gamblock.gamblock_ai_apps

import android.os.SystemClock
import android.view.accessibility.AccessibilityNodeInfo
import java.util.ArrayDeque

/** Research distribution: browser protection plus transparent removal friction. */
class GamblockAccessibilityService : BrowserProtectionAccessibilityService() {
    companion object {
        private val SETTINGS_AND_SECURITY_PACKAGES = setOf(
            "com.android.settings",
            "com.miui.securitycenter",
            "com.coloros.safecenter",
            "com.coloros.securityguard",
            "com.iqoo.secure",
            "com.transsion.phonemaster",
        )

        private val PACKAGE_INSTALLER_PACKAGES = setOf(
            "com.android.packageinstaller",
            "com.google.android.packageinstaller",
            "com.miui.packageinstaller",
            "com.samsung.android.packageinstaller",
            "com.coloros.packageinstaller",
            "com.heytap.packageinstaller",
            "com.vivo.packageinstaller",
            "com.transsion.packageinstaller",
            "com.android.vending",
        )

        private val LAUNCHER_PACKAGES = setOf(
            "com.miui.home",
            "com.mi.android.globallauncher",
            "com.miui.cleanmaster",
            "com.miui.mihome2",
            "com.sec.android.app.launcher",
            "com.samsung.android.settings.intelligence",
            "com.samsung.android.app.cocktailbarservice",
            "com.oppo.launcher",
            "com.coloros.launcher",
            "com.heytap.launcher",
            "com.bbk.launcher2",
            "com.vivo.launcher",
            "com.transsion.XOSLauncher",
            "com.transsion.hilauncher",
            "com.google.android.apps.nexuslauncher",
            "com.android.launcher3",
            "com.teslacoilsw.launcher",
            "com.microsoft.launcher",
            "com.actionlauncher.playstore",
            "com.smartlauncher.smartlauncher",
        )

        private val TAMPER_SUSPICIOUS_PACKAGES = SETTINGS_AND_SECURITY_PACKAGES +
            PACKAGE_INSTALLER_PACKAGES +
            LAUNCHER_PACKAGES

        private val NON_STANDARD_BROWSERS = setOf(
            "com.opera.browser",
            "com.opera.mini.native",
            "com.uc.browser",
            "org.mozilla.firefox",
        )

        private const val MIN_TAMPER_INTERVAL_MS = 2000L
    }

    override val additionalObservedPackages: Set<String> = TAMPER_SUSPICIOUS_PACKAGES
    override val additionalBrowserPackages: Set<String> = NON_STANDARD_BROWSERS
    private lateinit var tamperOverlay: TamperWarningOverlay
    private var lastTamperTriggerAt = 0L

    override fun onProtectionServiceConnected() {
        tamperOverlay = TamperWarningOverlay(this)
    }

    override fun onProtectionServiceDestroyed() {
        if (::tamperOverlay.isInitialized) tamperOverlay.dismiss()
    }

    override fun handleAdditionalAccessibilityEvent(sourcePackage: String) {
        if (!isTamperTargetPackage(sourcePackage)) return
        inspectTamperScreen(sourcePackage)
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

    private fun inspectTamperScreen(sourcePackage: String) {
        if (tamperOverlay.isShowing) return
        val now = SystemClock.elapsedRealtime()
        if (now - lastTamperTriggerAt < MIN_TAMPER_INTERVAL_MS) return

        val root = rootInActiveWindow ?: return
        val lowerPackage = sourcePackage.lowercase()
        val isLauncher = lowerPackage in LAUNCHER_PACKAGES || lowerPackage.contains("launcher") || lowerPackage.contains("home")
        val isInstaller = lowerPackage in PACKAGE_INSTALLER_PACKAGES || lowerPackage.contains("packageinstaller") || lowerPackage.contains("vending")
        val isSettings = lowerPackage in SETTINGS_AND_SECURITY_PACKAGES || lowerPackage.contains("settings") || lowerPackage.contains("secure") || lowerPackage.contains("center")

        val texts = mutableListOf<String>()
        val queue = ArrayDeque<AccessibilityNodeInfo>()
        queue.add(root)
        var visited = 0
        var foundExplicitDialogTamper = false

        while (queue.isNotEmpty() && visited < 300) {
            val node = queue.removeFirst()
            visited++
            val text = node.text?.toString()?.trim()
            val desc = node.contentDescription?.toString()?.trim()

            for (raw in listOfNotNull(text, desc)) {
                if (raw.isNotBlank()) {
                    texts.add(raw)
                    val lower = raw.lowercase()
                    if ((lower.contains("gamblock") || lower.contains(packageName.lowercase())) &&
                        (lower.contains("copot") || lower.contains("uninstall") || lower.contains("hapus") || lower.contains("remove"))
                    ) {
                        foundExplicitDialogTamper = true
                    }
                }
            }

            for (index in 0 until node.childCount) {
                node.getChild(index)?.let(queue::add)
            }
        }

        val shouldIntercept: Boolean = when {
            // Case 1: On Launchers, ONLY trigger on explicit modal uninstall dialogs for Gamblock
            isLauncher -> foundExplicitDialogTamper

            // Case 2: In Package Installers, trigger on explicit prompt or package confirmation
            isInstaller -> {
                foundExplicitDialogTamper || run {
                    val combined = texts.joinToString(" ").lowercase()
                    val targetsGamblock = combined.contains("gamblock") || combined.contains(packageName.lowercase())
                    val hasUninstallPrompt = combined.contains("uninstall") || combined.contains("copot") || combined.contains("hapus")
                    targetsGamblock && hasUninstallPrompt
                }
            }

            // Case 3: In Settings / Security Center, trigger if on Gamblock App Info page / Accessibility toggle with dangerous buttons
            isSettings -> {
                val combined = texts.joinToString(" ").lowercase()
                val targetsGamblock = combined.contains("gamblock") || combined.contains(packageName.lowercase())
                val hasDangerousButton = listOf(
                    "uninstall",
                    "copot pemasangan",
                    "copot",
                    "force stop",
                    "paksa berhenti",
                    "berhenti paksa",
                    "clear data",
                    "hapus data",
                    "hapus semua data",
                    "hapus penyimpanan",
                    "disable",
                    "nonaktifkan",
                ).any(combined::contains)
                targetsGamblock && hasDangerousButton
            }

            else -> foundExplicitDialogTamper
        }

        if (!shouldIntercept) return
        if (stateStore.activeGrantAllowsSettingsAction()) return

        lastTamperTriggerAt = SystemClock.elapsedRealtime()
        aggregateStore.increment("tamper_detected")
        performGlobalAction(GLOBAL_ACTION_BACK)
        tamperOverlay.show()
        NativeEventBus.emit(mapOf("type" to "approval_required"))
    }
}
