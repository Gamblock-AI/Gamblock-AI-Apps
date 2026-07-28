import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Opt-in, once-a-day check-in reminder (Android only). Uses an inexact daily
/// schedule — no exact-alarm permission, battery friendly, minute-level drift
/// is fine for a gentle nudge. Notification copy is neutral and contains
/// nothing sensitive for the lock screen. Windows has no reliable scheduled
/// toast path for an unpackaged exe, so the feature is hidden there.
class DailyReminderService {
  DailyReminderService._();

  static const _notificationId = 1001;
  static const _channelId = 'daily_reminder';
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static Future<void> init() async {
    if (!isSupported || _initialized) return;
    try {
      tz_data.initializeTimeZones();
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone));
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      _initialized = true;
    } catch (_) {
      // Reminders are optional; init failures must never block startup.
    }
  }

  static Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await init();
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
      await _plugin.zonedSchedule(
        _notificationId,
        l10n.reminderNotificationTitle,
        l10n.reminderNotificationBody,
        first,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            l10n.reminderChannelName,
            channelDescription: l10n.reminderChannelDesc,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            // Copy is neutral by design, so lock-screen visibility is safe.
            visibility: NotificationVisibility.public,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // A failed schedule quietly degrades to "no reminder".
    }
  }

  static Future<void> cancel() async {
    if (!isSupported) return;
    try {
      await _plugin.cancel(_notificationId);
    } catch (_) {
      // Ignore.
    }
  }
}
