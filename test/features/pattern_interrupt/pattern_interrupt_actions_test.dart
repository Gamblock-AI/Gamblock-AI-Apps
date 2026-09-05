import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/feedback/haptics.dart';
import 'package:gamblock_ai_apps/features/pattern_interrupt/presentation/widgets/pattern_interrupt_actions.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

void main() {
  setUp(() {
    Haptics.enabled = false;
  });

  tearDown(() {
    Haptics.enabled = true;
  });

  testWidgets(
    'blocks the primary CTA and excludes the later action from semantics before ready',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(_harness(ready: false));

      final continueButtonFinder = find.widgetWithText(
        FilledButton,
        'Lanjut ke Psikoedukasi',
      );
      final continueButton = tester.widget<FilledButton>(continueButtonFinder);
      expect(continueButton.onPressed, isNull);
      final continueSemantics = tester.getSemantics(continueButtonFinder);
      final continueSemanticsFlags = continueSemantics
          .getSemanticsData()
          .flagsCollection;
      expect(continueSemanticsFlags.isEnabled != Tristate.none, isTrue);
      expect(continueSemanticsFlags.isEnabled, Tristate.isFalse);
      expect(
        continueSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isFalse,
      );
      expect(find.bySemanticsLabel('Kembali ke proteksi'), findsNothing);

      semanticsHandle.dispose();
    },
  );

  testWidgets('shows the recovery CTA and later action when ready', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();

    await tester.pumpWidget(_harness(ready: true));

    final continueButtonFinder = find.widgetWithText(
      FilledButton,
      'Lanjut ke Psikoedukasi',
    );
    final continueButton = tester.widget<FilledButton>(continueButtonFinder);
    expect(continueButton.onPressed, isNotNull);
    final continueSemantics = tester.getSemantics(continueButtonFinder);
    expect(
      continueSemantics.getSemanticsData().flagsCollection.isEnabled,
      Tristate.isTrue,
    );
    expect(
      continueSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(find.text('Lanjut ke Psikoedukasi'), findsOneWidget);
    expect(find.text('Kembali ke proteksi'), findsOneWidget);
    expect(find.bySemanticsLabel('Kembali ke proteksi'), findsOneWidget);

    semanticsHandle.dispose();
  });

  testWidgets('invokes every recovery action callback when tapped', (
    tester,
  ) async {
    var continueCalls = 0;
    var groundingCalls = 0;
    var helpCalls = 0;
    var laterCalls = 0;

    await tester.pumpWidget(
      _harness(
        ready: true,
        onContinue: () => continueCalls++,
        onOpenGrounding: () => groundingCalls++,
        onOpenHelp: () => helpCalls++,
        onLater: () => laterCalls++,
      ),
    );

    await tester.tap(find.text('Lanjut ke Psikoedukasi'));
    await tester.tap(find.text('Latihan grounding offline'));
    await tester.tap(find.text('Butuh bantuan'));
    await tester.tap(find.text('Kembali ke proteksi'));

    expect(continueCalls, 1);
    expect(groundingCalls, 1);
    expect(helpCalls, 1);
    expect(laterCalls, 1);
  });
}

Widget _harness({
  required bool ready,
  VoidCallback? onContinue,
  VoidCallback? onOpenGrounding,
  VoidCallback? onOpenHelp,
  VoidCallback? onLater,
}) {
  return MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PatternInterruptActions(
          ready: ready,
          disableAnimations: true,
          onContinue: onContinue ?? () {},
          onOpenGrounding: onOpenGrounding ?? () {},
          onOpenHelp: onOpenHelp ?? () {},
          onLater: onLater ?? () {},
        ),
      ),
    ),
  );
}
