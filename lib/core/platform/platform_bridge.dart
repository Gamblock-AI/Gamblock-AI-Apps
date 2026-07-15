import 'package:flutter/services.dart';

/// Platform bridge — communicates with the native Android Accessibility
/// Service and the Windows Service via the `com.gamblock/protection`
/// MethodChannel (PRD §3.2: anti-uninstall via Accessibility Service on
/// Android and a Windows Service on desktop).
///
/// CONTRACT: every method here must tolerate a missing native handler
/// (returns false / no-op) so the Flutter UI launches even when the
/// native side is absent or the platform is unsupported. Do not let a
/// MissingPluginException escape to the caller — catch it here.
class PlatformBridge {
  static const _channel = MethodChannel('com.gamblock/protection');
  static const _eventChannel = EventChannel('com.gamblock/intervention');

  /// Listen for intervention events from native platform
  /// The native service (Windows/Android) sends an event when a block occurs
  static Stream<void> onInterventionTriggered() {
    return _eventChannel.receiveBroadcastStream().map((_) {});
  }

  /// Check if Gamblock service is running (Windows) or
  /// Accessibility Service is enabled (Android)
  static Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isServiceRunning');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request Accessibility Service permission (Android)
  static Future<bool> requestAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestAccessibility');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Check if Accessibility Service is enabled
  static Future<bool> isAccessibilityEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isAccessibilityEnabled',
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Check if overlay permission is granted (Android)
  static Future<bool> hasOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasOverlayPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request overlay permission (Android)
  static Future<bool> requestOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'requestOverlayPermission',
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Start local WebSocket server for browser extension IPC (Windows only)
  static Future<bool> startWebSocketServer({int port = 9090}) async {
    try {
      final result = await _channel.invokeMethod<bool>('startWebSocket', {
        'port': port,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Enable anti-uninstall protection
  static Future<bool> enableAntiUninstall() async {
    try {
      final result = await _channel.invokeMethod<bool>('enableAntiUninstall');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Disable anti-uninstall protection (requires approved accountability request)
  static Future<bool> disableAntiUninstall() async {
    try {
      final result = await _channel.invokeMethod<bool>('disableAntiUninstall');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Pause protection temporarily (requires approved accountability request)
  static Future<bool> pauseProtection(int durationMinutes) async {
    try {
      final result = await _channel.invokeMethod<bool>('pauseProtection', {
        'duration_minutes': durationMinutes,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Send heartbeat to keep alive
  static Future<void> sendHeartbeat() async {
    try {
      await _channel.invokeMethod('heartbeat');
    } catch (_) {}
  }
}
