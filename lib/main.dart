import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/platform/platform_bridge.dart';
import 'core/platform/asset_downloader.dart';
import 'core/platform/local_notification_scheduler.dart';
import 'core/platform/offline_queue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize platform protection services
  await _initPlatformServices();

  runApp(const ProviderScope(child: GamblockApp()));
}

Future<void> _initPlatformServices() async {
  // Request accessibility permission (Android)
  await PlatformBridge.requestAccessibilityPermission();

  // Request overlay permission (Android)
  await PlatformBridge.requestOverlayPermission();

  // Enable anti-uninstall (battery optimization exemption)
  await PlatformBridge.enableAntiUninstall();

  // Start asset download in background
  AssetDownloader.downloadAll();

  // Start daily reminder scheduler (8 PM)
  LocalNotificationScheduler.start(hour: 20, minute: 0);

  // Flush offline queue if any pending requests
  OfflineQueue.flush();
}
