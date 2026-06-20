import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gamblock_ai_apps/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<T> _ok<T>(T data) => Response<T>(
      requestOptions: RequestOptions(path: '/x'),
      statusCode: 200,
      data: data as dynamic,
    );

void main() {
  late _MockDio dio;
  late DashboardRepositoryImpl repo;

  setUp(() {
    dio = _MockDio();
    repo = DashboardRepositoryImpl(dio: dio);
    registerFallbackValue(RequestOptions(path: '/x'));
  });

  group('DashboardRepositoryImpl', () {
    test('fetchSummary parses envelope data', () async {
      when(() => dio.get('/v1/client/dashboard-summary')).thenAnswer(
        (_) async => _ok({
          'data': {
            'user_name': 'Gading',
            'protection_label': 'active',
            'blocked_attempts': 3,
            'active_days': 2,
            'current_streak': 1,
          },
          'error': null,
          'request_id': 'r',
        }),
      );
      final s = await repo.fetchSummary();
      expect(s.userName, 'Gading');
      expect(s.blockedAttempts, 3);
    });

    test('fetchProgress parses weekly blocks', () async {
      when(() => dio.get('/v1/client/progress')).thenAnswer(
        (_) async => _ok({
          'data': {'weekly_blocks': [0, 1, 2, 3, 4, 5, 6]},
        }),
      );
      final p = await repo.fetchProgress();
      expect(p.weeklyBlocks.length, 7);
      expect(p.weeklyBlocks.last, 6);
    });

    test('fetchProgress pads short arrays to 7', () async {
      when(() => dio.get('/v1/client/progress')).thenAnswer(
        (_) async => _ok({'data': {'weekly_blocks': [1, 2]}}),
      );
      final p = await repo.fetchProgress();
      expect(p.weeklyBlocks.length, 7);
      expect(p.weeklyBlocks[0], 1);
    });
  });
}
