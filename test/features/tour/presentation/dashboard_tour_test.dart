import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/tour/data/tour_seen_store.dart';
import 'package:gamblock_ai_apps/features/tour/presentation/dashboard_tour_controller.dart';
import 'package:gamblock_ai_apps/features/tour/presentation/dashboard_tour_host.dart';
import 'package:gamblock_ai_apps/features/tour/presentation/tour_target.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

class _FakeTourSeenStore extends TourSeenStore {
  _FakeTourSeenStore() : super(const FlutterSecureStorage());
  bool seen = false;
  bool markSeenCalled = false;

  @override
  Future<bool> isSeen() async => seen;

  @override
  Future<void> markSeen() async {
    markSeenCalled = true;
    seen = true;
  }
}

Widget _harness({
  required Widget host,
  required bool eligible,
  required _FakeTourSeenStore store,
}) {
  return ProviderScope(
    overrides: [
      tourSeenStoreProvider.overrideWithValue(store),
      dashboardTourEligibleProvider.overrideWith((ref) async => eligible),
    ],
    child: MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Stack(
          children: [
            const Positioned(
              top: 80,
              left: 40,
              child: TourTarget(
                id: 'tour-welcome',
                child: SizedBox(width: 240, height: 56),
              ),
            ),
            const Positioned(
              top: 160,
              left: 40,
              child: TourTarget(
                id: 'tour-hero',
                child: SizedBox(width: 240, height: 120),
              ),
            ),
            const Positioned(
              top: 300,
              left: 40,
              child: TourTarget(
                id: 'tour-protection',
                child: SizedBox(width: 240, height: 80),
              ),
            ),
            const Positioned(
              bottom: 120,
              right: 40,
              child: TourTarget(
                id: 'tour-fab',
                child: SizedBox(width: 60, height: 60),
              ),
            ),
            const Positioned(
              bottom: 40,
              left: 40,
              child: TourTarget(
                id: 'tour-nav',
                child: SizedBox(width: 320, height: 64),
              ),
            ),
            const Positioned(
              top: 40,
              left: 40,
              child: TourTarget(
                id: 'tour-profile',
                child: SizedBox(width: 50, height: 50),
              ),
            ),
            Positioned.fill(child: host),
          ],
        ),
      ),
    ),
  );
}

Rect _spotlightRect(WidgetTester tester) {
  final paint = find.byWidgetPredicate(
    (widget) =>
        widget is CustomPaint &&
        widget.painter?.runtimeType.toString() == '_SpotlightDimPainter',
  );
  final customPaint = tester.widget<CustomPaint>(paint);
  return (customPaint.painter! as dynamic).spotlight as Rect;
}

void main() {
  testWidgets('does not start when the tour is not eligible', (tester) async {
    final store = _FakeTourSeenStore();
    await tester.pumpWidget(
      _harness(
        host: const DashboardTourHost(currentPath: '/dashboard'),
        eligible: false,
        store: store,
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Dashboard kamu'), findsNothing);
    expect(store.markSeenCalled, isFalse);
  });

  testWidgets('does not start outside the dashboard route', (tester) async {
    final store = _FakeTourSeenStore();
    await tester.pumpWidget(
      _harness(
        host: const DashboardTourHost(currentPath: '/settings'),
        eligible: true,
        store: store,
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Dashboard kamu'), findsNothing);
    expect(store.markSeenCalled, isFalse);
  });

  testWidgets('starts once, advances steps, and skips', (tester) async {
    final store = _FakeTourSeenStore();
    await tester.pumpWidget(
      _harness(
        host: const DashboardTourHost(currentPath: '/dashboard'),
        eligible: true,
        store: store,
      ),
    );

    // Let eligibility resolve, then fire the 300ms start delay.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(store.markSeenCalled, isTrue, reason: 'seen persisted on start');
    expect(find.text('Dashboard kamu'), findsOneWidget);

    await tester.tap(find.text('Lanjut'));
    await tester.pump();
    expect(find.text('2 dari 6'), findsOneWidget);

    await tester.tap(find.text('Lewati'));
    await tester.pump();
    expect(find.text('Dashboard kamu'), findsNothing);

    // A skipped tour must not restart within the same session.
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Dashboard kamu'), findsNothing);
  });

  testWidgets('completes the last step instead of advancing', (tester) async {
    final store = _FakeTourSeenStore();
    await tester.pumpWidget(
      _harness(
        host: const DashboardTourHost(currentPath: '/dashboard'),
        eligible: true,
        store: store,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    expect(find.text('Dashboard kamu'), findsOneWidget);

    for (var i = 1; i <= 5; i++) {
      await tester.tap(find.text('Lanjut'));
      await tester.pump();
    }
    // Reaching the last step now shows the done button instead of next.
    final doneButton = find.text('Selesai');
    expect(doneButton, findsOneWidget);

    await tester.tap(doneButton);
    await tester.pump();
    expect(find.text('Dashboard kamu'), findsNothing);
  });

  testWidgets('spotlight moves to the next target when advancing', (
    tester,
  ) async {
    final store = _FakeTourSeenStore();
    await tester.pumpWidget(
      _harness(
        host: const DashboardTourHost(currentPath: '/dashboard'),
        eligible: true,
        store: store,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    // Step 0 spotlights `tour-welcome` (40,80,240x56) inflated by 14.
    expect(
      _spotlightRect(tester),
      Rect.fromLTRB(26, 66, 294, 150),
      reason: 'spotlight starts over the first target',
    );

    await tester.tap(find.text('Lanjut'));
    await tester.pump();
    await tester.pump();

    // Step 1 spotlights `tour-hero` (40,160,240x120) inflated by 14.
    expect(
      _spotlightRect(tester),
      Rect.fromLTRB(26, 146, 294, 294),
      reason: 'spotlight follows the next target on Next',
    );
  });
}
