import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/dashboard/domain/entities/dashboard_summary.dart';

void main() {
  group('DashboardSummary.fromJson', () {
    test('parses full json', () {
      final s = DashboardSummary.fromJson({
        'user_name': 'Gading',
        'protection_label': 'active',
        'blocked_attempts': 12,
        'active_days': 7,
        'current_streak': 5,
      });
      expect(s.userName, 'Gading');
      expect(s.blockedAttempts, 12);
      expect(s.activeDays, 7);
      expect(s.currentStreak, 5);
    });
    test('coerces string ints and defaults missing', () {
      final s = DashboardSummary.fromJson({
        'blocked_attempts': '9',
      });
      expect(s.blockedAttempts, 9);
      expect(s.activeDays, 0);
      expect(s.currentStreak, 0);
      expect(s.userName, '');
    });
  });
}
