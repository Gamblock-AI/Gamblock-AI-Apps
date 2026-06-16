import 'package:flutter/services.dart';

/// Platform bridge — communicates with native Android Accessibility Service
/// and Windows Service via MethodChannels.
class PlatformBridge {
  static const _channel = MethodChannel('com.gamblock/protection');

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
      final result = await _channel.invokeMethod<bool>('isAccessibilityEnabled');
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
      final result = await _channel.invokeMethod<bool>('requestOverlayPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Start local WebSocket server for browser extension IPC (Windows only)
  static Future<bool> startWebSocketServer({int port = 9090}) async {
    try {
      final result = await _channel.invokeMethod<bool>('startWebSocket', {'port': port});
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

  /// Send heartbeat to keep alive
  static Future<void> sendHeartbeat() async {
    try {
      await _channel.invokeMethod('heartbeat');
    } catch (_) {}
  }
}
