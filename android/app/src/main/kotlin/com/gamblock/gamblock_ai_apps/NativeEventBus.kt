package com.gamblock.gamblock_ai_apps

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.CopyOnWriteArrayList

object NativeEventBus {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val sinks = CopyOnWriteArrayList<EventChannel.EventSink>()

    fun add(sink: EventChannel.EventSink) {
        sinks.add(sink)
    }

    fun remove(sink: EventChannel.EventSink?) {
        if (sink != null) sinks.remove(sink)
    }

    fun hasListeners(): Boolean = sinks.isNotEmpty()

    fun emit(event: Map<String, Any?>) {
        mainHandler.post {
            sinks.forEach { sink ->
                try {
                    sink.success(event)
                } catch (_: Exception) {
                    sinks.remove(sink)
                }
            }
        }
    }
}
