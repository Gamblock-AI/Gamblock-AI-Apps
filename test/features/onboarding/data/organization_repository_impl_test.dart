import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gamblock_ai_apps/features/onboarding/data/repositories/organization_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late OrganizationRepositoryImpl repo;

  setUp(() {
    dio = _MockDio();
    repo = OrganizationRepositoryImpl(dio: dio);
    registerFallbackValue(RequestOptions(path: '/x'));
  });

  group('OrganizationRepositoryImpl', () {
    test('joinByGroupCode posts group_code and parses org', () async {
      when(() => dio.post('/v1/organizations/join', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 200,
          data: {
            'data': {'id': 'org_1', 'name': 'Kelas', 'slug': 'kelas', 'group_code': 'ABC123', 'status': 'active', 'members': 5},
          },
        ),
      );
      final org = await repo.joinByGroupCode('ABC123');
      expect(org.id, 'org_1');
      expect(org.groupCode, 'ABC123');
      verify(() => dio.post('/v1/organizations/join', data: {'group_code': 'ABC123'})).called(1);
    });

    test('joinByGroupCode throws when data absent', () async {
      when(() => dio.post('/v1/organizations/join', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: '/x'), statusCode: 200, data: {'data': null}),
      );
      expect(() => repo.joinByGroupCode('X'), throwsException);
    });

    test('create posts name and parses org', () async {
      when(() => dio.post('/v1/organizations', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 201,
          data: {
            'data': {'id': 'org_2', 'name': 'Kelas TI', 'slug': 'kelas-ti', 'group_code': 'XYZ', 'status': 'active', 'members': 1},
          },
        ),
      );
      final org = await repo.create(name: 'Kelas TI');
      expect(org.name, 'Kelas TI');
      verify(() => dio.post('/v1/organizations', data: {'name': 'Kelas TI'})).called(1);
    });
  });
}
