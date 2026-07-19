/// Immutable values exchanged with the Android and Windows protection bridges.
class ProtectionSnapshot {
  const ProtectionSnapshot({
    required this.platform,
    required this.status,
    required this.serviceRunning,
    required this.sensorStatus,
    required this.permissionStatus,
    required this.modelVersion,
    required this.rulesetVersion,
    this.degradedReasonCode,
    this.lastEventAt,
  });

  final String platform;
  final String status;
  final bool serviceRunning;
  final String sensorStatus;
  final String permissionStatus;
  final String modelVersion;
  final String rulesetVersion;
  final String? degradedReasonCode;
  final DateTime? lastEventAt;

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isDegraded => status == 'degraded';

  factory ProtectionSnapshot.fromMap(Map<Object?, Object?> map) {
    final lastEvent = map['last_event_at']?.toString();
    return ProtectionSnapshot(
      platform: map['platform']?.toString() ?? 'unsupported',
      status: map['status']?.toString() ?? 'inactive',
      serviceRunning: map['service_running'] == true,
      sensorStatus: map['sensor_status']?.toString() ?? 'disconnected',
      permissionStatus: map['permission_status']?.toString() ?? 'unknown',
      modelVersion:
          map['model_version']?.toString() ?? 'gamblock-lr-bfafb725511a',
      rulesetVersion:
          map['ruleset_version']?.toString() ??
          'gambling-keywords-b4f2932a7647',
      degradedReasonCode: map['degraded_reason_code']?.toString(),
      lastEventAt: lastEvent == null ? null : DateTime.tryParse(lastEvent),
    );
  }

  static const fallback = ProtectionSnapshot(
    platform: 'unsupported',
    status: 'inactive',
    serviceRunning: false,
    sensorStatus: 'disconnected',
    permissionStatus: 'unknown',
    modelVersion: 'gamblock-lr-bfafb725511a',
    rulesetVersion: 'gambling-keywords-b4f2932a7647',
    degradedReasonCode: 'native_bridge_unavailable',
  );
}

class NativeProtectionEvent {
  const NativeProtectionEvent({required this.type, required this.payload});

  final String type;
  final Map<String, dynamic> payload;

  factory NativeProtectionEvent.fromDynamic(dynamic value) {
    if (value is Map) {
      final payload = Map<String, dynamic>.from(value);
      return NativeProtectionEvent(
        type: payload.remove('type')?.toString() ?? 'unknown',
        payload: payload,
      );
    }
    return const NativeProtectionEvent(type: 'unknown', payload: {});
  }
}

class NativeDailyAggregate {
  const NativeDailyAggregate({
    required this.key,
    required this.date,
    required this.eventType,
    required this.count,
  });

  final String key;
  final String date;
  final String eventType;
  final int count;

  factory NativeDailyAggregate.fromMap(Map<Object?, Object?> map) {
    return NativeDailyAggregate(
      key: map['key']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      eventType: map['event_type']?.toString() ?? '',
      count: map['count'] is int
          ? map['count'] as int
          : int.tryParse(map['count']?.toString() ?? '') ?? 0,
    );
  }
}
