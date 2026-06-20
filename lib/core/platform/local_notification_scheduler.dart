import 'dart:async';

/// Schedules local reminders for the user to visit the psychoeducation web,
/// fill the daily journal, and check missions (PRD §7.2: "notifikasi
/// pengingat lokal harian yang diatur secara internal oleh client Flutter").
///
/// LIMITATION / CONTRACT:
/// This implementation uses an in-process [Timer]. A Dart [Timer] does NOT
/// survive after the OS kills or backgrounds the app, so it cannot deliver
/// reliable daily reminders on its own. To fully satisfy PRD §7.2, integrate a
/// native local-notification plugin (e.g. `flutter_local_notifications`) that
/// schedules OS-level alarms on Android and scheduled toast/task on Windows.
/// That native integration is a TODO tracked below; until then this scheduler
/// only fires while the app process is alive.
class LocalNotificationScheduler {
  static Timer? _timer;

  /// Start a daily reminder at [hour]:[minute] (24h format).
  static void start({int hour = 20, int minute = 0}) {
    _timer?.cancel();

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has passed today, schedule for tomorrow.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final delay = scheduled.difference(now);
    _timer = Timer(delay, () {
      _showReminder();
      // Re-schedule for every following day at the same time.
      _timer = Timer.periodic(const Duration(hours: 24), (_) => _showReminder());
    });
  }

  static void _showReminder() {
    // TODO: Route through flutter_local_notifications (or the native
    // MethodChannel) to raise an OS-level notification. The current stub only
    // marks the trigger point in Dart.
    // Platform-specific notification will be handled by native side.
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
