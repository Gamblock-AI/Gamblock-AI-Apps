import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/pattern_interrupt/presentation/screens/pattern_interrupt_screen.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

Widget _buildOfflineRouterApp(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: '/pattern-interrupt',
    routes: [
      GoRoute(
        path: '/pattern-interrupt',
        builder: (context, state) => const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: PatternInterruptScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Dashboard route', key: ValueKey('dashboard-route')),
          ),
        ),
      ),
    ],
  );
}

Future<void> _finishCountdown(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 7));
  await tester.pump();
}

void main() {
  testWidgets(
    'returns to dashboard through GoRouter after tapping Kembali ke proteksi',
    (tester) async {
      final router = _createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildOfflineRouterApp(router));
      expect(find.text('Ambil jeda sebelum melanjutkan'), findsOneWidget);

      await _finishCountdown(tester);
      await tester.tap(find.text('Kembali ke proteksi'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/dashboard');
      expect(find.byKey(const ValueKey('dashboard-route')), findsOneWidget);
    },
  );

  testWidgets(
    'opens offline grounding and returns to dashboard without native calls',
    (tester) async {
      final router = _createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildOfflineRouterApp(router));
      await _finishCountdown(tester);

      await tester.tap(find.text('Latihan grounding offline'));
      await tester.pump();

      expect(find.text('Perhatikan lima hal di sekitar Anda'), findsOneWidget);
      expect(find.text('Langkah 1 dari 5'), findsOneWidget);

      await tester.tap(find.text('Selesai dan kembali'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/dashboard');
      expect(find.byKey(const ValueKey('dashboard-route')), findsOneWidget);
    },
  );

  testWidgets('disposing the screen cancels its local countdown safely', (
    tester,
  ) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildOfflineRouterApp(router));
    await tester.pump(const Duration(seconds: 2));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 8));

    expect(find.byType(PatternInterruptScreen), findsNothing);
  });
}
