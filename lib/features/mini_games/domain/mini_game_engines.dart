import 'dart:math';

class ColorSprintRound {
  const ColorSprintRound({required this.wordId, required this.inkId});

  final String wordId;
  final String inkId;

  bool isCorrect(String selectedInkId) => selectedInkId == inkId;
}

/// Pure game setup helpers. They never read or write device storage so every
/// play session starts fresh and ends in memory.
class MiniGameEngines {
  MiniGameEngines._();

  static const colorIds = ['blue', 'yellow', 'red', 'green'];

  static List<ColorSprintRound> colorSprintRounds(
    Random random, {
    int count = 12,
  }) {
    final rounds = <ColorSprintRound>[];
    final words = List<String>.of(colorIds)..shuffle(random);
    for (var index = 0; index < count; index++) {
      if (index > 0 && index % words.length == 0) words.shuffle(random);
      final wordId = words[index % words.length];
      final inkChoices = colorIds.where((id) => id != wordId).toList()
        ..shuffle(random);
      rounds.add(ColorSprintRound(wordId: wordId, inkId: inkChoices.first));
    }
    return rounds;
  }

  static List<int> pictureForgeBoard(Random random, int gridSize) {
    final board = List<int>.generate(gridSize * gridSize, (index) => index);
    do {
      board.shuffle(random);
    } while (_misplaced(board) < (board.length * 2) ~/ 3);
    return board;
  }

  static bool isPictureForgeSolved(List<int> board) {
    return board.indexed.every((entry) => entry.$1 == entry.$2);
  }

  static List<String?> twinTraceBoard(
    Random random, {
    required int pairCount,
    required bool hasCenterGap,
  }) {
    final fruitIds = [
      'apple',
      'banana',
      'orange',
      'kiwi',
      'blueberry',
      'grapes',
      'dragonfruit',
      'pineapple',
      'coconut',
      'peach',
      'pear',
      'watermelon',
    ].take(pairCount).toList();
    final cards = [...fruitIds, ...fruitIds]..shuffle(random);
    if (!hasCenterGap) return cards;

    final middle = cards.length ~/ 2;
    return [...cards.take(middle), null, ...cards.skip(middle)];
  }

  static List<String> brainSummitQuestionIds(Random random, {int count = 8}) {
    final ids = [
      'everest',
      'pacific',
      'tokyo',
      'giza',
      'jupiter',
      'mars',
      'carbon',
      'heart',
      'independence',
      'borobudur',
      'laskarPelangi',
      'pancasila',
      'cpu',
      'https',
      'binary',
      'router',
    ]..shuffle(random);
    return ids.take(count).toList();
  }

  static int _misplaced(List<int> board) {
    return board.indexed.where((entry) => entry.$1 != entry.$2).length;
  }
}
