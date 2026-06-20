import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';

/// Offline queue — stores pending API requests when the device is offline
/// and automatically syncs when connectivity returns (PRD §6.3: offline
/// reliability). Pending emergency/uninstall requests stay queued locally
/// and flush to the server once the connection is restored. Entries are
/// stored in flutter_secure_storage (platform keychain/keystore).
class OfflineQueue {
  static const _storage = FlutterSecureStorage();
  static const _queueKey = 'offline_queue';

  /// Enqueue a request to be sent when online
  static Future<void> enqueue({
    required String method,
    required String path,
    Map<String, dynamic>? data,
  }) async {
    final current = await _readQueue();
    current.add({
      'method': method,
      'path': path,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _writeQueue(current);
  }

  /// Attempt to flush the queue — send all pending requests
  static Future<int> flush() async {
    final queue = await _readQueue();
    if (queue.isEmpty) return 0;

    int sent = 0;
    final remaining = <Map<String, dynamic>>[];

    for (final item in queue) {
      try {
        final method = item['method'] as String;
        final path = item['path'] as String;
        final data = item['data'] as Map<String, dynamic>?;

        if (method == 'POST') {
          await ApiClient.dio.post(path, data: data);
        } else if (method == 'PATCH') {
          await ApiClient.dio.patch(path, data: data);
        }
        sent++;
      } catch (_) {
        remaining.add(item);
      }
    }

    await _writeQueue(remaining);
    return sent;
  }

  /// Get pending queue count
  static Future<int> pendingCount() async {
    final queue = await _readQueue();
    return queue.length;
  }

  static Future<List<Map<String, dynamic>>> _readQueue() async {
    final raw = await _storage.read(key: _queueKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _writeQueue(List<Map<String, dynamic>> queue) async {
    await _storage.write(key: _queueKey, value: jsonEncode(queue));
  }

  /// Clear all pending
  static Future<void> clear() async {
    await _storage.delete(key: _queueKey);
  }
}
