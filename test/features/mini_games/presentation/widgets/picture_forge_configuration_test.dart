import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/data/mini_games_catalog.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/picture_forge_configuration.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/picture_forge_puzzle_choice.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  testWidgets('PictureForgeConfiguration renders preview, difficulty buttons, and triggers onStart', (
    tester,
  ) async {
    var started = false;
    await tester.pumpWidget(
      _wrap(
        PictureForgeConfiguration(
          title: 'Siapkan puzzlemu',
          description: 'Pilih gambar dan ukuran papan sebelum mulai bermain.',
          imageChoiceLabel: 'Pilih gambar',
          difficultyLabel: 'Pilih tingkat kesulitan',
          startLabel: 'Mulai permainan',
          selectedPuzzle: MiniGamesCatalog.picturePuzzles.first,
          selectedGridSize: 3,
          puzzles: MiniGamesCatalog.picturePuzzles,
          puzzleName: (puzzle) => puzzle.id,
          pieceCount: (count) => '$count keping',
          onPuzzleChanged: (_) {},
          onGridSizeChanged: (_) {},
          onStart: () => started = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siapkan puzzlemu'), findsOneWidget);
    expect(find.text('Pilih gambar'), findsOneWidget);
    expect(find.text('Pilih tingkat kesulitan'), findsOneWidget);
    expect(find.text('Mulai permainan'), findsOneWidget);

    await tester.tap(find.text('Mulai permainan'));
    await tester.pumpAndSettle();
    expect(started, isTrue);
  });

  testWidgets('PictureForgeConfiguration triggers onPuzzleChanged and onGridSizeChanged', (
    tester,
  ) async {
    PictureForgePuzzle? changedPuzzle;
    int? changedGridSize;

    await tester.pumpWidget(
      _wrap(
        PictureForgeConfiguration(
          title: 'Siapkan puzzlemu',
          description: 'Pilih gambar dan ukuran papan sebelum mulai bermain.',
          imageChoiceLabel: 'Pilih gambar',
          difficultyLabel: 'Pilih tingkat kesulitan',
          startLabel: 'Mulai permainan',
          selectedPuzzle: MiniGamesCatalog.picturePuzzles.first,
          selectedGridSize: 3,
          puzzles: MiniGamesCatalog.picturePuzzles,
          puzzleName: (puzzle) => puzzle.id,
          pieceCount: (count) => '$count keping',
          onPuzzleChanged: (p) => changedPuzzle = p,
          onGridSizeChanged: (g) => changedGridSize = g,
          onStart: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Checkmark icon on active puzzle
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    // Tap second puzzle
    final choices = find.byType(PictureForgePuzzleChoice);
    expect(choices, findsNWidgets(MiniGamesCatalog.picturePuzzles.length));
    await tester.tap(choices.at(1));
    await tester.pumpAndSettle();

    expect(changedPuzzle?.id, MiniGamesCatalog.picturePuzzles[1].id);

    // Tap 4x4 difficulty
    await tester.tap(find.text('4×4'));
    await tester.pumpAndSettle();

    expect(changedGridSize, 4);
  });
}
