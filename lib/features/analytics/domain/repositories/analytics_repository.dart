import '../entities/protection_analytics.dart';

abstract class AnalyticsRepository {
  Future<ProtectionAnalytics> fetch({
    required String deviceId,
    required int days,
  });
}
