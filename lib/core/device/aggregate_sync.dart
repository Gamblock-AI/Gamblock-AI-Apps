import '../network/api_client.dart';
import '../platform/platform_bridge.dart';

class AggregateSync {
  AggregateSync._();

  /// Publishes the cumulative current-day rows without acknowledging them.
  /// The native store remains the source of truth until the day is complete;
  /// the backend's snapshot mode makes retries monotonic and idempotent.
  static Future<bool> flushCurrentDay(String? deviceId) async {
    if (deviceId == null || deviceId.isEmpty) return false;
    final current = await PlatformBridge.readCurrentDailyAggregates();
    if (current == null) return false;
    if (current.isEmpty) return true;
    for (final aggregate in current) {
      try {
        await ApiClient.dio.post(
          '/v1/client/aggregate-events',
          data: {
            'device_id': deviceId,
            'event_type': aggregate.eventType,
            'event_date': aggregate.date,
            'count': aggregate.count,
            'snapshot': true,
            'idempotency_key':
                'daily:$deviceId:${aggregate.date}:${aggregate.eventType}',
            if (aggregate.hourly.length == 24)
              'metadata_json': {'hourly': aggregate.hourly},
          },
        );
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  static Future<int> flushCompletedDays(String? deviceId) async {
    if (deviceId == null || deviceId.isEmpty) return 0;
    final pending = await PlatformBridge.drainDailyAggregates();
    final acknowledged = <String>[];
    for (final aggregate in pending) {
      try {
        await ApiClient.dio.post(
          '/v1/client/aggregate-events',
          data: {
            'device_id': deviceId,
            'event_type': aggregate.eventType,
            'event_date': aggregate.date,
            'count': aggregate.count,
            'idempotency_key':
                'daily:$deviceId:${aggregate.date}:${aggregate.eventType}',
            if (aggregate.hourly.length == 24)
              'metadata_json': {'hourly': aggregate.hourly},
            if (aggregate.blockedEventTimes.isNotEmpty)
              'blocked_event_times': aggregate.blockedEventTimes,
          },
        );
        acknowledged.add(aggregate.key);
      } catch (_) {
        // Keep native counters until a later authenticated sync.
      }
    }
    await PlatformBridge.ackDailyAggregates(acknowledged);
    return acknowledged.length;
  }
}
