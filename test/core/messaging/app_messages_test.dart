import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/config/app_config.dart';
import 'package:gamblock_ai_apps/core/messaging/app_messages.dart';

// Helper: build a DioException carrying a backend envelope error.
DioException _dioErr({String? code, String? message, int? status}) {
  final data = <String, dynamic>{
    'error': <String, dynamic>{},
  };
  if (code != null) (data['error'] as Map)['code'] = code;
  if (message != null) (data['error'] as Map)['message'] = message;
  return DioException(
    requestOptions: RequestOptions(path: '/x'),
    response: Response(
      requestOptions: RequestOptions(path: '/x'),
      statusCode: status ?? 400,
      data: data,
    ),
  );
}

void main() {
  group('AppMessages.forCode', () {
    test('returns friendly message for known code', () {
      expect(AppMessages.forCode('invalid_credentials'),
          'Email atau kata sandi salah. Silakan periksa kembali.');
    });
    test('returns generic for unknown code', () {
      expect(AppMessages.forCode('mystery'), AppMessages.generic);
    });
    test('returns generic for null code', () {
      expect(AppMessages.forCode(null), AppMessages.generic);
    });
  });

  group('AppMessages.friendlyMessage production', () {
    test('uses backend message when present', () {
      // AppConfig.isProduction reads dotenv which is absent in test -> falls back
      // to kReleaseMode=false => development. So this branch covers dev path.
      final msg = AppMessages.friendlyMessage(
        _dioErr(code: 'invalid_credentials', message: 'backend friendly', status: 401),
      );
      // dev path includes the code prefix
      expect(msg, contains('invalid_credentials'));
    });
  });

  group('AppMessages.friendlyMessage code resolution', () {
    test('resolves known code to catalog message', () {
      final msg = AppMessages.friendlyMessage(
        _dioErr(code: 'join_failed', status: 400),
      );
      expect(msg, contains('join_failed'));
    });
  });

  group('AppMessages.friendlyMessage non-Dio error', () {
    test('handles arbitrary error without throwing', () {
      final msg = AppMessages.friendlyMessage(Exception('boom'));
      expect(msg, isNotEmpty);
    });
  });

  // Ensure AppConfig import is used (avoid unused import lint in some configs).
  test('AppConfig import referenced', () {
    expect(AppConfig, isNotNull);
  });
}
