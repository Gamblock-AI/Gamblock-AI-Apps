import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/protection/domain/entities/protection_status.dart';

void main() {
  test(
    'protection status never infers active from a running service alone',
    () {
      const status = ProtectionStatus(
        platform: 'windows',
        status: 'degraded',
        serviceRunning: true,
        sensorStatus: 'disconnected',
        permissionStatus: 'granted',
        rulesetVersion: 'gambling-keywords-b4f2932a7647',
        modelVersion: 'gamblock-lr-bfafb725511a',
        degradedReasonCode: 'browser_sensor_disconnected',
      );

      expect(status.isActive, isFalse);
      expect(status.isDegraded, isTrue);
    },
  );

  test('paused is a distinct truthful state', () {
    const status = ProtectionStatus(
      platform: 'android',
      status: 'paused',
      serviceRunning: true,
      sensorStatus: 'connected',
      permissionStatus: 'granted',
      rulesetVersion: 'gambling-keywords-b4f2932a7647',
      modelVersion: 'gamblock-lr-bfafb725511a',
    );

    expect(status.isActive, isFalse);
    expect(status.isPaused, isTrue);
    expect(status.isDegraded, isFalse);
  });
}
