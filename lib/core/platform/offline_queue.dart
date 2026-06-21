import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../network/api_client.dart';

/// Offline queue — stores pending API requests when the device is offline
/// and automatically syncs when connectivity returns (PRD §6.3: offline
/// reliability). Pending emergency/uninstall requests stay queued locally
/// and flush to the server once the connection is restored. Entries are
/// stored in an SQLite database for fast O(1) reads/writes.
class OfflineQueue {
  static Database? _db;

  static Future<Database> _getDb() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'offline_queue.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE queue (id INTEGER PRIMARY KEY AUTOINCREMENT, method TEXT, path TEXT, data TEXT, timestamp TEXT)',
        );
      },
    );
    return _db!;
  }

  /// Enqueue a request to be sent when online
  static Future<void> enqueue({
    required String method,
    required String path,
    Map<String, dynamic>? data,
  }) async {
    final db = await _getDb();
    await db.insert('queue', {
      'method': method,
      'path': path,
      'data': data != null ? jsonEncode(data) : null,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Attempt to flush the queue — send all pending requests
  static Future<int> flush() async {
    final db = await _getDb();
    final List<Map<String, dynamic>> queue = await db.query('queue', orderBy: 'id ASC');
    if (queue.isEmpty) return 0;

    int sent = 0;

    for (final item in queue) {
      try {
        final id = item['id'] as int;
        final method = item['method'] as String;
        final path = item['path'] as String;
        final dataStr = item['data'] as String?;
        final data = dataStr != null ? jsonDecode(dataStr) as Map<String, dynamic> : null;

        if (method == 'POST') {
          await ApiClient.dio.post(path, data: data);
        } else if (method == 'PATCH') {
          await ApiClient.dio.patch(path, data: data);
        }

        // Remove from DB immediately upon success (O(1))
        await db.delete('queue', where: 'id = ?', whereArgs: [id]);
        sent++;
      } catch (_) {
        // If it fails (e.g., still offline or server error), we leave it in the DB to try again later.
      }
    }

    return sent;
  }

  /// Get pending queue count
  static Future<int> pendingCount() async {
    final db = await _getDb();
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM queue'));
    return count ?? 0;
  }

  /// Clear all pending
  static Future<void> clear() async {
    final db = await _getDb();
    await db.delete('queue');
  }
}
