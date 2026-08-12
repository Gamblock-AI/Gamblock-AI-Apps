import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../platform/platform_info.dart';

/// Opt-in, once-a-day check-in reminder (Android and Windows).
///
/// Android uses an inexact daily `zonedSchedule` (no exact-alarm permission,
/// battery friendly, minute-level drift is fine for a gentle nudge). Windows
/// has no repeating-notification API in the plugin, so a one-shot toast is
/// scheduled for the next occurrence and re-scheduled on the next app launch
/// (the client runs at boot as the protection agent). Copy is neutral and
/// contains nothing sensitive for the lock screen.
class DailyReminderService {
  DailyReminderService._();

  static const _notificationId = 1001;
  static const _channelId = 'daily_reminder';
  static const _windowsActivatorGuid = '3f1e7d2a-8c54-4b90-9a1e-c6d0b4e5a2f3';
  static const _appUserModelId = 'GamblockAI.GamblockAIClient';
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// The device's IANA timezone id captured during init, used when saving the
  /// synced reminder preference to the backend.
  static String? localTimezone;

  /// Set by the app shell so a notification tap opens the dashboard.
  static Future<void> Function()? onNotificationTap;

  static bool get isSupported =>
      !kIsWeb && (PlatformInfo.isAndroid || PlatformInfo.isWindows);

  static Future<void> init() async {
    if (!isSupported || _initialized) return;
    try {
      tz_data.initializeTimeZones();
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      localTimezone = deviceTimezone;
      tz.setLocalLocation(tz.getLocation(deviceTimezone));
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          windows: WindowsInitializationSettings(
            appName: 'Gamblock-AI',
            appUserModelId: _appUserModelId,
            guid: _windowsActivatorGuid,
          ),
        ),
        onDidReceiveNotificationResponse: _onTap,
      );
      _initialized = true;
    } catch (_) {
      // Reminders are optional; init failures must never block startup.
    }
  }

  static Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await init();
    if (PlatformInfo.isWindows) return true;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> scheduleDaily(TimeOfDay time, Locale locale) async {
    if (!isSupported) return;
    await init();
    if (!_initialized) return;
    try {
      final l10n = lookupAppLocalizations(locale);
      final body = _rotatingBody(locale, DateTime.now());
      final now = tz.TZDateTime.now(tz.local);
      var first = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (!first.isAfter(now)) {
        first = first.add(const Duration(days: 1));
      }
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          l10n.reminderChannelName,
          channelDescription: l10n.reminderChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          // Copy is neutral by design, so lock-screen visibility is safe.
          visibility: NotificationVisibility.public,
        ),
        windows: const WindowsNotificationDetails(),
      );
      if (PlatformInfo.isWindows) {
        // Windows has no repeating notifications: schedule one shot for the
        // next occurrence. The next app launch (boot agent) re-schedules.
        await _plugin.zonedSchedule(
          _notificationId,
          l10n.reminderNotificationTitle,
          body,
          first,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        await _plugin.zonedSchedule(
          _notificationId,
          l10n.reminderNotificationTitle,
          body,
          first,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } catch (_) {
      // A failed schedule quietly degrades to "no reminder".
    }
  }

  static Future<void> cancel() async {
    if (!isSupported) return;
    try {
      await _plugin.cancel(_notificationId);
    } catch (_) {
      // Ignore; Windows cancel is a no-op for unpackaged apps.
    }
  }

  static void _onTap(NotificationResponse response) {
    onNotificationTap?.call();
  }

  /// Rotates a Duolingo-style nudge across four neutral, streak-friendly
  /// messages so the daily reminder does not become stale.
  static String _rotatingBody(Locale locale, DateTime now) {
    final l10n = lookupAppLocalizations(locale);
    final messages = [
      l10n.reminderNotificationBody,
      l10n.reminderBodyStreak,
      l10n.reminderBodyStep,
      l10n.reminderBodyConsistent,
    ];
    final dayOfYear = now.difference(DateTime(now.year)).inDays + 1;
    return messages[dayOfYear % messages.length];
  }
}
