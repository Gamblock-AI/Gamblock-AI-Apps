import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/platform/platform_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ProtectionSnapshot preserves raw native health state', () {
    final snapshot = ProtectionSnapshot.fromMap({
      'platform': 'windows',
      'status': 'degraded',
      'service_running': true,
      'sensor_status': 'disconnected',
      'permission_status': 'granted',
      'model_version': 'gamblock-lr-bfafb725511a',
      'ruleset_version': 'gambling-keywords-b4f2932a7647',
      'degraded_reason_code': 'browser_sensor_disconnected',
      'last_event_at': '2026-07-16T03:00:00Z',
    });

    expect(snapshot.platform, 'windows');
    expect(snapshot.isDegraded, isTrue);
    expect(snapshot.serviceRunning, isTrue);
    expect(snapshot.sensorStatus, 'disconnected');
    expect(snapshot.degradedReasonCode, 'browser_sensor_disconnected');
    expect(snapshot.lastEventAt, DateTime.utc(2026, 7, 16, 3));
  });

  test('NativeDailyAggregate rejects no fields during parsing', () {
    final aggregate = NativeDailyAggregate.fromMap({
      'key': '2026-07-16:intervention_shown',
      'date': '2026-07-16',
      'event_type': 'intervention_shown',
      'count': '3',
    });

    expect(aggregate.key, '2026-07-16:intervention_shown');
    expect(aggregate.eventType, 'intervention_shown');
    expect(aggregate.count, 3);
    expect(aggregate.hourly, isEmpty);
  });

  test('NativeDailyAggregate parses the hourly histogram', () {
    final hourly = List.generate(24, (index) => index == 3 ? 5 : 0);
    final aggregate = NativeDailyAggregate.fromMap({
      'key': '2026-07-16:block_count_sync',
      'date': '2026-07-16',
      'event_type': 'block_count_sync',
      'count': 5,
      'hourly': hourly,
    });

    expect(aggregate.hourly, hasLength(24));
    expect(aggregate.hourly[3], 5);
    expect(aggregate.hourly[0], 0);
  });

  test('storeProtectionGrant forwards only the compact signed token', () async {
    const channel = MethodChannel('com.gamblock/protection');
    MethodCall? captured;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          captured = call;
          return true;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    expect(await PlatformBridge.storeProtectionGrant('header.body.signature'), isTrue);
    expect(captured?.method, 'storeProtectionGrant');
    expect(captured?.arguments, {'grant_token': 'header.body.signature'});
  });

  test('getGrantKeyEnrollment normalizes a complete native response', () async {
    const channel = MethodChannel('com.gamblock/protection');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getGrantKeyEnrollment');
          expect(call.arguments, {
            'device_id': 'dev_123',
            'challenge_token': 'challenge',
          });
          return <String, Object?>{
            'public_jwk': '{"kty":"EC","crv":"P-256","x":"x","y":"y"}',
            'jwk_thumbprint': 'thumbprint',
            'proof': 'proof',
          };
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    final enrollment = await PlatformBridge.getGrantKeyEnrollment(
      deviceId: 'dev_123',
      challengeToken: 'challenge',
    );
    expect(enrollment?['jwk_thumbprint'], 'thumbprint');
    expect(enrollment?['proof'], 'proof');
  });
}
