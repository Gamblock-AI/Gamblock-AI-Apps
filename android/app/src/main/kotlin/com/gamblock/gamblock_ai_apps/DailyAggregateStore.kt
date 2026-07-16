package com.gamblock.gamblock_ai_apps

import android.content.Context
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class DailyAggregateStore(context: Context) {
    companion object {
        private const val PREFS = "gamblock_daily_aggregates"
        private val allowedTypes = setOf(
            "intervention_shown",
            "block_count_sync",
            "tamper_detected",
            "permission_revoked",
            "model_updated",
            "ruleset_updated",
        )
    }

    private val preferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    @Synchronized
    fun increment(eventType: String, count: Int = 1) {
        if (eventType !in allowedTypes || count <= 0) return
        val date = utcDate()
        val key = "$date:$eventType"
        preferences.edit().putInt(key, preferences.getInt(key, 0) + count).apply()
    }

    @Synchronized
    fun completedDays(): List<Map<String, Any>> {
        val today = utcDate()
        return preferences.all.entries.mapNotNull { (key, value) ->
            val separator = key.indexOf(':')
            if (separator <= 0 || key.substring(0, separator) >= today) return@mapNotNull null
            val eventType = key.substring(separator + 1)
            if (eventType !in allowedTypes || value !is Int) return@mapNotNull null
            mapOf(
                "key" to key,
                "date" to key.substring(0, separator),
                "event_type" to eventType,
                "count" to value,
            )
        }.sortedBy { it["key"].toString() }
    }

    @Synchronized
    fun currentDay(): List<Map<String, Any>> {
        val today = utcDate()
        return preferences.all.entries.mapNotNull { (key, value) ->
            val separator = key.indexOf(':')
            if (separator <= 0 || key.substring(0, separator) != today) return@mapNotNull null
            val eventType = key.substring(separator + 1)
            if (eventType !in allowedTypes || value !is Int) return@mapNotNull null
            mapOf(
                "key" to key,
                "date" to today,
                "event_type" to eventType,
                "count" to value,
            )
        }
    }

    @Synchronized
    fun acknowledge(keys: List<String>) {
        val editor = preferences.edit()
        keys.filter { key ->
            val eventType = key.substringAfter(':', "")
            eventType in allowedTypes
        }.forEach(editor::remove)
        editor.apply()
    }

    private fun utcDate(): String {
        return SimpleDateFormat("yyyy-MM-dd", Locale.US).apply {
            timeZone = TimeZone.getTimeZone("UTC")
        }.format(Date())
    }
}
