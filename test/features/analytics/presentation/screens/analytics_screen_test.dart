import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/auth/auth_state.dart';
import 'package:gamblock_ai_apps/core/widgets/app_bar_title.dart';
import 'package:gamblock_ai_apps/core/widgets/empty_state.dart';
import 'package:gamblock_ai_apps/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

class _FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  _FakeAuthNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('renders device registration empty state and privacy section when deviceId is null', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            (ref) => _FakeAuthNotifier(
              const AuthState(
                isAuthenticated: true,
                userId: 'user-1',
                deviceId: null,
                phoneVerified: true,
                isLoading: false,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AnalyticsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AppBarTitle), findsOneWidget);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Perangkat belum terdaftar'), findsOneWidget);
    expect(find.text('Setup perangkat'), findsOneWidget);
    expect(find.text('Jaminan Privasi & Keamanan Data'), findsOneWidget);
    expect(find.text('Privasi terjaga'), findsOneWidget);
    expect(find.text('Tanpa Riwayat Penelusuran'), findsOneWidget);
  });

  testWidgets('renders unauthenticated empty state when user is not logged in', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            (ref) => _FakeAuthNotifier(
              const AuthState(isAuthenticated: false, isLoading: false),
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AnalyticsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AppBarTitle), findsOneWidget);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Masuk untuk melihat analitik'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Jaminan Privasi & Keamanan Data'), findsOneWidget);
  });
}
