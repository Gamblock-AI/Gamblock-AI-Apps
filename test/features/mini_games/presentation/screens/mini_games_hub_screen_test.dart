import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/widgets/app_bar_title.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/screens/mini_games_hub_screen.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/mini_game_card.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

Widget _buildScreen() {
  return const MaterialApp(
    locale: Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MiniGamesHubScreen(),
  );
}

void main() {
  testWidgets(
    'renders MiniGamesHubScreen with consistent AppBarTitle and game cards',
    (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(AppBarTitle), findsOneWidget);
      expect(find.text('Mini game'), findsOneWidget);
      expect(find.byType(MiniGameCard), findsNWidgets(4));
    },
  );
}
