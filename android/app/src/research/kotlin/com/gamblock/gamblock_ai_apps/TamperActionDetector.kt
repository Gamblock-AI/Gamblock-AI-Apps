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
    /**
     * Strong uninstall tokens take precedence over weak ones so OEM dialogs
     * like MIUI's "Uninstal akan menghapus semua data aplikasi" classify as
     * UNINSTALL instead of CLEAR_DATA.
     */
    private val strongUninstallPhrases = listOf(
        "uninstall",
        "uninstal",
        "copot pemasangan",
        "copot",
        "bongkar",
        "remove app",
        "delete app",
        "hapus aplikasi",
        "hapus instalan",
        "uninstall app",
    )
    private val weakUninstallPhrases = listOf(
        "ingin mencopot",
        "ingin menghapus aplikasi",
        "mencopot pemasangan",
        "menghapus aplikasi ini",
        "menghapus aplikasi",
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
        "stop service",
        "hentikan layanan",
    )
    private val confirmationPhrases = listOf(
        "are you sure",
        "do you want to",
        "apakah anda yakin",
        "apakah kamu yakin",
        "apakah anda ingin",
        "ingin mencopot",
        "ingin menghapus aplikasi",
        "menghapus aplikasi ini",
        "konfirmasi",
        "confirm",
        "yes",
        "ya",
        "ok",
        "cancel",
        "batal",
        "batalkan",
    )
    private val accessibilityContextPhrases = listOf(
        "accessibility service",
        "layanan aksesibilitas",
        "use gamblock-ai",
        "gunakan gamblock-ai",
        "downloaded apps",
        "aplikasi yang didownload",
        "device admin",
        "admin perangkat",
        "administrator perangkat",
        "aplikasi admin",
        "deactivate",
        "nonaktifkan admin",
    )

    fun detect(observation: TamperObservation): TamperAction {
        val window = normalizedCombined(observation.windowTexts)
        val source = normalizedCombined(observation.sourceTexts)
        val targetsGamblock = containsGamblockTarget(observation.windowTexts, observation.targetIdentifiers) ||
            containsGamblockTarget(observation.sourceTexts, observation.targetIdentifiers)
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

                (observation.eventKind == TamperEventKind.WINDOW_CHANGED ||
                    observation.eventKind == TamperEventKind.CONTENT_CHANGED) &&
                    targetsGamblock && windowAction != TamperAction.NONE &&
                    isConfirmation -> windowAction

                else -> TamperAction.NONE
            }

            TamperSurface.PACKAGE_INSTALLER -> when {
                targetsGamblock && observation.eventKind == TamperEventKind.CLICK &&
                    sourceAction == TamperAction.UNINSTALL -> TamperAction.UNINSTALL

                targetsGamblock &&
                    (observation.eventKind == TamperEventKind.WINDOW_CHANGED ||
                        observation.eventKind == TamperEventKind.CONTENT_CHANGED) &&
                    windowAction == TamperAction.UNINSTALL && isConfirmation ->
                    TamperAction.UNINSTALL

                else -> TamperAction.NONE
            }

            TamperSurface.LAUNCHER -> when {
                // Clicking an uninstall button in launcher popup is valid only if
                // Gamblock was the long-pressed icon (armed) or the clicked view specifically names Gamblock.
                observation.eventKind == TamperEventKind.CLICK &&
                    sourceAction == TamperAction.UNINSTALL &&
                    (observation.launcherArmed || containsGamblockTarget(observation.sourceTexts, observation.targetIdentifiers)) ->
                    TamperAction.UNINSTALL

                // A confirmation dialog on launcher must be specifically armed OR contain a specific Gamblock uninstall prompt.
                (observation.eventKind == TamperEventKind.WINDOW_CHANGED ||
                    observation.eventKind == TamperEventKind.CONTENT_CHANGED) &&
                    (observation.launcherArmed && targetsGamblock && windowAction == TamperAction.UNINSTALL && isConfirmation ||
                        isSpecificGamblockUninstallDialog(observation.windowTexts, observation.targetIdentifiers) && isConfirmation) ->
                    TamperAction.UNINSTALL

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

    fun isSpecificGamblockUninstallDialog(
        texts: List<String>,
        targetIdentifiers: Set<String>,
    ): Boolean {
        val normalizedTargets = targetIdentifiers
            .map(::normalize)
            .filter(String::isNotBlank)
        val allUninstallPhrases = strongUninstallPhrases + weakUninstallPhrases
        return texts.any { line ->
            val normalizedLine = normalize(line)
            val hasTarget = normalizedTargets.any { target -> normalizedLine.contains(target) }
            val hasUninstall = allUninstallPhrases.any { phrase -> normalizedLine.contains(phrase) }
            hasTarget && hasUninstall
        }
    }

    private fun actionFrom(value: String): TamperAction {
        if (forceStopPhrases.any(value::contains)) return TamperAction.FORCE_STOP
        if (strongUninstallPhrases.any(value::contains)) return TamperAction.UNINSTALL
        if (clearDataPhrases.any(value::contains)) return TamperAction.CLEAR_DATA
        if (weakUninstallPhrases.any(value::contains)) return TamperAction.UNINSTALL
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
