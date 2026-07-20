import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized application configuration.
///
/// Single source of truth for environment-driven settings (API base URL,
/// asset base URL, environment). Values are read from the bundled `.env` file
/// loaded in `main.dart` via `dotenv.load()`. Do not hardcode URLs elsewhere —
/// read them from here so platform/emulator differences live in `.env` only.
///
/// Note: `.env` is bundled into the app and is therefore configuration, NOT a
/// secret store. Never place real secrets in a Flutter `.env`.
class AppConfig {
  AppConfig._();

  /// Safe accessor for dotenv values that returns '' when dotenv is not yet
  /// loaded (e.g. in unit tests before load()). Avoids NotInitializedError.
  static String _env(String key) {
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      // dotenv.load() not called yet — treat as unset.
      return '';
    }
  }

  /// Backend API base URL (e.g. http://10.0.2.2:8080 for the Android emulator,
  /// http://localhost:8080 for Windows/desktop).
  static String get apiBaseUrl {
    final v = _env('API_BASE_URL');
    return v.isNotEmpty ? v : 'http://10.0.2.2:8080';
  }

  /// Public web dashboard base URL used for recovery hand-offs.
  static String get webBaseUrl {
    final v = _env('WEB_BASE_URL');
    return v.isNotEmpty ? v : 'https://gamblock-ai.com';
  }

  static Uri webUri(
    String path, {
    Map<String, String> queryParameters = const {},
  }) {
    final base = Uri.parse(
      webBaseUrl.endsWith('/') ? webBaseUrl : '$webBaseUrl/',
    );
    final resolved = base.resolve(path.replaceFirst(RegExp(r'^/'), ''));
    return resolved.replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  /// Raw APP_ENV value from `.env` (e.g. "development", "production").
  static String get appEnv => _env('APP_ENV');

  static String get googleWebClientId => _env('GOOGLE_WEB_CLIENT_ID');

  static String get googleWindowsClientId => _env('GOOGLE_WINDOWS_CLIENT_ID');

  /// Whether the app runs in production. Gates user-facing messages: production
  /// shows friendly, non-leaking text; development shows technical detail.
  ///
  /// Production is true when APP_ENV is explicitly "production" OR the app is a
  /// release build with no APP_ENV set (safe default — never leak details in a
  /// shipped binary). Development/staging/test fall back to friendly-hidden
  /// only when APP_ENV says so; otherwise release mode is treated as production.
  static bool get isProduction {
    final env = appEnv.toLowerCase();
    if (env == 'production') return true;
    if (env == 'development' ||
        env == 'staging' ||
        env == 'test' ||
        env == 'local') {
      return false;
    }
    // No explicit env: release builds are production, debug builds are dev.
    return kReleaseMode;
  }
}
