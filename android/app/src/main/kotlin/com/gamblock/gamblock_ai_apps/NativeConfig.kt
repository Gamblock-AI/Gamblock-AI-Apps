package com.gamblock.gamblock_ai_apps

import android.content.Context

object NativeConfig {
    fun apiBaseUrl(context: Context): String {
        return readFlutterEnv(context)["API_BASE_URL"]
            ?.takeIf { it.startsWith("https://") || it.startsWith("http://") }
            ?: "http://10.0.2.2:8080"
    }

    fun webBaseUrl(context: Context): String {
        return readFlutterEnv(context)["WEB_BASE_URL"]
            ?.takeIf { it.startsWith("https://") || it.startsWith("http://") }
            ?: "https://gamblock-ai.vercel.app"
    }

    private fun readFlutterEnv(context: Context): Map<String, String> {
        return try {
            context.assets.open("flutter_assets/.env")
                .bufferedReader()
                .useLines { lines ->
                    lines.mapNotNull { line ->
                        val normalized = line.trim()
                        if (normalized.isEmpty() || normalized.startsWith("#") || !normalized.contains("=")) {
                            null
                        } else {
                            val key = normalized.substringBefore("=").trim()
                            val value = normalized.substringAfter("=").trim().trim('"', '\'')
                            key to value
                        }
                    }.toMap()
                }
        } catch (_: Exception) {
            emptyMap()
        }
    }
}
