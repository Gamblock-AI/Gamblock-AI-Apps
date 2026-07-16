import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/analytics/domain/entities/protection_analytics.dart';

void main() {
  test('aggregate analytics parses only privacy-safe daily counters', () {
    final analytics = ProtectionAnalytics.fromJson({
      'device_id': 'device-1',
      'period_days': 7,
      'data_state': 'complete',
      'totals': {
        'blocked': 4,
        'interventions': 4,
        'tamper_events': 1,
        'permission_revoked': 0,
      },
      'daily': [
        {
          'date': '2026-07-16',
          'blocked': 4,
          'interventions': 4,
          'tamper_events': 1,
          'permission_revoked': 0,
          'url': 'must-not-be-consumed',
        },
      ],
    });

    expect(analytics.deviceId, 'device-1');
    expect(analytics.totals.blocked, 4);
    expect(analytics.daily.single.interventions, 4);
    expect(analytics.daily.single.date, DateTime.parse('2026-07-16'));
  });

  test('daily and total counters merge deterministically', () {
    const totals = ProtectionAnalyticsTotals(
      blocked: 2,
      interventions: 2,
      tamperEvents: 0,
      permissionRevoked: 0,
    );
    final day = ProtectionAnalyticsDay(
      date: DateTime.utc(2026, 7, 16),
      blocked: 2,
      interventions: 2,
      tamperEvents: 0,
      permissionRevoked: 0,
    );

    expect(totals.add(blocked: 1, tamperEvents: 1).blocked, 3);
    expect(day.add(interventions: 1).interventions, 3);
  });
}
