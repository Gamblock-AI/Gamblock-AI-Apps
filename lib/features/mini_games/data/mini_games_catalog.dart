import '../domain/mini_game.dart';

class MiniGamesCatalog {
  MiniGamesCatalog._();

  static const games = [
    MiniGameDefinition(
      game: MiniGame.spectrumSprint,
      route: '/mini-games/spectrum-sprint',
      assetPath: 'assets/images/mini-games/spectrum-sprint.webp',
    ),
    MiniGameDefinition(
      game: MiniGame.pictureForge,
      route: '/mini-games/picture-forge',
      assetPath: 'assets/images/mini-games/picture-forge.webp',
    ),
    MiniGameDefinition(
      game: MiniGame.twinTrace,
      route: '/mini-games/twin-trace',
      assetPath: 'assets/images/mini-games/twin-trace/blueberry.webp',
    ),
    MiniGameDefinition(
      game: MiniGame.brainSummit,
      route: '/mini-games/brain-summit',
      assetPath: 'assets/images/mini-games/brain-summit.webp',
    ),
  ];

  static const picturePuzzles = [
    PictureForgePuzzle(
      id: 'studyCorner',
      assetPath: 'assets/images/mini-games/picture-forge.webp',
    ),
    PictureForgePuzzle(
      id: 'fruitMarket',
      assetPath: 'assets/images/mini-games/picture-forge/fruit-market.webp',
    ),
    PictureForgePuzzle(
      id: 'berryGarden',
      assetPath: 'assets/images/mini-games/picture-forge/berry-garden.webp',
    ),
    PictureForgePuzzle(
      id: 'tropicalPlatter',
      assetPath: 'assets/images/mini-games/picture-forge/tropical-platter.webp',
    ),
    PictureForgePuzzle(
      id: 'orchardBasket',
      assetPath: 'assets/images/mini-games/picture-forge/orchard-basket.webp',
    ),
    PictureForgePuzzle(
      id: 'citrusTable',
      assetPath: 'assets/images/mini-games/picture-forge/citrus-table.webp',
    ),
  ];

  static const twinTraceDifficulties = [
    TwinTraceDifficulty(id: '4x4', gridSize: 4, pairCount: 8),
    TwinTraceDifficulty(
      id: '5x5',
      gridSize: 5,
      pairCount: 12,
      hasCenterGap: true,
    ),
  ];

  static String fruitAsset(String fruitId) {
    return 'assets/images/mini-games/twin-trace/$fruitId.webp';
  }
}

class PictureForgePuzzle {
  const PictureForgePuzzle({required this.id, required this.assetPath});

  final String id;
  final String assetPath;
}

class TwinTraceDifficulty {
  const TwinTraceDifficulty({
    required this.id,
    required this.gridSize,
    required this.pairCount,
    this.hasCenterGap = false,
  });

  final String id;
  final int gridSize;
  final int pairCount;
  final bool hasCenterGap;

  int get cardCount => gridSize * gridSize - (hasCenterGap ? 1 : 0);
}
