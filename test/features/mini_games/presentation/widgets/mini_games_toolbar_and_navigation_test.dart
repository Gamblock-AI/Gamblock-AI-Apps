import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/mini_game_action_button.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/mini_game_header.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/picture_forge_toolbar.dart';
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
  testWidgets('MiniGameActionButton renders label, icon, and triggers onTap when enabled', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        MiniGameActionButton(
          icon: Icons.shuffle_rounded,
          label: 'Acak',
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acak'), findsOneWidget);
    expect(find.byIcon(Icons.shuffle_rounded), findsOneWidget);

    await tester.tap(find.text('Acak'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('MiniGameActionButton does not trigger onTap when disabled', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        MiniGameActionButton(
          icon: Icons.rotate_left_rounded,
          label: 'Atur ulang',
          enabled: false,
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Atur ulang'));
    await tester.pumpAndSettle();
    expect(tapped, isFalse);
  });

  testWidgets('PictureForgeToolbar renders all 3 action buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PictureForgeToolbar(
          resetLabel: 'Atur ulang',
          changeChallengeLabel: 'Ubah tantangan',
          shuffleLabel: 'Acak',
          resetEnabled: true,
          onReset: () {},
          onChangeChallenge: () {},
          onShuffle: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Atur ulang'), findsOneWidget);
    expect(find.text('Ubah tantangan'), findsOneWidget);
    expect(find.text('Acak'), findsOneWidget);
    expect(find.byType(MiniGameActionButton), findsNWidgets(3));
  });

  testWidgets('MiniGameHeader renders styled circular back button and triggers onBack', (
    tester,
  ) async {
    var backed = false;
    await tester.pumpWidget(
      _wrap(
        MiniGameHeader(
          title: 'Tempa Gambar',
          onBack: () => backed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tempa Gambar'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(backed, isTrue);
  });
}
