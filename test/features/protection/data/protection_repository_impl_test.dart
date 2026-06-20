import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gamblock_ai_apps/features/protection/data/repositories/protection_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<T> _ok<T>(T data) =>
    Response<T>(requestOptions: RequestOptions(path: '/x'), statusCode: 200, data: data as dynamic);

void main() {
  late _MockDio dio;
  late ProtectionRepositoryImpl repo;

  setUp(() {
    dio = _MockDio();
    repo = ProtectionRepositoryImpl(dio: dio);
    registerFallbackValue(RequestOptions(path: '/x'));
  });

  group('ProtectionRepositoryImpl', () {
    test('fetchStatus parses mode + isActive', () async {
      when(() => dio.get('/v1/client/protection-status')).thenAnswer(
        (_) async => _ok({
          'data': {'mode': 'Active', 'runtime_status': 'ready', 'ruleset_version': 'r', 'model_version': 'm', 'last_sync': 'now'},
        }),
      );
      final s = await repo.fetchStatus();
      expect(s.isActive, isTrue);
      expect(s.modelVersion, 'm');
    });

    test('fetchSummary parses blocked attempts', () async {
      when(() => dio.get('/v1/client/dashboard-summary')).thenAnswer(
        (_) async => _ok({
          'data': {'user_name': 'G', 'protection_label': 'active', 'blocked_attempts': 7, 'active_days': 2, 'current_streak': 1},
        }),
      );
      final s = await repo.fetchSummary();
      expect(s.blockedAttempts, 7);
    });

    test('requestApproval posts the expected payload', () async {
      when(() => dio.post('/v1/approval-requests', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: '/x'), statusCode: 201, data: {'data': {'id': 'APR-1'}}),
      );
      await repo.requestApproval(action: 'pause_protection', reason: 'x', durationMinutes: 30);
      verify(() => dio.post('/v1/approval-requests', data: {
            'action': 'pause_protection',
            'reason': 'x',
            'requested_duration_minutes': 30,
          })).called(1);
    });
  });
}
