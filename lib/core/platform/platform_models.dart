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
    this.supportsControlledRemoval = false,
    this.deviceAdminActive = false,
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
  final bool supportsControlledRemoval;
  final bool deviceAdminActive;
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
          map['model_version']?.toString() ?? 'gamblock-lr-14012bec0479',
      rulesetVersion:
          map['ruleset_version']?.toString() ??
          'gambling-keywords-b4f2932a7647',
      supportsControlledRemoval: map['supports_controlled_removal'] == true,
      deviceAdminActive: map['device_admin_active'] == true,
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
    modelVersion: 'gamblock-lr-14012bec0479',
    rulesetVersion: 'gambling-keywords-b4f2932a7647',
    supportsControlledRemoval: false,
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
    this.hourly = const [],
    this.blockedEventTimes = const [],
  });

  final String key;
  final String date;
  final String eventType;
  final int count;
  final List<int> hourly;
  final List<String> blockedEventTimes;

  factory NativeDailyAggregate.fromMap(Map<Object?, Object?> map) {
    final rawHourly = map['hourly'];
    final rawTimes = map['blocked_event_times'];
    return NativeDailyAggregate(
      key: map['key']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      eventType: map['event_type']?.toString() ?? '',
      count: map['count'] is int
          ? map['count'] as int
          : int.tryParse(map['count']?.toString() ?? '') ?? 0,
      hourly: rawHourly is List
          ? rawHourly
                .whereType<Object?>()
                .map(
                  (value) => value is int
                      ? value
                      : int.tryParse(value?.toString() ?? '') ?? 0,
                )
                .take(24)
                .toList()
          : const [],
      blockedEventTimes: rawTimes is List
          ? rawTimes
                .map((value) => value?.toString() ?? '')
                .where((value) => value.isNotEmpty)
                .toList()
          : const [],
    );
  }
}
