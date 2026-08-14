import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/screens/spectrum_sprint_screen.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/color_choice_button.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(
      locale: Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SpectrumSprintScreen()),
    ),
  );
}

void main() {
  testWidgets('renders SpectrumSprintScreen with centered color choice buttons in 2x2 grid', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    expect(find.text('Sprint Spektrum'), findsOneWidget);
    expect(find.byType(ColorChoiceButton), findsNWidgets(4));

    // Verify all 4 buttons have horizontally centered text
    final textFinders = find.descendant(
      of: find.byType(ColorChoiceButton),
      matching: find.byType(Text),
    );
    for (final textWidget in tester.widgetList<Text>(textFinders)) {
      expect(textWidget.textAlign, TextAlign.center);
    }

    // Clean up timers by disposing the screen
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping a color choice button shows instant visual feedback before advancing', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    expect(find.text('Ronde 1 dari 12'), findsOneWidget);

    // Tap first option button
    await tester.tap(find.byType(ColorChoiceButton).first);
    await tester.pump(); // frame where feedback state is set

    // Feedback icon (check or cancel) should be visible immediately
    final hasCheck = find.byIcon(Icons.check_circle_rounded).evaluate().isNotEmpty;
    final hasCancel = find.byIcon(Icons.cancel_rounded).evaluate().isNotEmpty;
    expect(hasCheck || hasCancel, isTrue);

    // Still on round 1 during feedback window
    expect(find.text('Ronde 1 dari 12'), findsOneWidget);

    // Advance through the 500ms delay
    await tester.pump(const Duration(milliseconds: 550));

    // Now moved to round 2
    expect(find.text('Ronde 2 dari 12'), findsOneWidget);

    // Clean up timers by disposing the screen
    await tester.pumpWidget(const SizedBox());
  });
}
