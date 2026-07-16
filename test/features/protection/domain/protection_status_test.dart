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
        rulesetVersion: 'dummy-rules-v1',
        modelVersion: 'dummy-lr-v1',
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
      rulesetVersion: 'dummy-rules-v1',
      modelVersion: 'dummy-lr-v1',
    );

    expect(status.isActive, isFalse);
    expect(status.isPaused, isTrue);
    expect(status.isDegraded, isFalse);
  });
}
