import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../feedback/haptics.dart';
import '../notifications/daily_reminder_service.dart';

class AppSettings {
  const AppSettings({
    this.locale = const Locale('id'),
    this.hapticsEnabled = true,
    this.healthNotificationsEnabled = true,
    this.checkInReminderEnabled = false,
    this.checkInReminderTime = const TimeOfDay(hour: 19, minute: 0),
    this.isLoading = true,
  });

  final Locale locale;
  final bool hapticsEnabled;
  final bool healthNotificationsEnabled;

  /// Opt-in daily check-in reminder (Android only); defaults off. The 19:00
  /// default mirrors the web's stored reminder concept.
  final bool checkInReminderEnabled;
  final TimeOfDay checkInReminderTime;
  final bool isLoading;

  AppSettings copyWith({
    Locale? locale,
    bool? hapticsEnabled,
    bool? healthNotificationsEnabled,
    bool? checkInReminderEnabled,
    TimeOfDay? checkInReminderTime,
    bool? isLoading,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      healthNotificationsEnabled:
          healthNotificationsEnabled ?? this.healthNotificationsEnabled,
      checkInReminderEnabled:
          checkInReminderEnabled ?? this.checkInReminderEnabled,
      checkInReminderTime: checkInReminderTime ?? this.checkInReminderTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  static const _storage = FlutterSecureStorage();
  static const _localeKey = 'setting_locale';
  static const _hapticsKey = 'setting_haptics';
  static const _notificationsKey = 'setting_health_notifications';
  static const _reminderEnabledKey = 'setting_checkin_reminder';
  static const _reminderTimeKey = 'setting_checkin_reminder_time';

  static TimeOfDay _parseTime(String? raw) {
    final parts = (raw ?? '').split(':');
    final hour = parts.length == 2 ? int.tryParse(parts[0]) : null;
    final minute = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (hour == null || minute == null) {
      return const TimeOfDay(hour: 19, minute: 0);
    }
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  Future<void> _load() async {
    try {
      final localeCode = await _storage.read(key: _localeKey) ?? 'id';
      final haptics = await _storage.read(key: _hapticsKey) != 'false';
      final notifications =
          await _storage.read(key: _notificationsKey) != 'false';
      final reminderEnabled =
          await _storage.read(key: _reminderEnabledKey) == 'true';
      final reminderTime = _parseTime(
        await _storage.read(key: _reminderTimeKey),
      );
      Haptics.enabled = haptics;
      state = AppSettings(
        locale: Locale(localeCode == 'en' ? 'en' : 'id'),
        hapticsEnabled: haptics,
        healthNotificationsEnabled: notifications,
        checkInReminderEnabled: reminderEnabled,
        checkInReminderTime: reminderTime,
        isLoading: false,
      );
      if (reminderEnabled) {
        // Idempotent same-id schedule: self-heals timezone changes and
        // missed boot receivers.
        await DailyReminderService.scheduleDaily(reminderTime, state.locale);
      }
    } catch (_) {
      Haptics.enabled = true;
      state = const AppSettings(isLoading: false);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final normalized = Locale(locale.languageCode == 'en' ? 'en' : 'id');
    await _storage.write(key: _localeKey, value: normalized.languageCode);
    state = state.copyWith(locale: normalized);
    if (state.checkInReminderEnabled) {
      await DailyReminderService.scheduleDaily(
        state.checkInReminderTime,
        normalized,
      );
    }
  }

  Future<void> setHaptics(bool enabled) async {
    await _storage.write(key: _hapticsKey, value: '$enabled');
    Haptics.enabled = enabled;
    state = state.copyWith(hapticsEnabled: enabled);
  }

  Future<void> setHealthNotifications(bool enabled) async {
    await _storage.write(key: _notificationsKey, value: '$enabled');
    state = state.copyWith(healthNotificationsEnabled: enabled);
  }

  /// Returns false when enabling was refused (notification permission
  /// denied); the caller surfaces the explanation.
  Future<bool> setCheckInReminder(bool enabled) async {
    if (enabled) {
      final granted = await DailyReminderService.requestPermission();
      if (!granted) {
        await _storage.write(key: _reminderEnabledKey, value: 'false');
        state = state.copyWith(checkInReminderEnabled: false);
        return false;
      }
      await _storage.write(key: _reminderEnabledKey, value: 'true');
      state = state.copyWith(checkInReminderEnabled: true);
      await DailyReminderService.scheduleDaily(
        state.checkInReminderTime,
        state.locale,
      );
      return true;
    }
    await _storage.write(key: _reminderEnabledKey, value: 'false');
    state = state.copyWith(checkInReminderEnabled: false);
    await DailyReminderService.cancel();
    return true;
  }

  Future<void> setCheckInReminderTime(TimeOfDay time) async {
    await _storage.write(
      key: _reminderTimeKey,
      value: '${time.hour}:${time.minute}',
    );
    state = state.copyWith(checkInReminderTime: time);
    if (state.checkInReminderEnabled) {
      await DailyReminderService.scheduleDaily(time, state.locale);
    }
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
      return AppSettingsNotifier();
    });
