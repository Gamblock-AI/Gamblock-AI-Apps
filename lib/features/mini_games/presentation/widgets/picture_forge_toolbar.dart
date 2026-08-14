import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import 'mini_game_action_button.dart';

class PictureForgeToolbar extends StatelessWidget {
  const PictureForgeToolbar({
    super.key,
    required this.resetLabel,
    required this.changeChallengeLabel,
    required this.shuffleLabel,
    required this.resetEnabled,
    required this.onReset,
    required this.onChangeChallenge,
    required this.onShuffle,
  });

  final String resetLabel;
  final String changeChallengeLabel;
  final String shuffleLabel;
  final bool resetEnabled;
  final VoidCallback onReset;
  final VoidCallback onChangeChallenge;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        MiniGameActionButton(
          onTap: onReset,
          enabled: resetEnabled,
          icon: Icons.rotate_left_rounded,
          label: resetLabel,
        ),
        MiniGameActionButton(
          onTap: onChangeChallenge,
          icon: Icons.image_outlined,
          label: changeChallengeLabel,
        ),
        MiniGameActionButton(
          onTap: onShuffle,
          icon: Icons.shuffle_rounded,
          label: shuffleLabel,
        ),
      ],
    );
  }
}
