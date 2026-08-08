import '../network/api_client.dart';
import '../network/api_response.dart';

/// A snapshot of the single opt-in daily reminder preference synced through the
/// backend so the same setting applies on the web, Android, and Windows.
class ReminderPreference {
  const ReminderPreference({
    required this.enabled,
    required this.localTime,
    required this.timezone,
    required this.locale,
  });

  final bool enabled;
  final String localTime;
  final String timezone;
  final String locale;

  factory ReminderPreference.fromMap(Map<String, dynamic> data) {
    return ReminderPreference(
      enabled: data['enabled'] == true,
      localTime: data['local_time']?.toString() ?? '19:00',
      timezone: data['timezone']?.toString() ?? 'Asia/Jakarta',
      locale: data['locale']?.toString() ?? 'id',
    );
  }
}

/// Thin client for the backend reminder-preference endpoints. Failures are
/// treated as optional: the reminder remains usable offline from local state.
class ReminderPreferenceApi {
  ReminderPreferenceApi._();

  static Future<ReminderPreference?> fetch() async {
    try {
      final response = await ApiClient.dio.get('/v1/me/reminder-preference');
      final data = ApiResponse.map(response);
      if (data == null) return null;
      return ReminderPreference.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save({
    required bool enabled,
    required String localTime,
    required String timezone,
    required String locale,
  }) async {
    await ApiClient.dio.put(
      '/v1/me/reminder-preference',
      data: {
        'enabled': enabled,
        'local_time': localTime,
        'timezone': timezone,
        'locale': locale,
      },
    );
  }
}
