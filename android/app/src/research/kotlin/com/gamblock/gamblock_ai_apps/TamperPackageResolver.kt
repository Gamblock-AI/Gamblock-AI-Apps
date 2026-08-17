package com.gamblock.gamblock_ai_apps

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings

data class ResolvedTamperPackages(
    val settings: Set<String>,
    val packageInstallers: Set<String>,
    val launchers: Set<String>,
) {
    val observed: Set<String>
        get() = settings + packageInstallers + launchers

    fun surfaceFor(packageName: String): TamperSurface = when (packageName) {
        in settings -> TamperSurface.SETTINGS
        in packageInstallers -> TamperSurface.PACKAGE_INSTALLER
        in launchers -> TamperSurface.LAUNCHER
        else -> TamperSurface.OTHER
    }
}

/** Resolves system handlers and combines them with a small audited OEM list. */
class TamperPackageResolver(private val context: Context) {
    companion object {
        private val AUDITED_SETTINGS_PACKAGES = setOf(
            "com.android.settings",
            "com.miui.securitycenter",
            "com.coloros.safecenter",
            "com.coloros.securityguard",
            "com.iqoo.secure",
            "com.transsion.phonemaster",
        )
        private val AUDITED_INSTALLER_PACKAGES = setOf(
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
        private val AUDITED_LAUNCHER_PACKAGES = setOf(
            "com.miui.home",
            "com.mi.android.globallauncher",
            "com.sec.android.app.launcher",
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
    }

    @Suppress("DEPRECATION")
    fun resolve(): ResolvedTamperPackages {
        val packageManager = context.packageManager
        val settingsIntent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.parse("package:${context.packageName}"),
        )
        val settings = AUDITED_SETTINGS_PACKAGES + listOfNotNull(
            packageManager.resolveActivity(settingsIntent, 0)?.activityInfo?.packageName,
            packageManager.resolveActivity(Intent(Settings.ACTION_SETTINGS), 0)
                ?.activityInfo?.packageName,
            packageManager.resolveActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS), 0)
                ?.activityInfo?.packageName,
        )
        val removalIntent = Intent(
            Intent.ACTION_DELETE,
            Uri.parse("package:${context.packageName}"),
        )
        val installers = AUDITED_INSTALLER_PACKAGES + packageManager
            .queryIntentActivities(removalIntent, 0)
            .map { it.activityInfo.packageName }
        val homeIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        val launchers = AUDITED_LAUNCHER_PACKAGES + packageManager
            .queryIntentActivities(homeIntent, 0)
            .map { it.activityInfo.packageName }
        return ResolvedTamperPackages(
            settings = settings.filter(String::isNotBlank).toSet(),
            packageInstallers = installers.filter(String::isNotBlank).toSet(),
            launchers = launchers.filter(String::isNotBlank).toSet(),
        )
    }
}
