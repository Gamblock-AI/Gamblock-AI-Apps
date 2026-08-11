package com.gamblock.gamblock_ai_apps

import android.content.Context
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class DailyAggregateStore(context: Context) {
    companion object {
        private const val PREFS = "gamblock_daily_aggregates"
        private const val HOURLY_BUCKETS = 24
        private val allowedTypes = setOf(
            "intervention_shown",
            "block_count_sync",
            "tamper_detected",
            "permission_revoked",
        )
        // Hourly histograms stay aggregate counts (no URLs/domains) and feed the
        // "jam rawan" analytics on partner/admin dashboards.
        private val hourlyTypes = setOf("block_count_sync", "intervention_shown")
    }

    private val preferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    @Synchronized
    fun increment(eventType: String, count: Int = 1) {
        if (eventType !in allowedTypes || count <= 0) return
        val date = utcDate()
        val editor = preferences.edit()
        val dailyKey = "$date:$eventType"
        editor.putInt(dailyKey, preferences.getInt(dailyKey, 0) + count)
        if (eventType in hourlyTypes) {
            val hourKey = hourlyKey(date, eventType, localHour())
            editor.putInt(hourKey, preferences.getInt(hourKey, 0) + count)
        }
        editor.apply()
    }

    @Synchronized
    fun completedDays(): List<Map<String, Any>> {
        val today = utcDate()
        return preferences.all.entries.mapNotNull { (key, value) ->
            val separator = key.indexOf(':')
            if (separator <= 0 || key.substring(0, separator) >= today) return@mapNotNull null
            val remainder = key.substring(separator + 1)
            if (remainder.contains(':') || remainder !in allowedTypes || value !is Int) {
                return@mapNotNull null
            }
            val date = key.substring(0, separator)
            mapOf(
                "key" to key,
                "date" to date,
                "event_type" to remainder,
                "count" to value,
                "hourly" to hourlyFor(date, remainder),
            )
        }.sortedBy { it["key"].toString() }
    }

    @Synchronized
    fun currentDay(): List<Map<String, Any>> {
        val today = utcDate()
        return preferences.all.entries.mapNotNull { (key, value) ->
            val separator = key.indexOf(':')
            if (separator <= 0 || key.substring(0, separator) != today) return@mapNotNull null
            val remainder = key.substring(separator + 1)
            if (remainder.contains(':') || remainder !in allowedTypes || value !is Int) {
                return@mapNotNull null
            }
            mapOf(
                "key" to key,
                "date" to today,
                "event_type" to remainder,
                "count" to value,
                "hourly" to hourlyFor(today, remainder),
            )
        }
    }

    @Synchronized
    fun acknowledge(keys: List<String>) {
        val editor = preferences.edit()
        keys.forEach { key ->
            val separator = key.indexOf(':')
            val eventType = key.substringAfter(':')
            if (separator <= 0 || eventType.contains(':') || eventType !in allowedTypes) {
                return@forEach
            }
            val date = key.substring(0, separator)
            editor.remove(key)
            if (eventType in hourlyTypes) {
                for (hour in 0 until HOURLY_BUCKETS) {
                    editor.remove(hourlyKey(date, eventType, hour))
                }
            }
        }
        editor.apply()
    }

    private fun hourlyKey(date: String, eventType: String, hour: Int): String {
        return "$date:$eventType:$hour"
    }

    private fun hourlyFor(date: String, eventType: String): List<Int> {
        if (eventType !in hourlyTypes) return emptyList()
        return (0 until HOURLY_BUCKETS).map { hour ->
            preferences.getInt(hourlyKey(date, eventType, hour), 0)
        }
    }

    private fun localHour(): Int {
        return Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
    }

    private fun utcDate(): String {
        return SimpleDateFormat("yyyy-MM-dd", Locale.US).apply {
            timeZone = TimeZone.getTimeZone("UTC")
        }.format(Date())
    }
}
