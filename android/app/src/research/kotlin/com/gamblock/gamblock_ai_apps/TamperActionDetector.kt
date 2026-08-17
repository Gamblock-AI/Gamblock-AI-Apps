package com.gamblock.gamblock_ai_apps

import java.text.Normalizer
import java.util.Locale

enum class TamperAction(val wireValue: String) {
    UNINSTALL("uninstall"),
    DISABLE_ACCESSIBILITY("disable_accessibility"),
    FORCE_STOP("force_stop"),
    CLEAR_DATA("clear_data"),
    NONE("none"),
}

enum class TamperSurface {
    SETTINGS,
    PACKAGE_INSTALLER,
    LAUNCHER,
    OTHER,
}

enum class TamperEventKind {
    CLICK,
    LONG_CLICK,
    WINDOW_CHANGED,
    CONTENT_CHANGED,
    OTHER,
}

data class TamperObservation(
    val surface: TamperSurface,
    val eventKind: TamperEventKind,
    val sourceTexts: List<String>,
    val windowTexts: List<String>,
    val targetIdentifiers: Set<String>,
    val launcherArmed: Boolean,
    val sourceCheckable: Boolean,
    val sourceChecked: Boolean,
)

/**
 * Pure decision logic for Research removal friction. Android tree traversal
 * stays in the service; this detector receives only transient on-device labels
 * and never persists or emits them.
 */
object TamperActionDetector {
    private val uninstallPhrases = listOf(
        "uninstall",
        "uninstal",
        "copot pemasangan",
        "copot",
        "remove app",
        "delete app",
        "hapus aplikasi",
    )
    private val forceStopPhrases = listOf(
        "force stop",
        "paksa berhenti",
        "berhenti paksa",
    )
    private val clearDataPhrases = listOf(
        "clear data",
        "clear storage",
        "hapus data",
        "hapus semua data",
        "hapus penyimpanan",
    )
    private val disablePhrases = listOf(
        "disable",
        "turn off",
        "nonaktifkan",
        "matikan layanan",
    )
    private val confirmationPhrases = listOf(
        "are you sure",
        "do you want to",
        "apakah anda yakin",
        "apakah kamu yakin",
        "ingin mencopot",
        "konfirmasi",
        "cancel",
        "batal",
    )
    private val accessibilityContextPhrases = listOf(
        "accessibility service",
        "layanan aksesibilitas",
        "use gamblock-ai",
        "gunakan gamblock-ai",
        "downloaded apps",
        "aplikasi yang didownload",
    )

    fun detect(observation: TamperObservation): TamperAction {
        val window = normalizedCombined(observation.windowTexts)
        val source = normalizedCombined(observation.sourceTexts)
        val targetsGamblock = observation.targetIdentifiers
            .map(::normalize)
            .filter(String::isNotBlank)
            .any(window::contains)
        val sourceAction = actionFrom(source)
        val windowAction = actionFrom(window)
        val isConfirmation = confirmationPhrases.any(window::contains)
        val accessibilityToggleOff = observation.sourceCheckable &&
            !observation.sourceChecked &&
            accessibilityContextPhrases.any(window::contains)

        return when (observation.surface) {
            TamperSurface.SETTINGS -> when {
                observation.eventKind == TamperEventKind.CLICK &&
                    targetsGamblock && accessibilityToggleOff ->
                    TamperAction.DISABLE_ACCESSIBILITY

                observation.eventKind == TamperEventKind.CLICK &&
                    targetsGamblock && sourceAction != TamperAction.NONE -> sourceAction

                observation.eventKind == TamperEventKind.WINDOW_CHANGED &&
                    targetsGamblock && windowAction != TamperAction.NONE &&
                    isConfirmation -> windowAction

                else -> TamperAction.NONE
            }

            TamperSurface.PACKAGE_INSTALLER -> when {
                targetsGamblock && observation.eventKind == TamperEventKind.CLICK &&
                    sourceAction == TamperAction.UNINSTALL -> TamperAction.UNINSTALL

                targetsGamblock && observation.eventKind == TamperEventKind.WINDOW_CHANGED &&
                    windowAction == TamperAction.UNINSTALL && isConfirmation ->
                    TamperAction.UNINSTALL

                else -> TamperAction.NONE
            }

            TamperSurface.LAUNCHER -> when {
                !observation.launcherArmed -> TamperAction.NONE
                observation.eventKind == TamperEventKind.CLICK &&
                    sourceAction == TamperAction.UNINSTALL -> TamperAction.UNINSTALL

                observation.eventKind == TamperEventKind.WINDOW_CHANGED &&
                    targetsGamblock && windowAction == TamperAction.UNINSTALL &&
                    isConfirmation -> TamperAction.UNINSTALL

                else -> TamperAction.NONE
            }

            TamperSurface.OTHER -> TamperAction.NONE
        }
    }

    fun containsGamblockTarget(texts: List<String>, targetIdentifiers: Set<String>): Boolean {
        val combined = normalizedCombined(texts)
        return targetIdentifiers
            .map(::normalize)
            .filter(String::isNotBlank)
            .any(combined::contains)
    }

    private fun actionFrom(value: String): TamperAction {
        if (forceStopPhrases.any(value::contains)) return TamperAction.FORCE_STOP
        if (clearDataPhrases.any(value::contains)) return TamperAction.CLEAR_DATA
        if (uninstallPhrases.any(value::contains)) return TamperAction.UNINSTALL
        if (disablePhrases.any(value::contains)) return TamperAction.DISABLE_ACCESSIBILITY
        return TamperAction.NONE
    }

    private fun normalizedCombined(values: List<String>): String {
        return values.asSequence()
            .map(::normalize)
            .filter(String::isNotBlank)
            .joinToString(" ")
    }

    private fun normalize(value: String): String {
        val decomposed = Normalizer.normalize(value, Normalizer.Form.NFKD)
        return decomposed
            .replace(Regex("\\p{M}+"), "")
            .lowercase(Locale.ROOT)
            .replace(Regex("\\s+"), " ")
            .trim()
    }
}
