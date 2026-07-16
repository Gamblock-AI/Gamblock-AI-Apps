package com.gamblock.gamblock_ai_apps

import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

object NativeApiClient {
    fun getJson(baseUrl: String, path: String): JSONObject {
        val connection = connection(baseUrl, path)
        return readEnvelope(connection)
    }

    fun download(baseUrl: String, path: String): ByteArray {
        val connection = connection(baseUrl, path)
        val status = connection.responseCode
        if (status !in 200..299) {
            connection.errorStream?.close()
            throw IllegalStateException("artifact download rejected with status $status")
        }
        return connection.inputStream.use { it.readBytes() }
    }

    private fun connection(
        baseUrl: String,
        path: String,
    ): HttpURLConnection {
        val url = if (path.startsWith("http://") || path.startsWith("https://")) {
            path
        } else {
            "${baseUrl.trimEnd('/')}/${path.trimStart('/')}"
        }
        return (URL(url).openConnection() as HttpURLConnection).apply {
            requestMethod = "GET"
            connectTimeout = 10_000
            readTimeout = 15_000
            setRequestProperty("Accept", "application/json")
            setRequestProperty("Content-Type", "application/json")
        }
    }

    private fun readEnvelope(connection: HttpURLConnection): JSONObject {
        val status = connection.responseCode
        val text = (if (status in 200..299) connection.inputStream else connection.errorStream)
            ?.bufferedReader()
            ?.use { it.readText() }
            .orEmpty()
        val envelope = if (text.isBlank()) JSONObject() else JSONObject(text)
        if (status !in 200..299 || !envelope.isNull("error")) {
            val code = envelope.optJSONObject("error")?.optString("code").orEmpty()
            throw IllegalStateException(if (code.isEmpty()) "request rejected" else code)
        }
        return envelope.optJSONObject("data") ?: JSONObject()
    }
}
