package com.gamblock.gamblock_ai_apps

import org.json.JSONArray
import org.json.JSONObject
import java.math.BigInteger
import java.nio.charset.StandardCharsets
import java.security.KeyFactory
import java.security.PublicKey
import java.security.Signature
import java.security.interfaces.ECPublicKey
import java.security.spec.X509EncodedKeySpec
import java.util.Base64

/** Strict verifier for compact ES256 protection grants issued by the backend. */
class ProtectionGrantVerifier(trustStoreBase64: String) {
    companion object {
        private const val EXPECTED_ISSUER = "gamblock-ai-backend"
        private const val EXPECTED_AUDIENCE = "gamblock-protection-native"
        private const val EXPECTED_TYPE = "gamblock-grant+jwt"
        private const val CLOCK_SKEW_SECONDS = 60L
        private const val MAX_TOKEN_LENGTH = 24 * 1024
        private val KEY_ID_PATTERN = Regex("^[A-Za-z0-9._-]{1,64}$")
        private val P256_ORDER = BigInteger(
            "FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551",
            16,
        )
        private val PAUSE_TTLS = setOf(15L * 60, 30L * 60, 60L * 60, 120L * 60)
    }

    private val trustedKeys: Map<String, PublicKey> = loadTrustStore(trustStoreBase64)

    fun verify(
        compactToken: String,
        expectedDeviceId: String,
        expectedJwkThumbprint: String,
        nowMillis: Long,
    ): JSONObject? {
        if (
            compactToken.isBlank() ||
            compactToken.length > MAX_TOKEN_LENGTH ||
            expectedDeviceId.isBlank() ||
            expectedJwkThumbprint.isBlank() ||
            trustedKeys.isEmpty()
        ) {
            return null
        }
        val segments = compactToken.split('.')
        if (segments.size != 3 || segments.any(String::isBlank)) return null
        val header = decodeJson(segments[0]) ?: return null
        val payload = decodeJson(segments[1]) ?: return null
        if (
            header.optString("alg") != "ES256" ||
            header.optString("typ") != EXPECTED_TYPE ||
            header.has("jku") ||
            header.has("jwk") ||
            header.has("x5u") ||
            header.has("x5c") ||
            header.has("crit")
        ) {
            return null
        }
        val keyId = header.optString("kid")
        if (!KEY_ID_PATTERN.matches(keyId)) return null
        val publicKey = trustedKeys[keyId] ?: return null
        val rawSignature = decodeBase64Url(segments[2]) ?: return null
        if (rawSignature.size != 64) return null
        val derSignature = rawSignatureToDer(rawSignature)
        val verified = runCatching {
            Signature.getInstance("SHA256withECDSA").apply {
                initVerify(publicKey)
                update("${segments[0]}.${segments[1]}".toByteArray(StandardCharsets.US_ASCII))
            }.verify(derSignature)
        }.getOrDefault(false)
        if (!verified) return null

        if (
            payload.optString("iss") != EXPECTED_ISSUER ||
            !hasExpectedAudience(payload.opt("aud")) ||
            integerClaim(payload, "grant_version") != 1L ||
            payload.optString("device_id") != expectedDeviceId
        ) {
            return null
        }
        val requestId = payload.optString("request_id")
        val tokenId = payload.optString("jti")
        if (requestId.isBlank() || requestId.length > 128 || tokenId.isBlank() || tokenId.length > 128) {
            return null
        }
        val confirmation = payload.optJSONObject("cnf") ?: return null
        if (confirmation.optString("jkt") != expectedJwkThumbprint) return null

        val issuedAt = integerClaim(payload, "iat") ?: return null
        val notBefore = integerClaim(payload, "nbf") ?: return null
        val expiresAt = integerClaim(payload, "exp") ?: return null
        val nowSeconds = nowMillis / 1000
        if (
            issuedAt > nowSeconds + CLOCK_SKEW_SECONDS ||
            notBefore > nowSeconds + CLOCK_SKEW_SECONDS ||
            notBefore < issuedAt - CLOCK_SKEW_SECONDS ||
            expiresAt <= nowSeconds ||
            expiresAt <= notBefore
        ) {
            return null
        }
        val lifetimeSeconds = expiresAt - issuedAt
        val action = payload.optString("action")
        val validLifetime = when (action) {
            "pause_protection" -> lifetimeSeconds in PAUSE_TTLS
            "uninstall_detected", "emergency_access" -> lifetimeSeconds in 1..600
            else -> false
        }
        return payload.takeIf { validLifetime }
    }

    private fun loadTrustStore(encoded: String): Map<String, PublicKey> {
        if (encoded.isBlank()) return emptyMap()
        return runCatching {
            val jsonBytes = Base64.getDecoder().decode(encoded)
            val json = JSONObject(String(jsonBytes, StandardCharsets.UTF_8))
            val keyIds = json.keys().asSequence().toList()
            if (keyIds.isEmpty() || keyIds.size > 8) return emptyMap()
            keyIds.associateWith { keyId ->
                require(KEY_ID_PATTERN.matches(keyId))
                val der = Base64.getDecoder().decode(json.getString(keyId))
                val key = KeyFactory.getInstance("EC")
                    .generatePublic(X509EncodedKeySpec(der)) as ECPublicKey
                require(key.params.curve.field.fieldSize == 256)
                require(key.params.order == P256_ORDER)
                key
            }
        }.getOrElse { emptyMap() }
    }

    private fun decodeJson(segment: String): JSONObject? {
        val decoded = decodeBase64Url(segment) ?: return null
        if (decoded.size > 16 * 1024) return null
        return runCatching {
            JSONObject(String(decoded, StandardCharsets.UTF_8))
        }.getOrNull()
    }

    private fun decodeBase64Url(segment: String): ByteArray? {
        if (!Regex("^[A-Za-z0-9_-]+$").matches(segment)) return null
        return runCatching { Base64.getUrlDecoder().decode(segment) }.getOrNull()
    }

    private fun integerClaim(json: JSONObject, name: String): Long? {
        return when (val value = json.opt(name)) {
            is Int -> value.toLong()
            is Long -> value
            else -> null
        }
    }

    private fun hasExpectedAudience(value: Any?): Boolean {
        return when (value) {
            is String -> value == EXPECTED_AUDIENCE
            is JSONArray -> value.length() == 1 &&
                value.optString(0) == EXPECTED_AUDIENCE
            else -> false
        }
    }

    private fun rawSignatureToDer(raw: ByteArray): ByteArray {
        val r = positiveDerInteger(raw.copyOfRange(0, 32))
        val s = positiveDerInteger(raw.copyOfRange(32, 64))
        val sequenceLength = 2 + r.size + 2 + s.size
        return ByteArray(2 + sequenceLength).also { output ->
            var cursor = 0
            output[cursor++] = 0x30.toByte()
            output[cursor++] = sequenceLength.toByte()
            output[cursor++] = 0x02.toByte()
            output[cursor++] = r.size.toByte()
            r.copyInto(output, cursor)
            cursor += r.size
            output[cursor++] = 0x02.toByte()
            output[cursor++] = s.size.toByte()
            s.copyInto(output, cursor)
        }
    }

    private fun positiveDerInteger(input: ByteArray): ByteArray {
        var first = 0
        while (first < input.size - 1 && input[first] == 0.toByte()) first++
        val unsigned = input.copyOfRange(first, input.size)
        return if (unsigned[0].toInt().and(0x80) != 0) {
            byteArrayOf(0) + unsigned
        } else {
            unsigned
        }
    }
}
