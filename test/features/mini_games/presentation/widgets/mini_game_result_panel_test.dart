import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/mini_game_result_panel.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('MiniGameResultPanel renders title, body, and triggers primary action', (
    tester,
  ) async {
    var replayed = false;
    await tester.pumpWidget(
      _wrap(
        MiniGameResultPanel(
          title: 'Bagus sekali',
          body: 'Kamu menyelesaikan dalam 10 langkah.',
          action: 'Main lagi',
          onAction: () => replayed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bagus sekali'), findsOneWidget);
    expect(find.text('Kamu menyelesaikan dalam 10 langkah.'), findsOneWidget);
    expect(find.text('Main lagi'), findsOneWidget);

    await tester.tap(find.text('Main lagi'));
    await tester.pumpAndSettle();
    expect(replayed, isTrue);
  });

  testWidgets('MiniGameResultPanel renders and triggers secondaryAction (back to hub)', (
    tester,
  ) async {
    var backedToHub = false;
    await tester.pumpWidget(
      _wrap(
        MiniGameResultPanel(
          title: 'Bagus sekali',
          body: 'Kamu menyelesaikan dalam 10 langkah.',
          action: 'Main lagi',
          onAction: () {},
          secondaryAction: 'Menu mini game',
          onSecondaryAction: () => backedToHub = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menu mini game'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);

    await tester.tap(find.text('Menu mini game'));
    await tester.pumpAndSettle();
    expect(backedToHub, isTrue);
  });
}
