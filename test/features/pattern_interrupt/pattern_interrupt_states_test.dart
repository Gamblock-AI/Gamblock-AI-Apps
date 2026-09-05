import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/platform/protection_timing_contract.dart';
import 'package:gamblock_ai_apps/features/pattern_interrupt/presentation/screens/pattern_interrupt_screen.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

void main() {
  const continueLabel = 'Lanjut ke Psikoedukasi';
  const groundingLabel = 'Latihan grounding offline';
  const laterLabel = 'Kembali ke proteksi';
  const waitHint = 'Sebentar lagi — tarik napas dulu.';
  const staticPhase = 'Tarik napas perlahan, lalu hembuskan.';

  Future<void> pumpScreen(
    WidgetTester tester, {
    bool disableAnimations = true,
  }) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: PatternInterruptScreen(),
          ),
        ),
      ),
    );

    if (!disableAnimations) {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('id'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PatternInterruptScreen(),
          ),
        ),
      );
    }
    await tester.pump();
  }

  TextButton laterButton(WidgetTester tester) =>
      tester.widget<TextButton>(find.widgetWithText(TextButton, laterLabel));

  FilledButton continueButton(WidgetTester tester) => tester
      .widget<FilledButton>(find.widgetWithText(FilledButton, continueLabel));

  OutlinedButton groundingButton(WidgetTester tester) =>
      tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, groundingLabel),
      );

  testWidgets(
    'renders the Indonesian initial state with locked recovery CTAs',
    (tester) async {
      await pumpScreen(tester);

      expect(find.text('Ambil jeda sebelum melanjutkan'), findsOneWidget);
      expect(
        find.text('Tarik napas dalam-dalam.\nDorongan ini akan lewat.'),
        findsOneWidget,
      );
      expect(find.text('7 detik tersisa'), findsOneWidget);
      expect(find.text(staticPhase), findsOneWidget);
      expect(continueButton(tester).onPressed, isNull);
      expect(groundingButton(tester).onPressed, isNull);
      expect(laterButton(tester).onPressed, isNotNull);

      final semantics = tester.ensureSemantics();
      expect(find.bySemanticsLabel(laterLabel), findsNothing);
      semantics.dispose();
    },
  );

  testWidgets('unlocks the recovery CTAs only after the seven-second pause', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.pump(
      const Duration(
        seconds: ProtectionTimingContract.patternInterruptSeconds - 1,
      ),
    );
    expect(find.text('1 detik tersisa'), findsOneWidget);
    expect(continueButton(tester).onPressed, isNull);
    expect(groundingButton(tester).onPressed, isNull);

    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('Jeda selesai. Pilih langkah berikutnya.'),
      findsOneWidget,
    );
    expect(continueButton(tester).onPressed, isNotNull);
    expect(groundingButton(tester).onPressed, isNotNull);
    expect(find.bySemanticsLabel(laterLabel), findsOneWidget);
  });

  testWidgets(
    'reduced motion keeps a static phase while progress advances by ticks',
    (tester) async {
      await pumpScreen(tester);

      expect(find.text(staticPhase), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text(staticPhase), findsOneWidget);
      expect(find.text('5 detik tersisa'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );

  testWidgets(
    'back before readiness shows the wait hint and keeps the screen open',
    (tester) async {
      await pumpScreen(tester);

      final didPop = await tester.binding.handlePopRoute();
      await tester.pump();

      // The binding reports the back event as handled even though PopScope
      // rejects the pop while the countdown is active.
      expect(didPop, isTrue);
      expect(find.text(waitHint), findsOneWidget);
      expect(find.text('Ambil jeda sebelum melanjutkan'), findsOneWidget);
    },
  );
}
