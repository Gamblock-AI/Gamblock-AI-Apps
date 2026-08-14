import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../data/mini_games_catalog.dart';
import 'picture_forge_difficulty_choice.dart';
import 'picture_forge_puzzle_choice.dart';

class PictureForgeConfiguration extends StatelessWidget {
  const PictureForgeConfiguration({
    super.key,
    required this.title,
    required this.description,
    required this.imageChoiceLabel,
    required this.difficultyLabel,
    required this.startLabel,
    required this.selectedPuzzle,
    required this.selectedGridSize,
    required this.puzzles,
    required this.puzzleName,
    required this.pieceCount,
    required this.onPuzzleChanged,
    required this.onGridSizeChanged,
    required this.onStart,
  });

  final String title;
  final String description;
  final String imageChoiceLabel;
  final String difficultyLabel;
  final String startLabel;
  final PictureForgePuzzle selectedPuzzle;
  final int selectedGridSize;
  final List<PictureForgePuzzle> puzzles;
  final String Function(PictureForgePuzzle puzzle) puzzleName;
  final String Function(int count) pieceCount;
  final ValueChanged<PictureForgePuzzle> onPuzzleChanged;
  final ValueChanged<int> onGridSizeChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navyDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.asset(
                    selectedPuzzle.assetPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              puzzleName(selectedPuzzle),
              style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            imageChoiceLabel,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final puzzle in puzzles)
                PictureForgePuzzleChoice(
                  puzzle: puzzle,
                  selected: puzzle.id == selectedPuzzle.id,
                  label: puzzleName(puzzle),
                  onTap: () => onPuzzleChanged(puzzle),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            difficultyLabel,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final gridSize in [3, 4, 5])
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: gridSize == 5 ? 0 : AppSpacing.xs,
                    ),
                    child: PictureForgeDifficultyChoice(
                      gridSize: gridSize,
                      selected: selectedGridSize == gridSize,
                      pieceCount: pieceCount(gridSize * gridSize),
                      onTap: () => onGridSizeChanged(gridSize),
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
