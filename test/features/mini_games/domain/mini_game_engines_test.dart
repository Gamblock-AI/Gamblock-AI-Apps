import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/data/mini_games_catalog.dart';
import 'package:gamblock_ai_apps/features/mini_games/domain/mini_game_engines.dart';

void main() {
  test('Spectrum Sprint never uses the displayed word as its ink colour', () {
    final rounds = MiniGameEngines.colorSprintRounds(Random(4));

    expect(rounds, hasLength(12));
    expect(rounds.every((round) => round.wordId != round.inkId), isTrue);
  });

  test('Picture Forge begins mixed and recognises the completed board', () {
    final board = MiniGameEngines.pictureForgeBoard(Random(3), 3);

    expect(MiniGameEngines.isPictureForgeSolved(board), isFalse);
    expect(
      MiniGameEngines.isPictureForgeSolved(
        List<int>.generate(9, (index) => index),
      ),
      isTrue,
    );
  });

  test('Twin Trace adds the empty centre only for the large board', () {
    final board = MiniGameEngines.twinTraceBoard(
      Random(2),
      pairCount: 12,
      hasCenterGap: true,
    );

    expect(board, hasLength(25));
    expect(board.where((card) => card == null), hasLength(1));
  });

  test('catalog keeps the website puzzle and board configurations', () {
    expect(
      MiniGamesCatalog.games.map((game) => game.assetPath),
      everyElement(isNotEmpty),
    );
    expect(MiniGamesCatalog.picturePuzzles, hasLength(6));
    expect(MiniGamesCatalog.twinTraceDifficulties.map((item) => item.id), [
      '4x4',
      '5x5',
    ]);
    expect(MiniGamesCatalog.twinTraceDifficulties.last.cardCount, 24);
  });

  test('Brain Summit selects a fresh eight-question session', () {
    final questions = MiniGameEngines.brainSummitQuestionIds(Random(6));

    expect(questions, hasLength(8));
    expect(questions.toSet(), hasLength(8));
  });
}
