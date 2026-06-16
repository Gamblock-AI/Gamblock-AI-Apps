import 'dart:async';

/// Schedules local reminders for user to visit psychoeducation web,
/// fill daily journal, and check missions.
class LocalNotificationScheduler {
  static Timer? _timer;

  /// Start daily reminder at specified hour (24h format)
  static void start({int hour = 20, int minute = 0}) {
    _timer?.cancel();

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final delay = scheduled.difference(now);
    _timer = Timer(delay, () {
      _showReminder();
      // Re-schedule for next day
      _timer = Timer.periodic(const Duration(hours: 24), (_) => _showReminder());
    });
  }

  static void _showReminder() {
    // Platform-specific notification will be handled by native side
    // This is a scheduler trigger — actual notification via MethodChannel
    // or flutter_local_notifications plugin
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
