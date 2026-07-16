class ProtectionAnalyticsTotals {
  const ProtectionAnalyticsTotals({
    required this.blocked,
    required this.interventions,
    required this.tamperEvents,
    required this.permissionRevoked,
  });

  final int blocked;
  final int interventions;
  final int tamperEvents;
  final int permissionRevoked;

  ProtectionAnalyticsTotals add({
    int blocked = 0,
    int interventions = 0,
    int tamperEvents = 0,
    int permissionRevoked = 0,
  }) {
    return ProtectionAnalyticsTotals(
      blocked: this.blocked + blocked,
      interventions: this.interventions + interventions,
      tamperEvents: this.tamperEvents + tamperEvents,
      permissionRevoked: this.permissionRevoked + permissionRevoked,
    );
  }
}

class ProtectionAnalyticsDay {
  const ProtectionAnalyticsDay({
    required this.date,
    required this.blocked,
    required this.interventions,
    required this.tamperEvents,
    required this.permissionRevoked,
  });

  final DateTime date;
  final int blocked;
  final int interventions;
  final int tamperEvents;
  final int permissionRevoked;

  ProtectionAnalyticsDay add({
    int blocked = 0,
    int interventions = 0,
    int tamperEvents = 0,
    int permissionRevoked = 0,
  }) {
    return ProtectionAnalyticsDay(
      date: date,
      blocked: this.blocked + blocked,
      interventions: this.interventions + interventions,
      tamperEvents: this.tamperEvents + tamperEvents,
      permissionRevoked: this.permissionRevoked + permissionRevoked,
    );
  }

  factory ProtectionAnalyticsDay.fromJson(Map<String, dynamic> json) {
    return ProtectionAnalyticsDay(
      date:
          DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      blocked: int.tryParse(json['blocked']?.toString() ?? '') ?? 0,
      interventions: int.tryParse(json['interventions']?.toString() ?? '') ?? 0,
      tamperEvents: int.tryParse(json['tamper_events']?.toString() ?? '') ?? 0,
      permissionRevoked:
          int.tryParse(json['permission_revoked']?.toString() ?? '') ?? 0,
    );
  }
}

class ProtectionAnalytics {
  const ProtectionAnalytics({
    required this.deviceId,
    required this.periodDays,
    required this.totals,
    required this.daily,
    required this.dataState,
  });

  final String deviceId;
  final int periodDays;
  final ProtectionAnalyticsTotals totals;
  final List<ProtectionAnalyticsDay> daily;
  final String dataState;

  factory ProtectionAnalytics.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] is Map
        ? Map<String, dynamic>.from(json['totals'] as Map)
        : const <String, dynamic>{};
    return ProtectionAnalytics(
      deviceId: json['device_id']?.toString() ?? '',
      periodDays: int.tryParse(json['period_days']?.toString() ?? '') ?? 7,
      totals: ProtectionAnalyticsTotals(
        blocked: int.tryParse(totals['blocked']?.toString() ?? '') ?? 0,
        interventions:
            int.tryParse(totals['interventions']?.toString() ?? '') ?? 0,
        tamperEvents:
            int.tryParse(totals['tamper_events']?.toString() ?? '') ?? 0,
        permissionRevoked:
            int.tryParse(totals['permission_revoked']?.toString() ?? '') ?? 0,
      ),
      daily: (json['daily'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => ProtectionAnalyticsDay.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      dataState: json['data_state']?.toString() ?? 'empty',
    );
  }
}
