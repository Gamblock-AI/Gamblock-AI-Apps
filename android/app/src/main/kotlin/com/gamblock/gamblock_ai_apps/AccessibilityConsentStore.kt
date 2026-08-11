package com.gamblock.gamblock_ai_apps

import android.content.Context

/** Versioned, device-local record of the user's Accessibility disclosure choice. */
class AccessibilityConsentStore(context: Context) {
    companion object {
        const val CURRENT_VERSION = 1
        private const val PREFS = "gamblock_accessibility_consent"
        private const val VERSION_KEY = "disclosure_version"
        private const val ACCEPTED_KEY = "accepted"
        private const val DECIDED_AT_KEY = "decided_at_epoch_ms"
    }

    private val preferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun hasCurrentConsent(): Boolean {
        return preferences.getInt(VERSION_KEY, 0) == CURRENT_VERSION &&
            preferences.getBoolean(ACCEPTED_KEY, false)
    }

    fun recordDecision(accepted: Boolean): Boolean {
        return preferences.edit()
            .putInt(VERSION_KEY, CURRENT_VERSION)
            .putBoolean(ACCEPTED_KEY, accepted)
            .putLong(DECIDED_AT_KEY, System.currentTimeMillis())
            .commit()
    }
}
