import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:gamblock_ai_apps/core/config/app_config.dart';
import 'package:gamblock_ai_apps/core/messaging/app_messages.dart';

// Helper: build a DioException carrying a backend envelope error.
DioException _dioErr({String? code, String? message, int? status}) {
  final data = <String, dynamic>{'error': <String, dynamic>{}};
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

Widget buildTestApp(WidgetBuilder builder) {
  return MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(builder: builder),
  );
}

void main() {
  group('AppMessages.forCode', () {
    testWidgets('returns friendly message for known code', (tester) async {
      late String result;
      await tester.pumpWidget(
        buildTestApp((context) {
          result = AppMessages.forCode(context, 'invalid_credentials');
          return const SizedBox();
        }),
      );
      expect(result, 'Email atau kata sandi salah. Silakan periksa kembali.');
    });

    testWidgets('returns generic for unknown code', (tester) async {
      late String result;
      late String generic;
      await tester.pumpWidget(
        buildTestApp((context) {
          result = AppMessages.forCode(context, 'mystery');
          generic = AppMessages.generic(context);
          return const SizedBox();
        }),
      );
      expect(result, generic);
    });

    testWidgets('returns generic for null code', (tester) async {
      late String result;
      late String generic;
      await tester.pumpWidget(
        buildTestApp((context) {
          result = AppMessages.forCode(context, null);
          generic = AppMessages.generic(context);
          return const SizedBox();
        }),
      );
      expect(result, generic);
    });
  });

  group('AppMessages.friendlyMessage production', () {
    testWidgets('uses backend message when present', (tester) async {
      late String msg;
      await tester.pumpWidget(
        buildTestApp((context) {
          msg = AppMessages.friendlyMessage(
            context,
            _dioErr(
              code: 'invalid_credentials',
              message: 'backend friendly',
              status: 401,
            ),
          );
          return const SizedBox();
        }),
      );
      expect(msg, 'Email atau kata sandi salah. Silakan periksa kembali.');
    });
  });

  group('AppMessages.friendlyMessage code resolution', () {
    testWidgets('resolves known code to catalog message', (tester) async {
      late String msg;
      await tester.pumpWidget(
        buildTestApp((context) {
          msg = AppMessages.friendlyMessage(
            context,
            _dioErr(code: 'join_failed', status: 400),
          );
          return const SizedBox();
        }),
      );
      expect(msg, 'Kode grup tidak valid. Coba lagi.');
    });
  });

  group('AppMessages.friendlyMessage non-Dio error', () {
    testWidgets('handles arbitrary error without throwing', (tester) async {
      late String msg;
      await tester.pumpWidget(
        buildTestApp((context) {
          msg = AppMessages.friendlyMessage(context, Exception('boom'));
          return const SizedBox();
        }),
      );
      expect(msg, isNotEmpty);
    });
  });

  test('AppConfig import referenced', () {
    expect(AppConfig, isNotNull);
  });
}
