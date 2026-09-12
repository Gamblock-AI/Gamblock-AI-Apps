package com.gamblock.gamblock_ai_apps

import android.content.Context
import android.os.SystemClock
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import org.json.JSONArray
import org.json.JSONObject
import java.security.MessageDigest
import java.security.KeyStore
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

data class PendingIntervention(
    val id: String,
    val reasonCode: String,
    val modelVersion: String,
    val rulesetVersion: String,
    val createdWallMs: Long,
    val ackDeadlineWallMs: Long,
    val expiresWallMs: Long,
    val owner: String,
) {
    fun event(): Map<String, Any?> = mapOf(
        "type" to "intervention_required",
        "intervention_id" to id,
        "reason_code" to reasonCode,
        "model_version" to modelVersion,
        "ruleset_version" to rulesetVersion,
    )
}

data class PendingInterventionAcquisition(
    val intervention: PendingIntervention,
    val created: Boolean,
)

data class InterventionVisibilityClaim(
    val accepted: Boolean,
    val newlyVisible: Boolean,
)

data class ApprovedRemovalState(
    val tokenIdDigest: String,
    val action: String,
    val expiresAtSeconds: Long,
    val stage: String,
)

class ProtectionStateStore(private val context: Context) {
    companion object {
        private const val PREFS = "gamblock_protection_state"
        private const val ENCRYPTION_KEY_ALIAS = "gamblock_approval_grant"
        private const val GRANT_KEY = "encrypted_grant"
        private const val CONSUMED_GRANTS_KEY = "encrypted_consumed_grants"
        private const val PENDING_REMOVAL_KEY = "encrypted_pending_removal"
        private const val PENDING_INTERVENTION_KEY = "pending_intervention"
        private const val PENDING_TAMPER_ACTION_KEY = "pending_tamper_action"
        private const val PENDING_TAMPER_ACTION_ID_KEY = "pending_tamper_action_id"
        private const val PENDING_TAMPER_ACTION_AT_KEY = "pending_tamper_action_at"
        private const val RUNTIME_CONNECTED_KEY = "runtime_connected"
        private const val CLOCK_ROLLBACK_TOLERANCE_MS = 2 * 60 * 1000L
        private const val INTERVENTION_TTL_MS = 30_000L
        private const val FLUTTER_ACK_TIMEOUT_MS = 2_000L
        private const val TAMPER_ATTEMPT_DEDUP_MS = 2_000L
        private const val MAX_CONSUMED_GRANTS = 64
        private const val OWNER_NONE = "none"
        private const val OWNER_FLUTTER = "flutter_visible"
        private const val OWNER_NATIVE_PENDING = "native_pending"
        private const val OWNER_NATIVE_VISIBLE = "native_visible"
        private val TAMPER_ACTIONS = setOf(
            "uninstall",
            "disable_accessibility",
            "force_stop",
            "clear_data",
        )

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

    /** Records the protection process' last lifecycle state for bridge fallback. */
    fun setRuntimeConnected(connected: Boolean) {
        preferences.edit().putBoolean(RUNTIME_CONNECTED_KEY, connected).apply()
    }

    fun runtimeConnected(): Boolean = preferences.getBoolean(RUNTIME_CONNECTED_KEY, false)

    fun setLastEventNow() {
        preferences.edit().putString("last_event_at", isoDateFormat().format(Date())).apply()
    }

    fun lastEventAt(): String? = preferences.getString("last_event_at", null)

    fun grantKeyEnrollment(deviceId: String, challengeToken: String): Map<String, String>? {
        if (!setDeviceId(deviceId) || this.deviceId() != deviceId.trim()) return null
        return deviceGrantKey.enrollment(deviceId.trim(), challengeToken)
    }

    @Synchronized
    fun storeGrant(compactToken: String): Boolean {
        if (activeApprovedRemoval() != null) return false
        val expectedDevice = deviceId()
        val thumbprint = runCatching { deviceGrantKey.jwkThumbprint() }.getOrNull() ?: return false
        val nowWall = System.currentTimeMillis()
        val payload = grantVerifier.verify(
            compactToken = compactToken.trim(),
            expectedDeviceId = expectedDevice,
            expectedJwkThumbprint = thumbprint,
            nowMillis = nowWall,
        ) ?: return false
        val tokenId = payload.optString("jti")
        if (tokenId.isBlank() || isGrantConsumed(tokenId, nowWall / 1000)) return false
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
                clearPendingTamperActionIfAllowed(payload.getString("action"))
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
            val verified = grantVerifier.verify(
                compactToken = clearState.getString("token"),
                expectedDeviceId = deviceId(),
                expectedJwkThumbprint = thumbprint,
                nowMillis = currentWall,
            ) ?: run {
                clearGrant()
                return null
            }
            if (isGrantConsumed(verified.optString("jti"), currentWall / 1000)) {
                clearGrant()
                null
            } else {
                verified
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

    /** Emergency grants can authorize non-removal recovery actions. */
    fun activeGrantAllowsTamperAction(tamperAction: String): Boolean {
        return grantAllowsTamperAction(activeGrant()?.optString("action"), tamperAction)
    }

    /**
     * Consumes an uninstall/emergency grant exactly once and creates the
     * encrypted state needed to finish Android's non-atomic admin/uninstall
     * hand-off. No compact token is retained in the pending transaction.
     */
    @Synchronized
    fun consumeControlledRemovalGrant(): ApprovedRemovalState? {
        activeApprovedRemoval()?.let { return it }
        val grant = activeGrant() ?: return null
        val action = grant.optString("action")
        if (action != "uninstall_detected" && action != "emergency_access") return null
        val tokenId = grant.optString("jti")
        val expiresAt = grant.optLong("exp", 0L)
        val now = System.currentTimeMillis() / 1000
        if (tokenId.isBlank() || expiresAt <= now) return null

        val digest = grantIdDigest(tokenId)
        val consumed = readConsumedGrants(now) ?: return null
        if (consumed.containsKey(digest)) return null
        consumed[digest] = expiresAt
        val state = ApprovedRemovalState(
            tokenIdDigest = digest,
            action = action,
            expiresAtSeconds = expiresAt,
            stage = "authorized",
        )
        val ledger = encodeConsumedGrants(consumed) ?: return null
        val pending = encryptJson(removalStateJson(state)) ?: return null
        val committed = preferences.edit()
            .putString(CONSUMED_GRANTS_KEY, ledger)
            .putString(PENDING_REMOVAL_KEY, pending)
            .remove(GRANT_KEY)
            .commit()
        if (!committed) return null
        cachedGrant = null
        cachedGrantAtElapsedMs = 0L
        return state
    }

    @Synchronized
    fun activeApprovedRemoval(): ApprovedRemovalState? {
        val encoded = preferences.getString(PENDING_REMOVAL_KEY, null) ?: return null
        val json = decryptJson(encoded)
        val state = json?.let {
            ApprovedRemovalState(
                tokenIdDigest = it.optString("jti_digest"),
                action = it.optString("action"),
                expiresAtSeconds = it.optLong("expires_at", 0L),
                stage = it.optString("stage"),
            )
        }
        if (
            state == null ||
            state.tokenIdDigest.length != 64 ||
            state.action !in setOf("uninstall_detected", "emergency_access") ||
            state.stage !in setOf("authorized", "pending_admin_deactivation", "installer_started") ||
            state.expiresAtSeconds <= System.currentTimeMillis() / 1000
        ) {
            preferences.edit().remove(PENDING_REMOVAL_KEY).commit()
            return null
        }
        return state
    }

    fun hasApprovedRemovalPending(): Boolean = activeApprovedRemoval() != null

    @Synchronized
    fun updateApprovedRemovalStage(stage: String): Boolean {
        if (stage !in setOf("authorized", "pending_admin_deactivation", "installer_started")) {
            return false
        }
        val current = activeApprovedRemoval() ?: return false
        val encoded = encryptJson(removalStateJson(current.copy(stage = stage))) ?: return false
        return preferences.edit().putString(PENDING_REMOVAL_KEY, encoded).commit()
    }

    fun clearApprovedRemoval() {
        preferences.edit().remove(PENDING_REMOVAL_KEY).apply()
    }

    /**
     * Coalesces classifier bursts into one durable intervention. The same
     * opaque ID is replayed after a Flutter cold start; a new ID is allocated
     * only after completion or the 30-second safety TTL.
     */
    @Synchronized
    fun acquireIntervention(
        reasonCode: String,
        modelVersion: String,
        rulesetVersion: String,
    ): PendingInterventionAcquisition {
        activeIntervention()?.let {
            return PendingInterventionAcquisition(it, created = false)
        }
        val now = System.currentTimeMillis()
        val intervention = PendingIntervention(
            id = java.util.UUID.randomUUID().toString(),
            reasonCode = reasonCode.take(96),
            modelVersion = modelVersion.take(128),
            rulesetVersion = rulesetVersion.take(128),
            createdWallMs = now,
            ackDeadlineWallMs = now + FLUTTER_ACK_TIMEOUT_MS,
            expiresWallMs = now + INTERVENTION_TTL_MS,
            owner = OWNER_NONE,
        )
        writeIntervention(intervention, visibleRecorded = false)
        return PendingInterventionAcquisition(intervention, created = true)
    }

    @Synchronized
    fun activeIntervention(): PendingIntervention? {
        val encoded = preferences.getString(PENDING_INTERVENTION_KEY, null) ?: return null
        val parsed = runCatching {
            val json = JSONObject(encoded)
            PendingIntervention(
                id = json.getString("id"),
                reasonCode = json.optString("reason_code").take(96),
                modelVersion = json.optString("model_version").take(128),
                rulesetVersion = json.optString("ruleset_version").take(128),
                createdWallMs = json.getLong("created_wall_ms"),
                ackDeadlineWallMs = json.getLong("ack_deadline_wall_ms"),
                expiresWallMs = json.getLong("expires_wall_ms"),
                owner = json.optString("owner", OWNER_NONE),
            )
        }.getOrNull()
        if (
            parsed == null ||
            parsed.id.isBlank() ||
            parsed.expiresWallMs <= System.currentTimeMillis()
        ) {
            preferences.edit().remove(PENDING_INTERVENTION_KEY).commit()
            return null
        }
        return parsed
    }

    @Synchronized
    fun claimFlutterVisibility(interventionId: String): InterventionVisibilityClaim {
        val current = activeIntervention()
            ?: return InterventionVisibilityClaim(accepted = false, newlyVisible = false)
        if (current.id != interventionId) {
            return InterventionVisibilityClaim(accepted = false, newlyVisible = false)
        }
        if (current.owner == OWNER_FLUTTER) {
            return InterventionVisibilityClaim(accepted = true, newlyVisible = false)
        }
        if (current.owner != OWNER_NONE) {
            return InterventionVisibilityClaim(accepted = false, newlyVisible = false)
        }
        val visibleRecorded = interventionVisibleRecorded()
        writeIntervention(current.copy(owner = OWNER_FLUTTER), visibleRecorded = true)
        return InterventionVisibilityClaim(accepted = true, newlyVisible = !visibleRecorded)
    }

    /** Reserves presentation for native before addView, rejecting late Flutter ACKs. */
    @Synchronized
    fun claimNativeOwnership(interventionId: String): Boolean {
        val current = activeIntervention() ?: return false
        if (current.id != interventionId) return false
        if (current.owner == OWNER_FLUTTER) return false
        if (current.owner == OWNER_NONE) {
            writeIntervention(current.copy(owner = OWNER_NATIVE_PENDING), interventionVisibleRecorded())
        }
        return true
    }

    /** Returns true exactly once, after the native overlay's first draw. */
    @Synchronized
    fun markNativeVisible(interventionId: String): Boolean {
        val current = activeIntervention() ?: return false
        if (
            current.id != interventionId ||
            current.owner !in setOf(OWNER_NATIVE_PENDING, OWNER_NATIVE_VISIBLE)
        ) {
            return false
        }
        val alreadyRecorded = interventionVisibleRecorded()
        writeIntervention(current.copy(owner = OWNER_NATIVE_VISIBLE), visibleRecorded = true)
        return !alreadyRecorded
    }

    @Synchronized
    fun releaseUncommittedNativeOwnership(interventionId: String) {
        val current = activeIntervention() ?: return
        if (current.id == interventionId && current.owner == OWNER_NATIVE_PENDING) {
            writeIntervention(current.copy(owner = OWNER_NONE), interventionVisibleRecorded())
        }
    }

    /**
     * A Flutter engine can disappear while the Accessibility Service remains.
     * Releasing only its presentation ownership lets the same durable ID be
     * replayed without recording a second visible aggregate.
     */
    @Synchronized
    fun releaseFlutterOwnershipForReplay(interventionId: String): PendingIntervention? {
        val current = activeIntervention() ?: return null
        if (current.id != interventionId || current.owner != OWNER_FLUTTER) return null
        val released = current.copy(
            ackDeadlineWallMs = minOf(
                System.currentTimeMillis() + FLUTTER_ACK_TIMEOUT_MS,
                current.expiresWallMs,
            ),
            owner = OWNER_NONE,
        )
        writeIntervention(released, interventionVisibleRecorded())
        return released
    }

    @Synchronized
    fun completeIntervention(interventionId: String): Boolean {
        val current = activeIntervention() ?: return false
        if (current.id != interventionId) return false
        return preferences.edit().remove(PENDING_INTERVENTION_KEY).commit()
    }

    /** Handler deadlines use elapsed realtime, so wall-clock edits cannot extend the TTL. */
    @Synchronized
    fun expireIntervention(interventionId: String): Boolean {
        val encoded = preferences.getString(PENDING_INTERVENTION_KEY, null) ?: return false
        val storedId = runCatching { JSONObject(encoded).optString("id") }.getOrNull()
        if (storedId != interventionId) return false
        return preferences.edit().remove(PENDING_INTERVENTION_KEY).commit()
    }

    @Synchronized
    fun recordPendingTamperAction(tamperAction: String): Boolean {
        if (tamperAction !in TAMPER_ACTIONS) return false
        val current = pendingTamperAction()
        val now = System.currentTimeMillis()
        val lastRecordedAt = preferences.getLong(PENDING_TAMPER_ACTION_AT_KEY, 0L)
        if (
            current == tamperAction &&
            now >= lastRecordedAt &&
            now - lastRecordedAt < TAMPER_ATTEMPT_DEDUP_MS
        ) {
            ensurePendingTamperActionId()
            return false
        }
        return preferences.edit()
            .putString(PENDING_TAMPER_ACTION_KEY, tamperAction)
            .putString(PENDING_TAMPER_ACTION_ID_KEY, java.util.UUID.randomUUID().toString())
            .putLong(PENDING_TAMPER_ACTION_AT_KEY, now)
            .commit()
    }

    fun pendingTamperAction(): String? {
        return preferences.getString(PENDING_TAMPER_ACTION_KEY, null)
            ?.takeIf(TAMPER_ACTIONS::contains)
    }

    fun pendingApprovalEvent(): Map<String, Any?>? {
        val action = pendingTamperAction() ?: return null
        return mapOf(
            "type" to "approval_required",
            "tamper_action" to action,
            "action_id" to ensurePendingTamperActionId(),
        )
    }

    fun clearPendingTamperAction() {
        preferences.edit()
            .remove(PENDING_TAMPER_ACTION_KEY)
            .remove(PENDING_TAMPER_ACTION_ID_KEY)
            .remove(PENDING_TAMPER_ACTION_AT_KEY)
            .apply()
    }

    private fun clearPendingTamperActionIfAllowed(grantAction: String) {
        val pendingAction = pendingTamperAction() ?: return
        if (grantAllowsTamperAction(grantAction, pendingAction)) {
            clearPendingTamperAction()
        }
    }

    private fun grantAllowsTamperAction(grantAction: String?, tamperAction: String): Boolean {
        return when (tamperAction) {
            "uninstall" -> grantAction == "uninstall_detected" || grantAction == "emergency_access"
            "disable_accessibility", "force_stop", "clear_data" -> grantAction == "emergency_access"
            else -> false
        }
    }

    @Synchronized
    private fun ensurePendingTamperActionId(): String {
        preferences.getString(PENDING_TAMPER_ACTION_ID_KEY, null)
            ?.takeIf(String::isNotBlank)
            ?.let { return it }
        val actionId = java.util.UUID.randomUUID().toString()
        preferences.edit().putString(PENDING_TAMPER_ACTION_ID_KEY, actionId).commit()
        return actionId
    }

    private fun interventionVisibleRecorded(): Boolean {
        val encoded = preferences.getString(PENDING_INTERVENTION_KEY, null) ?: return false
        return runCatching { JSONObject(encoded).optBoolean("visible_recorded", false) }
            .getOrDefault(false)
    }

    private fun writeIntervention(
        intervention: PendingIntervention,
        visibleRecorded: Boolean,
    ) {
        val encoded = JSONObject().apply {
            put("id", intervention.id)
            put("reason_code", intervention.reasonCode)
            put("model_version", intervention.modelVersion)
            put("ruleset_version", intervention.rulesetVersion)
            put("created_wall_ms", intervention.createdWallMs)
            put("ack_deadline_wall_ms", intervention.ackDeadlineWallMs)
            put("expires_wall_ms", intervention.expiresWallMs)
            put("owner", intervention.owner)
            put("visible_recorded", visibleRecorded)
        }.toString()
        preferences.edit().putString(PENDING_INTERVENTION_KEY, encoded).commit()
    }

    private fun clearGrant() {
        preferences.edit().remove(GRANT_KEY).apply()
        cachedGrant = null
        cachedGrantAtElapsedMs = 0L
    }

    private fun isGrantConsumed(tokenId: String, now: Long): Boolean {
        if (tokenId.isBlank()) return true
        val consumed = readConsumedGrants(now) ?: return true
        return consumed.containsKey(grantIdDigest(tokenId))
    }

    private fun readConsumedGrants(now: Long): MutableMap<String, Long>? {
        val encoded = preferences.getString(CONSUMED_GRANTS_KEY, null) ?: return mutableMapOf()
        val values = decryptJson(encoded)?.optJSONArray("items") ?: return null
        val result = mutableMapOf<String, Long>()
        for (index in 0 until values.length()) {
            val item = values.optJSONObject(index) ?: continue
            val digest = item.optString("digest")
            val expiresAt = item.optLong("expires_at", 0L)
            if (digest.length == 64 && expiresAt > now) result[digest] = expiresAt
        }
        return result
    }

    private fun encodeConsumedGrants(values: Map<String, Long>): String? {
        val items = JSONArray()
        values.entries
            .sortedByDescending { it.value }
            .take(MAX_CONSUMED_GRANTS)
            .forEach { (digest, expiresAt) ->
                items.put(JSONObject().apply {
                    put("digest", digest)
                    put("expires_at", expiresAt)
                })
            }
        return encryptJson(JSONObject().put("items", items))
    }

    private fun removalStateJson(state: ApprovedRemovalState): JSONObject {
        return JSONObject().apply {
            put("jti_digest", state.tokenIdDigest)
            put("action", state.action)
            put("expires_at", state.expiresAtSeconds)
            put("stage", state.stage)
        }
    }

    private fun encryptJson(value: JSONObject): String? {
        return runCatching {
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(Cipher.ENCRYPT_MODE, secretKey())
            val encrypted = cipher.doFinal(value.toString().toByteArray(Charsets.UTF_8))
            JSONObject().apply {
                put("iv", Base64.encodeToString(cipher.iv, Base64.NO_WRAP))
                put("payload", Base64.encodeToString(encrypted, Base64.NO_WRAP))
            }.toString()
        }.getOrNull()
    }

    private fun decryptJson(encoded: String): JSONObject? {
        return runCatching {
            val packed = JSONObject(encoded)
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(
                Cipher.DECRYPT_MODE,
                secretKey(),
                GCMParameterSpec(128, Base64.decode(packed.getString("iv"), Base64.NO_WRAP)),
            )
            val clear = cipher.doFinal(Base64.decode(packed.getString("payload"), Base64.NO_WRAP))
            JSONObject(String(clear, Charsets.UTF_8))
        }.getOrNull()
    }

    private fun grantIdDigest(tokenId: String): String {
        val bytes = MessageDigest.getInstance("SHA-256")
            .digest(tokenId.toByteArray(Charsets.UTF_8))
        val digits = "0123456789abcdef"
        return buildString(bytes.size * 2) {
            bytes.forEach { byte ->
                val value = byte.toInt() and 0xff
                append(digits[value ushr 4])
                append(digits[value and 0x0f])
            }
        }
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
