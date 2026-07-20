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
    return RepaintBoundary(
      child: Semantics(
        label: semanticsLabel,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = disableAnimations
                ? 1.0
                : 0.86 + (animation.value * 0.14);
            return Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.skyLight.withValues(alpha: 0.05 + (animation.value * 0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.skyLight.withValues(alpha: 0.15 * animation.value),
                          blurRadius: 40 + (20 * animation.value),
                          spreadRadius: 10 + (10 * animation.value),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.skyLight.withValues(alpha: 0.8),
                          AppColors.sky.withValues(alpha: 0.2),
                        ],
                        stops: const [0.2, 1.0],
                      ),
                      border: Border.all(
                        color: AppColors.skyLight.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.self_improvement, size: 64, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
