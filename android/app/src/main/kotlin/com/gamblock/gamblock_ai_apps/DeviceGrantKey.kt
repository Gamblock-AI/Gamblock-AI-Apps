package com.gamblock.gamblock_ai_apps

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.math.BigInteger
import java.nio.charset.StandardCharsets
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.MessageDigest
import java.security.Signature
import java.security.interfaces.ECPublicKey
import java.security.spec.ECGenParameterSpec
import java.util.Base64

/** Non-exportable device key used to bind backend protection grants. */
class DeviceGrantKey {
    companion object {
        private const val KEY_ALIAS = "gamblock_device_grant_key_v1"
        private const val PROOF_DOMAIN = "gamblock-device-key-v1"
        private val DEVICE_ID_PATTERN = Regex("^[A-Za-z0-9._:-]{1,128}$")
    }

    @Synchronized
    fun enrollment(deviceId: String, challengeToken: String): Map<String, String>? {
        if (!DEVICE_ID_PATTERN.matches(deviceId) || challengeToken.isBlank() || challengeToken.length > 4096) {
            return null
        }
        val keyPair = keyPair()
        val publicJwk = canonicalPublicJwk(keyPair.public as? ECPublicKey ?: return null)
        val thumbprint = base64Url(
            MessageDigest.getInstance("SHA-256").digest(
                publicJwk.toByteArray(StandardCharsets.UTF_8),
            ),
        )
        val proofPayload = "$PROOF_DOMAIN\n$deviceId\n$challengeToken"
        val signer = Signature.getInstance("SHA256withECDSA").apply {
            initSign(keyPair.private)
            update(proofPayload.toByteArray(StandardCharsets.UTF_8))
        }
        val rawProof = derSignatureToRaw(signer.sign()) ?: return null
        return mapOf(
            "public_jwk" to publicJwk,
            "jwk_thumbprint" to thumbprint,
            "proof" to base64Url(rawProof),
        )
    }

    @Synchronized
    fun jwkThumbprint(): String? {
        val publicKey = keyPair().public as? ECPublicKey ?: return null
        return base64Url(
            MessageDigest.getInstance("SHA-256").digest(
                canonicalPublicJwk(publicKey).toByteArray(StandardCharsets.UTF_8),
            ),
        )
    }

    private fun keyPair(): KeyPair {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        val existingPrivate = keyStore.getKey(KEY_ALIAS, null)
        val existingPublic = keyStore.getCertificate(KEY_ALIAS)?.publicKey
        if (existingPrivate != null && existingPublic != null) {
            return KeyPair(existingPublic, existingPrivate as java.security.PrivateKey)
        }
        val generator = KeyPairGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_EC,
            "AndroidKeyStore",
        )
        generator.initialize(
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY,
            )
                .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
                .setDigests(KeyProperties.DIGEST_SHA256)
                .setUserAuthenticationRequired(false)
                .build(),
        )
        return generator.generateKeyPair()
    }

    private fun canonicalPublicJwk(publicKey: ECPublicKey): String {
        val x = base64Url(unsignedCoordinate(publicKey.w.affineX))
        val y = base64Url(unsignedCoordinate(publicKey.w.affineY))
        // RFC 7638 requires lexicographic member order and only required members.
        return "{\"crv\":\"P-256\",\"kty\":\"EC\",\"x\":\"$x\",\"y\":\"$y\"}"
    }

    private fun unsignedCoordinate(value: BigInteger): ByteArray {
        val encoded = value.toByteArray()
        val withoutSign = if (encoded.size == 33 && encoded[0] == 0.toByte()) {
            encoded.copyOfRange(1, encoded.size)
        } else {
            encoded
        }
        require(withoutSign.size <= 32)
        return ByteArray(32).also { output ->
            withoutSign.copyInto(output, destinationOffset = 32 - withoutSign.size)
        }
    }

    private fun derSignatureToRaw(der: ByteArray): ByteArray? {
        var cursor = 0
        if (der.getOrNull(cursor++) != 0x30.toByte()) return null
        val sequenceLength = readDerLength(der, cursor) ?: return null
        cursor = sequenceLength.second
        if (cursor + sequenceLength.first != der.size) return null
        if (der.getOrNull(cursor++) != 0x02.toByte()) return null
        val rLength = readDerLength(der, cursor) ?: return null
        cursor = rLength.second
        if (cursor + rLength.first > der.size) return null
        val r = der.copyOfRange(cursor, cursor + rLength.first)
        cursor += rLength.first
        if (der.getOrNull(cursor++) != 0x02.toByte()) return null
        val sLength = readDerLength(der, cursor) ?: return null
        cursor = sLength.second
        if (cursor + sLength.first != der.size) return null
        val s = der.copyOfRange(cursor, cursor + sLength.first)
        val output = ByteArray(64)
        if (!copyUnsignedInteger(r, output, 0) || !copyUnsignedInteger(s, output, 32)) {
            return null
        }
        return output
    }

    private fun readDerLength(input: ByteArray, offset: Int): Pair<Int, Int>? {
        val first = input.getOrNull(offset)?.toInt()?.and(0xff) ?: return null
        if (first < 0x80) return first to offset + 1
        val byteCount = first and 0x7f
        if (byteCount !in 1..2 || offset + byteCount >= input.size) return null
        var length = 0
        for (index in 0 until byteCount) {
            length = (length shl 8) or input[offset + 1 + index].toInt().and(0xff)
        }
        return length to offset + 1 + byteCount
    }

    private fun copyUnsignedInteger(input: ByteArray, output: ByteArray, offset: Int): Boolean {
        var start = 0
        while (start < input.size - 1 && input[start] == 0.toByte()) start++
        val length = input.size - start
        if (length !in 1..32) return false
        input.copyInto(output, destinationOffset = offset + 32 - length, startIndex = start)
        return true
    }

    private fun base64Url(value: ByteArray): String {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value)
    }
}
