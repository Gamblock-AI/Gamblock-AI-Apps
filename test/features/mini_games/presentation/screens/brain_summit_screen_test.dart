import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/screens/brain_summit_screen.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/brain_answer_option.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(
      locale: Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: BrainSummitScreen()),
    ),
  );
}

void main() {
  testWidgets(
    'renders BrainSummitScreen with centered options and progress bar',
    (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Puncak Otak'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(BrainAnswerOption), findsNWidgets(4));

      // Verify all 4 options have horizontally centered text (TextAlign.center)
      final textFinders = find.descendant(
        of: find.byType(BrainAnswerOption),
        matching: find.byType(Text),
      );
      for (final textWidget in tester.widgetList<Text>(textFinders)) {
        expect(textWidget.textAlign, TextAlign.center);
      }
    },
  );

  testWidgets(
    'tapping an option displays instant visual feedback before advancing',
    (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final firstOption = find.byType(BrainAnswerOption).first;
      await tester.tap(firstOption);
      await tester.pump(); // Advance 1 frame to display feedback immediately

      // Verify feedback icon is rendered (either check or cancel icon)
      final hasFeedbackIcon =
          find.byIcon(Icons.check_circle_rounded).evaluate().isNotEmpty ||
          find.byIcon(Icons.cancel_rounded).evaluate().isNotEmpty;
      expect(hasFeedbackIcon, isTrue);

      // After timer expires (~850ms), it moves forward
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
    },
  );
}
