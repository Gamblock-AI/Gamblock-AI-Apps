import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/platform/platform_bridge.dart';
import 'core/platform/asset_downloader.dart';
import 'core/platform/local_notification_scheduler.dart';
import 'core/platform/offline_queue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration (centralized in lib/core/config/app_config.dart).
  // `.env` holds configuration only — never secrets (client-side env is not private).
  await _safe(dotenv.load);

  // Initialize the Dio client once config is available (base URL from .env).
  await ApiClient.init();

  // Initialize platform protection services. Each step is best-effort: a
  // failure on one platform (e.g. a missing native method on desktop) must not
  // crash the whole app — the UI still launches so the user can recover.
  await _initPlatformServices();

  runApp(const ProviderScope(child: GamblockApp()));
}

Future<void> _initPlatformServices() async {
  // Request accessibility permission (Android)
  await _safe(PlatformBridge.requestAccessibilityPermission);

  // Request overlay permission (Android)
  await _safe(PlatformBridge.requestOverlayPermission);

  // Enable anti-uninstall (battery optimization exemption)
  await _safe(PlatformBridge.enableAntiUninstall);

  // Start asset download in background (fire-and-forget; failures use fallback UI)
  AssetDownloader.downloadAll();

  // Start daily reminder scheduler (8 PM)
  LocalNotificationScheduler.start(hour: 20, minute: 0);

  // Flush offline queue if any pending requests (PRD §6.3 offline reliability)
  await _safe(OfflineQueue.flush);
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
