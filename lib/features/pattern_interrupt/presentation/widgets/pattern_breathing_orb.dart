import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Animated breathing focal point used by the Pattern Interrupt exercise.
class PatternBreathingOrb extends StatelessWidget {
  const PatternBreathingOrb({
    super.key,
    required this.animation,
    required this.disableAnimations,
    required this.semanticsLabel,
  });

  final Animation<double> animation;
  final bool disableAnimations;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final scale = disableAnimations
              ? 1.0
              : 0.86 + (animation.value * 0.14);
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: 172,
          height: 172,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.sky.withValues(alpha: 0.12),
            border: Border.all(
              color: AppColors.skyLight.withValues(alpha: 0.65),
              width: 2,
            ),
          ),
          child: const Icon(Icons.air, size: 64, color: AppColors.skyLight),
        ),
      ),
    );
  }
}
