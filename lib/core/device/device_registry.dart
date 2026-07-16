import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../platform/platform_bridge.dart';

class RegisteredDevice {
  const RegisteredDevice({
    required this.id,
    required this.clientInstanceId,
    required this.status,
  });

  final String id;
  final String clientInstanceId;
  final String status;
}

class DeviceRegistry {
  DeviceRegistry._();

  static const _storage = FlutterSecureStorage();
  static const _instanceKey = 'gamblock_client_instance_id';

  static String _deviceKey(String userId) => 'gamblock_device_id_$userId';

  static Future<String> clientInstanceId() async {
    final existing = await _storage.read(key: _instanceKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    final generated = base64Url.encode(bytes).replaceAll('=', '');
    await _storage.write(key: _instanceKey, value: generated);
    return generated;
  }

  static Future<String?> deviceIdFor(String? userId) async {
    if (userId == null || userId.isEmpty) return null;
    return _storage.read(key: _deviceKey(userId));
  }

  static Future<RegisteredDevice> register({
    required String userId,
    required String displayName,
  }) async {
    final instanceId = await clientInstanceId();
    final snapshot = await PlatformBridge.getProtectionSnapshot();
    final response = await ApiClient.dio.post(
      '/v1/devices',
      data: {
        'client_instance_id': instanceId,
        'platform': Platform.isWindows ? 'windows' : 'android',
        'label': displayName.isEmpty
            ? (Platform.isWindows ? 'Windows device' : 'Android device')
            : '${displayName.trim()} ${Platform.isWindows ? 'Windows' : 'Android'}',
        'app_version': '1.0.0',
        'os_version': Platform.operatingSystemVersion,
        'model_version': snapshot.modelVersion,
        'ruleset_version': snapshot.rulesetVersion,
      },
    );
    final data = ApiResponse.map(response) ?? const <String, dynamic>{};
    final deviceId = data['id']?.toString() ?? '';
    if (deviceId.isEmpty) {
      throw StateError('Backend did not return a device id');
    }
    await _storage.write(key: _deviceKey(userId), value: deviceId);
    await PlatformBridge.setDeviceId(deviceId);
    return RegisteredDevice(
      id: deviceId,
      clientInstanceId: instanceId,
      status: data['status']?.toString() ?? 'inactive',
    );
  }

  static Future<void> heartbeat(String? userId) async {
    final deviceId = await deviceIdFor(userId);
    if (deviceId == null) return;
    await PlatformBridge.setDeviceId(deviceId);
    final snapshot = await PlatformBridge.getProtectionSnapshot();
    await ApiClient.dio.patch(
      '/v1/devices/$deviceId',
      data: {
        'app_version': '1.0.0',
        'os_version': Platform.operatingSystemVersion,
        'protection_status': snapshot.status,
        'model_version': snapshot.modelVersion,
        'ruleset_version': snapshot.rulesetVersion,
      },
    );
    await ApiClient.dio.post('/v1/devices/$deviceId/heartbeat');
  }
}
