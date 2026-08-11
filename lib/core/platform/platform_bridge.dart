import 'package:flutter/services.dart';

import 'platform_models.dart';

export 'platform_models.dart';

class PlatformBridge {
  PlatformBridge._();

  static const _channel = MethodChannel('com.gamblock/protection');
  static const _eventChannel = EventChannel('com.gamblock/intervention');

  static Stream<NativeProtectionEvent> events() {
    return _eventChannel
        .receiveBroadcastStream()
        .map(NativeProtectionEvent.fromDynamic)
        .handleError((_) {});
  }

  static Stream<NativeProtectionEvent> interventionEvents() =>
      events().where((event) => event.type == 'intervention_shown');

  static Future<ProtectionSnapshot> getProtectionSnapshot() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getProtectionSnapshot',
      );
      return result == null
          ? ProtectionSnapshot.fallback
          : ProtectionSnapshot.fromMap(result);
    } on MissingPluginException {
      return ProtectionSnapshot.fallback;
    } on PlatformException {
      return ProtectionSnapshot.fallback;
    }
  }

  static Future<bool> openPlatformSetup() => _boolMethod('openPlatformSetup');

  static Future<Map<String, dynamic>> runLocalSelfTest() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'runLocalSelfTest',
      );
      return result == null ? const {} : Map<String, dynamic>.from(result);
    } catch (_) {
      return const {
        'passed': false,
        'reason_code': 'native_bridge_unavailable',
      };
    }
  }

  static Future<bool> setHealthNotifications(bool enabled) =>
      _boolMethodWithArguments('setHealthNotifications', {'enabled': enabled});

  static Future<bool> recordInterventionCommitted(String evidenceId) {
    if (evidenceId.isEmpty) return Future.value(false);
    return _boolMethodWithArguments('recordInterventionCommitted', {
      'evidence_id': evidenceId,
    });
  }

  static Future<bool> setDeviceId(String deviceId) async {
    if (deviceId.isEmpty) return false;
    try {
      return await _channel.invokeMethod<bool>('setDeviceId', {
            'device_id': deviceId,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getGrantKeyEnrollment({
    required String deviceId,
    required String challengeToken,
  }) async {
    if (deviceId.isEmpty || challengeToken.isEmpty) return null;
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getGrantKeyEnrollment',
        {'device_id': deviceId, 'challenge_token': challengeToken},
      );
      if (result == null) return null;
      final normalized = <String, dynamic>{
        for (final entry in result.entries)
          if (entry.key != null) entry.key.toString(): entry.value,
      };
      final publicJwk = normalized['public_jwk']?.toString().trim() ?? '';
      final thumbprint =
          normalized['jwk_thumbprint']?.toString().trim() ?? '';
      final proof = normalized['proof']?.toString().trim() ?? '';
      if (publicJwk.isEmpty || thumbprint.isEmpty || proof.isEmpty) return null;
      return normalized;
    } catch (_) {
      return null;
    }
  }

  static Future<List<NativeDailyAggregate>> drainDailyAggregates() async {
    return _aggregateMethod('drainDailyAggregates');
  }

  static Future<List<NativeDailyAggregate>> getCurrentDailyAggregates() async {
    return _aggregateMethod('getCurrentDailyAggregates');
  }

  static Future<List<NativeDailyAggregate>> _aggregateMethod(
    String method,
  ) async {
    try {
      final result = await _channel.invokeMethod<List<Object?>>(method);
      return (result ?? const [])
          .whereType<Map<Object?, Object?>>()
          .map(NativeDailyAggregate.fromMap)
          .where(
            (item) =>
                item.key.isNotEmpty &&
                item.date.isNotEmpty &&
                item.eventType.isNotEmpty &&
                item.count >= 0,
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> ackDailyAggregates(List<String> keys) async {
    if (keys.isEmpty) return;
    try {
      await _channel.invokeMethod<void>('ackDailyAggregates', {'keys': keys});
    } catch (_) {}
  }

  static Future<bool> storeProtectionGrant(String grantToken) {
    final token = grantToken.trim();
    if (token.isEmpty) return Future.value(false);
    return _boolMethodWithArguments('storeProtectionGrant', {
      'grant_token': token,
    });
  }

  static Future<String?> getPairingToken() async {
    try {
      return await _channel.invokeMethod<String>('getPairingToken');
    } catch (_) {
      return null;
    }
  }

  static Future<String?> rotatePairingToken() async {
    try {
      return await _channel.invokeMethod<String>('rotatePairingToken');
    } catch (_) {
      return null;
    }
  }

  static Future<bool> _boolMethod(String method) async {
    return _boolMethodWithArguments(method, const {});
  }

  static Future<bool> _boolMethodWithArguments(
    String method,
    Map<String, dynamic> arguments,
  ) async {
    try {
      return await _channel.invokeMethod<bool>(method, arguments) ?? false;
    } catch (_) {
      return false;
    }
  }

}
