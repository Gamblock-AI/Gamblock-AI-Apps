import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/app/shell.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget _buildAppShell() {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Dashboard Content')),
            ),
          ),
          GoRoute(
            path: '/mini-games',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Mini Games Content')),
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  testWidgets('Center FAB responds to tap on upper floating area (top)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAppShell());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Content'), findsOneWidget);

    final fabFinder = find.ancestor(
      of: find.byIcon(Icons.sports_esports_rounded),
      matching: find.byType(InkWell),
    );
    expect(fabFinder, findsOneWidget);

    // Tap the top-center edge of the FAB (the raised floating portion)
    final fabTopCenter = tester.getTopLeft(fabFinder) + const Offset(30, 8);
    await tester.tapAt(fabTopCenter);
    await tester.pumpAndSettle();

    expect(find.text('Mini Games Content'), findsOneWidget);
  });

  testWidgets('Center FAB responds to tap on center of the button', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAppShell());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Content'), findsOneWidget);

    final fabFinder = find.byIcon(Icons.sports_esports_rounded);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    expect(find.text('Mini Games Content'), findsOneWidget);
  });
}
