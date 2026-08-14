package com.gamblock.gamblock_ai_apps

import android.content.Context
import android.os.SystemClock
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import org.json.JSONObject
import java.security.KeyStore
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class ProtectionStateStore(private val context: Context) {
    companion object {
        private const val PREFS = "gamblock_protection_state"
        private const val ENCRYPTION_KEY_ALIAS = "gamblock_approval_grant"
        private const val GRANT_KEY = "encrypted_grant"
        private const val CLOCK_ROLLBACK_TOLERANCE_MS = 2 * 60 * 1000L

        /**
         * activeGrant() performs AES-GCM decryption plus a full JWS signature
         * verification, so frequent callers (accessibility events, Flutter
         * status polls) would pay that cost repeatedly. The result is cached
         * for a short window; storeGrant/clearGrant invalidate it. A pause or
         * emergency grant can therefore outlive its expiry by at most this TTL.
         */
        private const val GRANT_CACHE_TTL_MS = 3_000L
    }

    private val preferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    private val deviceGrantKey = DeviceGrantKey()
    private val grantVerifier = ProtectionGrantVerifier(
        BuildConfig.PROTECTION_GRANT_TRUST_STORE_BASE64,
    )

    @Volatile
    private var cachedGrant: JSONObject? = null
    @Volatile
    private var cachedGrantAtElapsedMs = 0L

    /** Binds once and remains idempotent for the same backend device ID. */
    @Synchronized
    fun setDeviceId(deviceId: String): Boolean {
        val normalized = deviceId.trim()
        if (normalized.isEmpty() || normalized.length > 128) return false
        val current = this.deviceId()
        if (current.isNotEmpty()) return current == normalized
        return preferences.edit().putString("device_id", normalized).commit()
    }

    fun deviceId(): String = preferences.getString("device_id", "") ?: ""

    fun setStatus(status: String, reasonCode: String? = null) {
        preferences.edit()
            .putString("status", status)
            .putString("degraded_reason_code", reasonCode)
            .apply()
    }

    fun status(): String = preferences.getString("status", "inactive") ?: "inactive"

    fun degradedReason(): String? = preferences.getString("degraded_reason_code", null)

    fun setLastEventNow() {
        preferences.edit().putString("last_event_at", isoDateFormat().format(Date())).apply()
    }

    fun lastEventAt(): String? = preferences.getString("last_event_at", null)

    fun grantKeyEnrollment(deviceId: String, challengeToken: String): Map<String, String>? {
        if (!setDeviceId(deviceId) || this.deviceId() != deviceId.trim()) return null
        return deviceGrantKey.enrollment(deviceId.trim(), challengeToken)
    }

    fun storeGrant(compactToken: String): Boolean {
        val expectedDevice = deviceId()
        val thumbprint = runCatching { deviceGrantKey.jwkThumbprint() }.getOrNull() ?: return false
        val nowWall = System.currentTimeMillis()
        val payload = grantVerifier.verify(
            compactToken = compactToken.trim(),
            expectedDeviceId = expectedDevice,
            expectedJwkThumbprint = thumbprint,
            nowMillis = nowWall,
        ) ?: return false
        return runCatching {
            val clearState = JSONObject().apply {
                put("token", compactToken.trim())
                put("accepted_wall_ms", nowWall)
                put("accepted_elapsed_ms", SystemClock.elapsedRealtime())
                put("action", payload.getString("action"))
            }
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(Cipher.ENCRYPT_MODE, secretKey())
            val encrypted = cipher.doFinal(clearState.toString().toByteArray(Charsets.UTF_8))
            val packed = JSONObject().apply {
                put("iv", Base64.encodeToString(cipher.iv, Base64.NO_WRAP))
                put("payload", Base64.encodeToString(encrypted, Base64.NO_WRAP))
            }
            preferences.edit().putString(GRANT_KEY, packed.toString()).commit()
        }.getOrDefault(false).also { committed ->
            if (committed) {
                cachedGrant = null
                cachedGrantAtElapsedMs = 0L
            }
        }
    }

    fun activeGrant(): JSONObject? {
        val nowElapsed = SystemClock.elapsedRealtime()
        if (nowElapsed - cachedGrantAtElapsedMs < GRANT_CACHE_TTL_MS) {
            return cachedGrant
        }
        val encoded = preferences.getString(GRANT_KEY, null) ?: run {
            cachedGrant = null
            cachedGrantAtElapsedMs = nowElapsed
            return null
        }
        val result = try {
            val packed = JSONObject(encoded)
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(
                Cipher.DECRYPT_MODE,
                secretKey(),
                GCMParameterSpec(
                    128,
                    Base64.decode(packed.getString("iv"), Base64.NO_WRAP),
                ),
            )
            val clear = cipher.doFinal(
                Base64.decode(packed.getString("payload"), Base64.NO_WRAP),
            )
            val clearState = JSONObject(String(clear, Charsets.UTF_8))
            val acceptedWall = clearState.getLong("accepted_wall_ms")
            val acceptedElapsed = clearState.getLong("accepted_elapsed_ms")
            val currentElapsed = SystemClock.elapsedRealtime()
            val currentWall = System.currentTimeMillis()
            if (currentElapsed < acceptedElapsed) {
                clearGrant()
                return null
            }
            val expectedWall = acceptedWall + (currentElapsed - acceptedElapsed)
            if (currentWall + CLOCK_ROLLBACK_TOLERANCE_MS < expectedWall) {
                clearGrant()
                return null
            }
            val thumbprint = deviceGrantKey.jwkThumbprint() ?: run {
                clearGrant()
                return null
            }
            grantVerifier.verify(
                compactToken = clearState.getString("token"),
                expectedDeviceId = deviceId(),
                expectedJwkThumbprint = thumbprint,
                nowMillis = currentWall,
            ) ?: run {
                clearGrant()
                null
            }
        } catch (_: Exception) {
            clearGrant()
            null
        }
        cachedGrant = result
        cachedGrantAtElapsedMs = SystemClock.elapsedRealtime()
        return result
    }

    fun activeGrantAllowsProtectionPause(): Boolean {
        return when (activeGrant()?.optString("action")) {
            "pause_protection", "emergency_access" -> true
            else -> false
        }
    }

    /** Only a removal/emergency window may authorize a Settings intervention.
     * A pause grant is deliberately scoped to browser protection and cannot
     * approve disabling Accessibility or force-stopping the app.
     */
    fun activeGrantAllowsSettingsAction(): Boolean {
        return when (activeGrant()?.optString("action")) {
            "emergency_access", "uninstall_detected" -> true
            else -> false
        }
    }

    private fun clearGrant() {
        preferences.edit().remove(GRANT_KEY).apply()
        cachedGrant = null
        cachedGrantAtElapsedMs = 0L
    }

    private fun secretKey(): SecretKey {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (keyStore.getKey(ENCRYPTION_KEY_ALIAS, null) as? SecretKey)?.let { return it }
        val generator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            "AndroidKeyStore",
        )
        generator.init(
            KeyGenParameterSpec.Builder(
                ENCRYPTION_KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .build(),
        )
        return generator.generateKey()
    }

    private fun isoDateFormat(): SimpleDateFormat {
        return SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
            timeZone = TimeZone.getTimeZone("UTC")
        }
    }
}
