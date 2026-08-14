import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

class TwinTraceCard extends StatelessWidget {
  const TwinTraceCard({
    super.key,
    required this.fruitId,
    required this.showFace,
    required this.semanticLabel,
    required this.onTap,
  });

  final String? fruitId;
  final bool showFace;
  final String? semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (fruitId == null) return const SizedBox.expand();
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Ink(
            decoration: BoxDecoration(
              color: showFace ? Colors.white : AppColors.navy,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: showFace ? AppColors.skyLight : AppColors.navyLight,
              ),
              boxShadow: AppColors.cardSoftShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: showFace
                    ? Image.asset(
                        'assets/images/mini-games/twin-trace/$fruitId.webp',
                        key: const ValueKey('face'),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        key: ValueKey('back'),
                        child: Icon(
                          Icons.question_mark_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
