import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/app/shell.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget _buildShell({
  required double width,
  String initialLocation = '/dashboard',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const SizedBox(),
          ),
          GoRoute(
            path: '/mini-games',
            builder: (context, state) => const SizedBox(),
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
  testWidgets('renders Gamblock logo and title on wide desktop sidebar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildShell(width: 1200));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sidebar-brand-logo')), findsOneWidget);
    expect(find.byKey(const ValueKey('sidebar-brand-title')), findsOneWidget);
    expect(find.text('Gamblock AI'), findsOneWidget);
  });

  testWidgets('renders Gamblock logo on medium tablet rail', (tester) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildShell(width: 800));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sidebar-brand-logo')), findsOneWidget);
  });

  testWidgets('shows Mini Games destination on the tablet rail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildShell(width: 800));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.sports_esports_outlined), findsOneWidget);
    expect(find.text('Mini game'), findsOneWidget);
  });

  testWidgets('keeps Mini Games selected on the Windows-style rail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _buildShell(width: 1200, initialLocation: '/mini-games'),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.sports_esports_rounded), findsOneWidget);
    expect(find.text('Mini game'), findsOneWidget);
  });
}
