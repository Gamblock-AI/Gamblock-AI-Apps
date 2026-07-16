import '../network/api_client.dart';
import '../platform/platform_bridge.dart';

class AggregateSync {
  AggregateSync._();

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
