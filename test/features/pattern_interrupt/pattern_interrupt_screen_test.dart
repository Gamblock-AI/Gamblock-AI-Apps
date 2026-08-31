import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/pattern_interrupt/presentation/screens/pattern_interrupt_screen.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:gamblock_ai_apps/core/platform/protection_timing_contract.dart';

void main() {
  test('Pattern Interrupt contract remains inside the proposal range', () {
    expect(ProtectionTimingContract.patternInterruptSeconds, 7);
    expect(
      ProtectionTimingContract.patternInterruptSeconds,
      inInclusiveRange(5, 10),
    );
  });

  testWidgets('Pattern Interrupt waits seven seconds before recovery actions', (
    tester,
  ) async {
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

    expect(find.text('Lanjut ke Psikoedukasi'), findsOneWidget);
    FilledButton recoveryButton() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Lanjut ke Psikoedukasi'),
    );
    expect(recoveryButton().onPressed, isNull);

    await tester.pump(const Duration(seconds: 7));
    expect(recoveryButton().onPressed, isNotNull);
  });
}
