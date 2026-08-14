/// A lightweight, session-only activity offered from the mobile dashboard.
///
/// These definitions deliberately carry no score, completion, or persistence
/// fields. Mini games are supporting activities, not progress tracking.
enum MiniGame { spectrumSprint, pictureForge, twinTrace, brainSummit }

class MiniGameDefinition {
  const MiniGameDefinition({
    required this.game,
    required this.route,
    required this.assetPath,
  });

  final MiniGame game;
  final String route;
  final String assetPath;
}
