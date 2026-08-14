import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/screens/picture_forge_screen.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/picture_forge_configuration.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/picture_forge_reference_card.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(
      locale: Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PictureForgeScreen()),
    ),
  );
}

void main() {
  testWidgets('lets the player configure a Picture Forge challenge', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    expect(find.byType(PictureForgeConfiguration), findsOneWidget);
    expect(find.text('Pilih gambar'), findsOneWidget);
    expect(find.text('Pilih tingkat kesulitan'), findsOneWidget);
    expect(find.text('Mulai permainan'), findsOneWidget);
  });

  testWidgets('keeps the selected image visible as a puzzle reference', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    await tester.tap(find.text('Mulai permainan'));
    await tester.pump();

    expect(find.byType(PictureForgeReferenceCard), findsOneWidget);
    expect(find.text('Gambar referensi'), findsOneWidget);
  });
}
