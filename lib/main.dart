import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/notifications/daily_reminder_service.dart';
import 'features/intro/data/onboarding_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Development-only: clear the onboarding-completed flag so the intro flow
  // can be re-verified. Disabled by default; production is unaffected.
  const resetOnboarding = bool.fromEnvironment('RESET_ONBOARDING');
  if (resetOnboarding) {
    await _safe(
      () => const FlutterSecureStorage().delete(key: onboardingCompletedKey),
    );
  }

  // Load environment configuration (centralized in lib/core/config/app_config.dart).
  // `.env` holds configuration only — never secrets (client-side env is not private).
  await _safe(dotenv.load);

  // Initialize the Dio client once config is available (base URL from .env).
  await ApiClient.init();

  // Optional daily-reminder plumbing (Android only; no-op elsewhere).
  await _safe(DailyReminderService.init);

  runApp(const ProviderScope(child: GamblockApp()));
}

/// Runs [action] and swallows exceptions, logging them to the debug console.
/// Platform services and config load are optional-at-startup by design: the
/// Flutter UI must always be able to launch so the user can troubleshoot.
Future<void> _safe(Future<void> Function() action) async {
  try {
    await action();
  } catch (e) {
    debugPrint('[Gamblock] init step failed: $e');
  }
}
