import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bar_title.dart';
import '../../data/mini_games_catalog.dart';
import '../../domain/mini_game.dart';
import '../widgets/mini_game_card.dart';
import '../widgets/mini_games_session_notice.dart';

class MiniGamesHubScreen extends StatelessWidget {
  const MiniGamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: 16,
        title: AppBarTitle(
          icon: Icons.sports_esports_rounded,
          title: l10n.miniGamesTitle,
        ),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.miniGamesDescription,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MiniGamesSessionNotice(text: l10n.miniGamesSessionOnly),
          const SizedBox(height: AppSpacing.lg),
          for (final game in MiniGamesCatalog.games) ...[
            MiniGameCard(
              title: _title(l10n, game.game),
              description: _description(l10n, game.game),
              icon: _icon(game.game),
              color: _color(game.game),
              assetPath: game.assetPath,
              onTap: () => context.go(game.route),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  String _title(AppLocalizations l10n, MiniGame game) => switch (game) {
    MiniGame.spectrumSprint => l10n.miniGamesSpectrumTitle,
    MiniGame.pictureForge => l10n.miniGamesPictureTitle,
    MiniGame.twinTrace => l10n.miniGamesTwinTitle,
    MiniGame.brainSummit => l10n.miniGamesBrainTitle,
  };

  String _description(AppLocalizations l10n, MiniGame game) => switch (game) {
    MiniGame.spectrumSprint => l10n.miniGamesSpectrumDescription,
    MiniGame.pictureForge => l10n.miniGamesPictureDescription,
    MiniGame.twinTrace => l10n.miniGamesTwinDescription,
    MiniGame.brainSummit => l10n.miniGamesBrainDescription,
  };

  IconData _icon(MiniGame game) => switch (game) {
    MiniGame.spectrumSprint => Icons.palette_outlined,
    MiniGame.pictureForge => Icons.grid_view_rounded,
    MiniGame.twinTrace => Icons.grid_4x4_rounded,
    MiniGame.brainSummit => Icons.quiz_outlined,
  };

  Color _color(MiniGame game) => switch (game) {
    MiniGame.spectrumSprint => AppColors.skyDark,
    MiniGame.pictureForge => AppColors.amberDark,
    MiniGame.twinTrace => AppColors.sage,
    MiniGame.brainSummit => AppColors.navyLight,
  };
}
