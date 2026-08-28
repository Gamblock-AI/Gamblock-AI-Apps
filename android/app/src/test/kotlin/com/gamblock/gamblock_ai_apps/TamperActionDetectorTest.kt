package com.gamblock.gamblock_ai_apps

import org.junit.Assert.assertEquals
import org.junit.Test

class TamperActionDetectorTest {

    private val targetIdentifiers = setOf(
        "com.gamblock.gamblock_ai_apps.research",
        "Gamblock-AI Research",
        "Gamblock-AI",
        "Gamblock AI Research",
        "Gamblock AI",
    )

    @Test
    fun launcherClickingGenericDeleteShortcutDoesNotTriggerUninstall() {
        val observation = TamperObservation(
            surface = TamperSurface.LAUNCHER,
            eventKind = TamperEventKind.CLICK,
            sourceTexts = listOf("Hapus"),
            windowTexts = listOf("Layar Utama", "Hapus", "Gamblock-AI", "WhatsApp", "YouTube"),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.NONE, action)
    }

    @Test
    fun launcherUninstallingAnotherAppDoesNotTriggerUninstall() {
        val observation = TamperObservation(
            surface = TamperSurface.LAUNCHER,
            eventKind = TamperEventKind.WINDOW_CHANGED,
            sourceTexts = emptyList(),
            windowTexts = listOf("Copot pemasangan WhatsApp?", "Batal", "OK"),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.NONE, action)
    }

    @Test
    fun launcherArmedAndClickingUninstallTriggersUninstall() {
        val observation = TamperObservation(
            surface = TamperSurface.LAUNCHER,
            eventKind = TamperEventKind.CLICK,
            sourceTexts = listOf("Copot pemasangan"),
            windowTexts = listOf("Copot pemasangan", "Info aplikasi"),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = true,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.UNINSTALL, action)
    }

    @Test
    fun packageInstallerGamblockUninstallTriggersUninstall() {
        val observation = TamperObservation(
            surface = TamperSurface.PACKAGE_INSTALLER,
            eventKind = TamperEventKind.WINDOW_CHANGED,
            sourceTexts = emptyList(),
            windowTexts = listOf(
                "Apakah Anda ingin mencopot pemasangan aplikasi ini?",
                "Gamblock-AI Research",
                "Batal",
                "OK",
            ),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.UNINSTALL, action)
    }

    @Test
    fun packageInstallerAnotherAppUninstallDoesNotTriggerUninstall() {
        val observation = TamperObservation(
            surface = TamperSurface.PACKAGE_INSTALLER,
            eventKind = TamperEventKind.WINDOW_CHANGED,
            sourceTexts = emptyList(),
            windowTexts = listOf(
                "Apakah Anda ingin mencopot pemasangan aplikasi ini?",
                "Spotify Music",
                "Batal",
                "OK",
            ),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.NONE, action)
    }

    @Test
    fun samsungStylePackageInstallerContentChangeTriggersUninstall() {
        val observation = TamperObservation(
            surface = TamperSurface.PACKAGE_INSTALLER,
            eventKind = TamperEventKind.CONTENT_CHANGED,
            sourceTexts = emptyList(),
            windowTexts = listOf(
                "Uninstall app?",
                "Gamblock-AI Research",
                "Cancel",
                "OK",
            ),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.UNINSTALL, action)
    }

    @Test
    fun oppoStyleSettingsContentChangeTriggersUninstall() {
        val observation = TamperObservation(
            surface = TamperSurface.SETTINGS,
            eventKind = TamperEventKind.CONTENT_CHANGED,
            sourceTexts = emptyList(),
            windowTexts = listOf(
                "Hapus aplikasi Gamblock-AI Research?",
                "Batal",
                "OK",
            ),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.UNINSTALL, action)
    }

    @Test
    fun settingsTurningOffGamblockAccessibilityTriggersDisableAccessibility() {
        val observation = TamperObservation(
            surface = TamperSurface.SETTINGS,
            eventKind = TamperEventKind.CLICK,
            sourceTexts = listOf("Gunakan Gamblock-AI"),
            windowTexts = listOf(
                "Layanan Aksesibilitas",
                "Gunakan Gamblock-AI",
                "Gamblock-AI Research",
            ),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = true,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.DISABLE_ACCESSIBILITY, action)
    }

    @Test
    fun settingsManagingAnotherAppDoesNotTriggerTamper() {
        val observation = TamperObservation(
            surface = TamperSurface.SETTINGS,
            eventKind = TamperEventKind.CLICK,
            sourceTexts = listOf("Paksa berhenti"),
            windowTexts = listOf("Info Aplikasi", "Telegram", "Paksa berhenti", "Hapus data"),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.NONE, action)
    }

    @Test
    fun launcherExitingAppToHomeScreenDoesNotTriggerTamper() {
        val observation = TamperObservation(
            surface = TamperSurface.LAUNCHER,
            eventKind = TamperEventKind.WINDOW_CHANGED,
            sourceTexts = emptyList(),
            windowTexts = listOf("Layar Utama", "Gamblock-AI Research", "Batal", "Telusuri", "WhatsApp", "YouTube"),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.NONE, action)
    }

    @Test
    fun launcherAtomicGamblockUninstallDialogTriggersTamper() {
        val observation = TamperObservation(
            surface = TamperSurface.LAUNCHER,
            eventKind = TamperEventKind.WINDOW_CHANGED,
            sourceTexts = emptyList(),
            windowTexts = listOf(
                "Copot pemasangan Gamblock-AI Research?",
                "Batal",
                "OK",
            ),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.UNINSTALL, action)
    }

    @Test
    fun settingsForceStopGamblockTriggersForceStop() {
        val observation = TamperObservation(
            surface = TamperSurface.SETTINGS,
            eventKind = TamperEventKind.CLICK,
            sourceTexts = listOf("Paksa berhenti"),
            windowTexts = listOf(
                "Info Aplikasi",
                "Gamblock-AI Research",
                "com.gamblock.gamblock_ai_apps.research",
                "Paksa berhenti",
                "Hapus data",
            ),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.FORCE_STOP, action)
    }

    @Test
    fun passiveXiaomiAppInfoLabelsDoNotLookLikeConfirmation() {
        val observation = TamperObservation(
            surface = TamperSurface.SETTINGS,
            eventKind = TamperEventKind.WINDOW_CHANGED,
            sourceTexts = emptyList(),
            windowTexts = listOf(
                "Info aplikasi",
                "Gamblock-AI Research",
                "Layanan",
                "Blokir notifikasi",
                "Paksa berhenti",
                "Hapus data",
            ),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.NONE, action)
    }

    @Test
    fun xiaomiForceStopConfirmationStillTriggersForceStop() {
        val observation = TamperObservation(
            surface = TamperSurface.SETTINGS,
            eventKind = TamperEventKind.WINDOW_CHANGED,
            sourceTexts = emptyList(),
            windowTexts = listOf(
                "Paksa henti?",
                "Jika Anda paksa henti suatu apl, maka apl tersebut kemungkinan tidak dapat bekerja normal.",
                "Gamblock-AI Research",
                "Batal",
                "Oke",
            ),
            targetIdentifiers = targetIdentifiers,
            launcherArmed = false,
            sourceCheckable = false,
            sourceChecked = false,
        )
        val action = TamperActionDetector.detect(observation)
        assertEquals(TamperAction.FORCE_STOP, action)
    }
}
