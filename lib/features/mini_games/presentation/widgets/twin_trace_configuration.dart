import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../data/mini_games_catalog.dart';
import 'twin_trace_difficulty_choice.dart';

class TwinTraceConfiguration extends StatelessWidget {
  const TwinTraceConfiguration({
    super.key,
    required this.title,
    required this.description,
    required this.difficultyLabel,
    required this.startLabel,
    required this.selectedDifficulty,
    required this.difficulties,
    required this.pairCount,
    required this.onDifficultyChanged,
    required this.onStart,
  });

  final String title;
  final String description;
  final String difficultyLabel;
  final String startLabel;
  final TwinTraceDifficulty selectedDifficulty;
  final List<TwinTraceDifficulty> difficulties;
  final String Function(TwinTraceDifficulty difficulty) pairCount;
  final ValueChanged<TwinTraceDifficulty> onDifficultyChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.grid_4x4_rounded,
              color: AppColors.amberDark,
              size: 38,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.navyDark,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              difficultyLabel,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final difficulty in difficulties)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: difficulty == difficulties.last
                          ? 0
                          : AppSpacing.sm,
                    ),
                    child: TwinTraceDifficultyChoice(
                      difficulty: difficulty,
                      selected: selectedDifficulty.id == difficulty.id,
                      pairCount: pairCount(difficulty),
                      onTap: () => onDifficultyChanged(difficulty),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(startLabel),
            ),
          ),
        ],
      ),
    );
  }
}
