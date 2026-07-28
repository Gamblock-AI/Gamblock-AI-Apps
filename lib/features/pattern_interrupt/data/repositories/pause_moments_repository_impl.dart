import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/pause_moment.dart';
import '../../domain/repositories/pause_moments_repository.dart';

const _storageKey = 'pause_moments_v1';
const _maxEntries = 30;
const _retention = Duration(days: 30);
const _recentWindow = Duration(hours: 48);

/// Local-first pause bookkeeping. The secure-storage record is authoritative
/// for the dashboard acknowledgment; a completed grounding additionally syncs
/// best-effort as a regular recovery practice (kind + duration only, zero
/// browsing context) so the account's badges, presence rhythm, and the
/// practice mission can recognize it. Every failure is swallowed.
class PauseMomentsRepositoryImpl implements PauseMomentsRepository {
  PauseMomentsRepositoryImpl({
    FlutterSecureStorage? storage,
    Dio? dio,
    required this.isStudentSession,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _dio = dio ?? ApiClient.dio;

  final FlutterSecureStorage _storage;
  final Dio _dio;
  final bool Function() isStudentSession;

  @override
  Future<void> record(String kind, Duration elapsed) async {
    try {
      final moments = await _read();
      moments.add(PauseMoment(completedAt: DateTime.now(), kind: kind));
      await _write(moments);
    } catch (_) {
      // Bookkeeping must never break the interrupt flow.
    }
    if (kind == 'grounding' &&
        elapsed.inSeconds >= 30 &&
        elapsed.inSeconds <= 7200 &&
        isStudentSession()) {
      try {
        await _dio.post(
          '/v1/recovery-practices',
          data: {
            'practice_kind': 'grounding_54321',
            'duration_seconds': elapsed.inSeconds,
            'feedback': '',
          },
        );
      } catch (_) {
        // Offline or rejected: the local record already carries the moment.
      }
    }
  }

  @override
  Future<PauseMoment?> unacknowledgedRecent() async {
    try {
      final cutoff = DateTime.now().subtract(_recentWindow);
      final moments = await _read();
      for (final moment in moments.reversed) {
        if (!moment.acknowledged && moment.completedAt.isAfter(cutoff)) {
          return moment;
        }
      }
    } catch (_) {
      // Treated as "nothing to acknowledge".
    }
    return null;
  }

  @override
  Future<void> acknowledgeAll() async {
    try {
      final moments = await _read();
      await _write([
        for (final moment in moments) moment.copyWith(acknowledged: true),
      ]);
    } catch (_) {
      // Ignore.
    }
  }

  Future<List<PauseMoment>> _read() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    final cutoff = DateTime.now().subtract(_retention);
    return [
      for (final item in decoded)
        if (PauseMoment.fromJson(item) case final moment?)
          if (moment.completedAt.isAfter(cutoff)) moment,
    ];
  }

  Future<void> _write(List<PauseMoment> moments) async {
    final bounded = moments.length > _maxEntries
        ? moments.sublist(moments.length - _maxEntries)
        : moments;
    await _storage.write(
      key: _storageKey,
      value: jsonEncode([for (final moment in bounded) moment.toJson()]),
    );
  }
}
