import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../feedback/haptics.dart';

class AppSettings {
  const AppSettings({
    this.locale = const Locale('id'),
    this.hapticsEnabled = true,
    this.healthNotificationsEnabled = true,
    this.isLoading = true,
  });

  final Locale locale;
  final bool hapticsEnabled;
  final bool healthNotificationsEnabled;
  final bool isLoading;

  AppSettings copyWith({
    Locale? locale,
    bool? hapticsEnabled,
    bool? healthNotificationsEnabled,
    bool? isLoading,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      healthNotificationsEnabled:
          healthNotificationsEnabled ?? this.healthNotificationsEnabled,
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

  Future<void> _load() async {
    try {
      final localeCode = await _storage.read(key: _localeKey) ?? 'id';
      final haptics = await _storage.read(key: _hapticsKey) != 'false';
      final notifications =
          await _storage.read(key: _notificationsKey) != 'false';
      Haptics.enabled = haptics;
      state = AppSettings(
        locale: Locale(localeCode == 'en' ? 'en' : 'id'),
        hapticsEnabled: haptics,
        healthNotificationsEnabled: notifications,
        isLoading: false,
      );
    } catch (_) {
      Haptics.enabled = true;
      state = const AppSettings(isLoading: false);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final normalized = Locale(locale.languageCode == 'en' ? 'en' : 'id');
    await _storage.write(key: _localeKey, value: normalized.languageCode);
    state = state.copyWith(locale: normalized);
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
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
      return AppSettingsNotifier();
    });
