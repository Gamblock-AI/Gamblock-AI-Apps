import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/platform/platform_bridge.dart';
import '../../domain/entities/protection_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  @override
  Future<ProtectionAnalytics> fetch({
    required String deviceId,
    required int days,
  }) async {
    ProtectionAnalytics server;
    try {
      final response = await _dio.get(
        '/v1/client/protection-analytics',
        queryParameters: {'device_id': deviceId, 'days': days},
      );
      server = ProtectionAnalytics.fromJson(
        ApiResponse.map(response) ?? const {},
      );
    } catch (_) {
      final today = DateTime.now().toUtc();
      server = ProtectionAnalytics(
        deviceId: deviceId,
        periodDays: days,
        totals: const ProtectionAnalyticsTotals(
          blocked: 0,
          interventions: 0,
          tamperEvents: 0,
          permissionRevoked: 0,
        ),
        daily: List.generate(days, (index) {
          final date = DateTime.utc(
            today.year,
            today.month,
            today.day,
          ).subtract(Duration(days: days - index - 1));
          return ProtectionAnalyticsDay(
            date: date,
            blocked: 0,
            interventions: 0,
            tamperEvents: 0,
            permissionRevoked: 0,
          );
        }),
        dataState: 'local_only',
      );
    }

    // Reconcile the local cumulative row with the server's current-day
    // snapshot. This remains correct when a multi-row sync partially succeeds:
    // only the unsynced local delta is added, never the whole row again.
    final current = await PlatformBridge.getCurrentDailyAggregates();
    if (current.isEmpty) return server;

    final daysByDate = <String, ProtectionAnalyticsDay>{
      for (final day in server.daily)
        day.date.toUtc().toIso8601String().substring(0, 10): day,
    };
    var totals = server.totals;
    for (final item in current) {
      final day = daysByDate[item.date];
      if (day == null) continue;
      final block = item.eventType == 'block_count_sync'
          ? _positiveDelta(item.count, day.blocked)
          : 0;
      final intervention = item.eventType == 'intervention_shown'
          ? _positiveDelta(item.count, day.interventions)
          : 0;
      final tamper = item.eventType == 'tamper_detected'
          ? _positiveDelta(item.count, day.tamperEvents)
          : 0;
      final permission = item.eventType == 'permission_revoked'
          ? _positiveDelta(item.count, day.permissionRevoked)
          : 0;
      daysByDate[item.date] = day.add(
        blocked: block,
        interventions: intervention,
        tamperEvents: tamper,
        permissionRevoked: permission,
      );
      totals = totals.add(
        blocked: block,
        interventions: intervention,
        tamperEvents: tamper,
        permissionRevoked: permission,
      );
    }
    return ProtectionAnalytics(
      deviceId: server.deviceId,
      periodDays: server.periodDays,
      totals: totals,
      daily: server.daily
          .map(
            (day) =>
                daysByDate[day.date.toUtc().toIso8601String().substring(
                  0,
                  10,
                )] ??
                day,
          )
          .toList(),
      dataState: server.dataState == 'empty' ? 'local_only' : server.dataState,
    );
  }

  int _positiveDelta(int localCount, int serverCount) {
    final delta = localCount - serverCount;
    return delta > 0 ? delta : 0;
  }
}
