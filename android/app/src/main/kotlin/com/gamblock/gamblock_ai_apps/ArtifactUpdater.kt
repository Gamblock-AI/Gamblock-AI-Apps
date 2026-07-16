package com.gamblock.gamblock_ai_apps

import android.content.Context
import org.json.JSONObject
import java.io.File
import java.security.MessageDigest

class ArtifactUpdater(
    private val context: Context,
    private val classifier: HybridClassifier,
    private val aggregateStore: DailyAggregateStore,
) {
    private data class UpdateResult(val success: Boolean, val updated: Boolean)

    fun check(baseUrl: String): Boolean {
        val directory = File(context.filesDir, "protection").apply { mkdirs() }
        val model = File(directory, "model.json")
        val rules = File(directory, "rules.json")
        val previousModel = model.takeIf(File::isFile)?.readBytes()
        val previousRules = rules.takeIf(File::isFile)?.readBytes()
        val modelResult = updateOne(
            baseUrl = baseUrl,
            latestPath = "/v1/releases/model/latest",
            target = model,
            expectedPlatform = "android",
        )
        val rulesResult = updateOne(
            baseUrl = baseUrl,
            latestPath = "/v1/releases/ruleset/latest",
            target = rules,
            expectedPlatform = null,
        )
        if (!modelResult.success || !rulesResult.success) {
            restore(model, previousModel)
            restore(rules, previousRules)
            classifier.load()
            return false
        }
        if ((modelResult.updated || rulesResult.updated) && !classifier.load()) {
            restore(model, previousModel)
            restore(rules, previousRules)
            classifier.load()
            return false
        }
        if (modelResult.updated) aggregateStore.increment("model_updated")
        if (rulesResult.updated) aggregateStore.increment("ruleset_updated")
        return true
    }

    private fun updateOne(
        baseUrl: String,
        latestPath: String,
        target: File,
        expectedPlatform: String?,
    ): UpdateResult {
        return try {
            val release = NativeApiClient.getJson(baseUrl, latestPath)
            val version = release.getString("version")
            val sha = release.getString("sha256").lowercase()
            val platform = release.optString("platform", "all")
            val contract = release.optString("contract_version", HybridClassifier.CONTRACT_VERSION)
            if (expectedPlatform != null && platform != "all" && platform != expectedPlatform) {
                return UpdateResult(success = false, updated = false)
            }
            if (contract != HybridClassifier.CONTRACT_VERSION) {
                return UpdateResult(success = false, updated = false)
            }
            if (target.isFile) {
                val current = JSONObject(target.readText()).optString("version")
                if (current == version) {
                    return UpdateResult(success = true, updated = false)
                }
            }
            val bytes = NativeApiClient.download(baseUrl, release.getString("download_url"))
            if (bytes.artifactSha256() != sha) {
                return UpdateResult(success = false, updated = false)
            }
            val artifact = JSONObject(String(bytes, Charsets.UTF_8))
            if (artifact.optString("contract_version") != HybridClassifier.CONTRACT_VERSION) {
                return UpdateResult(success = false, updated = false)
            }
            val temporary = File(target.parentFile, "${target.name}.tmp")
            temporary.writeBytes(bytes)
            if (!temporary.renameTo(target)) {
                temporary.copyTo(target, overwrite = true)
                temporary.delete()
            }
            UpdateResult(success = true, updated = true)
        } catch (_: Exception) {
            // An unavailable backend does not invalidate the local last-good pair.
            UpdateResult(success = true, updated = false)
        }
    }

    private fun restore(target: File, bytes: ByteArray?) {
        if (bytes == null) {
            target.delete()
        } else {
            target.writeBytes(bytes)
        }
    }
}

private fun ByteArray.artifactSha256(): String {
    return MessageDigest.getInstance("SHA-256")
        .digest(this)
        .joinToString("") { "%02x".format(it) }
}
