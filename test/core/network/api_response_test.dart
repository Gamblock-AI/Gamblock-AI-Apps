import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/network/api_response.dart';

void main() {
  group('ApiResponse.map', () {
    test('extracts data field from envelope', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        data: {'data': {'a': 1}, 'error': null, 'request_id': 'r1'},
      );
      expect(ApiResponse.map(res), {'a': 1});
    });
    test('returns null when no data field', () {
      final res = Response(requestOptions: RequestOptions(path: '/x'), data: {'foo': 1});
      expect(ApiResponse.map(res), isNull);
    });
    test('returns null when data is not a map', () {
      final res = Response(requestOptions: RequestOptions(path: '/x'), data: {'data': [1, 2]});
      expect(ApiResponse.map(res), isNull);
    });
  });

  group('ApiResponse.list', () {
    test('extracts list of maps from envelope', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        data: {'data': [{'id': 1}, {'id': 2}]},
      );
      final list = ApiResponse.list(res);
      expect(list.length, 2);
      expect(list[0]['id'], 1);
    });
    test('returns empty list when data absent', () {
      final res = Response(requestOptions: RequestOptions(path: '/x'), data: {});
      expect(ApiResponse.list(res), isEmpty);
    });
  });
}
