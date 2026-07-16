package com.gamblock.gamblock_ai_apps

import android.content.Context
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
        private const val KEY_ALIAS = "gamblock_approval_grant"
        private const val GRANT_KEY = "encrypted_grant"
    }

    private val preferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun setDeviceId(deviceId: String) {
        preferences.edit().putString("device_id", deviceId).apply()
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

    fun storeGrant(grant: JSONObject): Boolean {
        val action = grant.optString("action")
        val allowed = setOf(
            "pause_protection",
            "disable_protection",
            "uninstall_detected",
            "emergency_access",
        )
        val expectedDevice = deviceId()
        val expiry = parseIsoMillis(grant.optString("grant_expires_at"))
        if (
            action !in allowed ||
            expectedDevice.isEmpty() ||
            grant.optString("device_id") != expectedDevice ||
            expiry == null ||
            expiry <= System.currentTimeMillis()
        ) {
            return false
        }
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, secretKey())
        val payload = cipher.doFinal(grant.toString().toByteArray(Charsets.UTF_8))
        val packed = JSONObject().apply {
            put("iv", Base64.encodeToString(cipher.iv, Base64.NO_WRAP))
            put("payload", Base64.encodeToString(payload, Base64.NO_WRAP))
        }
        preferences.edit().putString(GRANT_KEY, packed.toString()).apply()
        return true
    }

    fun activeGrant(): JSONObject? {
        val encoded = preferences.getString(GRANT_KEY, null) ?: return null
        return try {
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
            val grant = JSONObject(String(clear, Charsets.UTF_8))
            val expiry = parseIsoMillis(grant.getString("grant_expires_at"))
            if (
                grant.optString("device_id") == deviceId() &&
                expiry != null &&
                System.currentTimeMillis() < expiry
            ) {
                grant
            } else {
                preferences.edit().remove(GRANT_KEY).apply()
                null
            }
        } catch (_: Exception) {
            preferences.edit().remove(GRANT_KEY).apply()
            null
        }
    }

    fun activeGrantAllowsSettingsAction(removal: Boolean): Boolean {
        val action = activeGrant()?.optString("action").orEmpty()
        return action == "emergency_access" ||
            (removal && action == "uninstall_detected") ||
            (!removal && action == "disable_protection")
    }

    private fun secretKey(): SecretKey {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (keyStore.getKey(KEY_ALIAS, null) as? SecretKey)?.let { return it }
        val generator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            "AndroidKeyStore",
        )
        generator.init(
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .build(),
        )
        return generator.generateKey()
    }

    private fun parseIsoMillis(value: String): Long? {
        val match = Regex(
            "^(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2})(?:\\.(\\d+))?(Z|[+-]\\d{2}:\\d{2})$",
        ).matchEntire(value) ?: return null
        val fraction = (match.groupValues[2] + "000").take(3)
        val normalized = "${match.groupValues[1]}.$fraction${match.groupValues[3]}"
        return try {
            SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX", Locale.US).apply {
                isLenient = false
            }.parse(normalized)?.time
        } catch (_: Exception) {
            null
        }
    }

    private fun isoDateFormat(): SimpleDateFormat {
        return SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
            timeZone = TimeZone.getTimeZone("UTC")
        }
    }
}
