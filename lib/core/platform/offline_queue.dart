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
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE queue (id INTEGER PRIMARY KEY AUTOINCREMENT, method TEXT, path TEXT, data TEXT, timestamp TEXT)',
        );
        await db.execute(
          'CREATE TABLE daily_aggregates (event_date TEXT NOT NULL, event_type TEXT NOT NULL, count INTEGER NOT NULL, PRIMARY KEY (event_date, event_type))',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE daily_aggregates (event_date TEXT NOT NULL, event_type TEXT NOT NULL, count INTEGER NOT NULL, PRIMARY KEY (event_date, event_type))',
          );
        }
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
    final List<Map<String, dynamic>> queue = await db.query(
      'queue',
      orderBy: 'id ASC',
    );
    if (queue.isEmpty) return 0;

    int sent = 0;

    for (final item in queue) {
      try {
        final id = item['id'] as int;
        final method = item['method'] as String;
        final path = item['path'] as String;
        final dataStr = item['data'] as String?;
        final data = dataStr != null
            ? jsonDecode(dataStr) as Map<String, dynamic>
            : null;

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

  /// Increment a privacy-safe daily counter. No URL, domain, DOM text, or
  /// browsing timestamp is stored; only a UTC calendar date and event type.
  static Future<void> recordDailyAggregate(
    String eventType, {
    int count = 1,
  }) async {
    const allowed = {
      'intervention_shown',
      'block_count_sync',
      'tamper_detected',
      'permission_revoked',
    };
    if (!allowed.contains(eventType) || count < 0) return;
    final db = await _getDb();
    final date = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    await db.rawInsert(
      'INSERT INTO daily_aggregates (event_date, event_type, count) VALUES (?, ?, ?) '
      'ON CONFLICT(event_date, event_type) DO UPDATE SET count = count + excluded.count',
      [date, eventType, count],
    );
  }

  /// Upload completed calendar days with a deterministic idempotency key.
  /// Today's incomplete counter stays local until the next UTC day.
  static Future<int> flushCompletedDailyAggregates() async {
    final db = await _getDb();
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final rows = await db.query(
      'daily_aggregates',
      where: 'event_date < ?',
      whereArgs: [today],
      orderBy: 'event_date ASC',
    );
    var sent = 0;
    for (final row in rows) {
      final date = row['event_date'] as String;
      final type = row['event_type'] as String;
      try {
        await ApiClient.dio.post(
          '/v1/client/aggregate-events',
          data: {
            'event_type': type,
            'event_date': date,
            'count': row['count'] as int,
            'idempotency_key': 'daily_${date}_$type',
          },
        );
        await db.delete(
          'daily_aggregates',
          where: 'event_date = ? AND event_type = ?',
          whereArgs: [date, type],
        );
        sent++;
      } catch (_) {
        // Keep the aggregate locally and retry after connectivity returns.
      }
    }
    return sent;
  }

  /// Get pending queue count
  static Future<int> pendingCount() async {
    final db = await _getDb();
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM queue'),
    );
    return count ?? 0;
  }

  /// Clear all pending
  static Future<void> clear() async {
    final db = await _getDb();
    await db.delete('queue');
  }
}
