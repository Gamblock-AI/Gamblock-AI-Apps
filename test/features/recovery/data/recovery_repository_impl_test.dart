import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gamblock_ai_apps/features/recovery/data/repositories/recovery_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late RecoveryRepositoryImpl repo;

  setUp(() {
    dio = _MockDio();
    repo = RecoveryRepositoryImpl(dio: dio);
    registerFallbackValue(RequestOptions(path: '/x'));
  });

  test('fetchReflections maps envelope list', () async {
    when(() => dio.get('/v1/reflections')).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 200,
          data: {
            'data': [
              {'id': 'r1', 'text': 'a', 'mood': 'baik', 'created_at': '2026-06-19T00:00:00Z'},
              {'id': 'r2', 'text': 'b', 'mood': 'cemas', 'created_at': '2026-06-18T00:00:00Z'},
            ],
          },
        ));
    final list = await repo.fetchReflections();
    expect(list.length, 2);
    expect(list.first.id, 'r1');
    expect(list.last.mood, 'cemas');
  });

  test('submitReflection posts text and mood', () async {
    when(() => dio.post('/v1/reflections', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
              requestOptions: RequestOptions(path: '/x'),
              statusCode: 201,
              data: {'data': {'id': 'r3'}},
            ));
    await repo.submitReflection(text: 'refleksi', mood: 'baik');
    verify(() => dio.post('/v1/reflections', data: {'text': 'refleksi', 'mood': 'baik'})).called(1);
  });
}
