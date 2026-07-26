import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Animated breathing focal point used by the Pattern Interrupt exercise.
/// A thin progress ring visualises the sanctioned pause filling up — calm and
/// digit-free (the countdown text lives in the pill below the title).
class PatternBreathingOrb extends StatelessWidget {
  const PatternBreathingOrb({
    super.key,
    required this.animation,
    required this.progress,
    required this.disableAnimations,
    required this.semanticsLabel,
  });

  final Animation<double> animation;
  final Animation<double> progress;
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
            // Under reduced motion the controller is stopped; park visuals at
            // the mid state instead of the dimmest frame (SkeletonBox pattern).
            final t = disableAnimations ? 0.5 : animation.value;
            final scale = disableAnimations ? 1.0 : 0.86 + (t * 0.14);
            return CustomPaint(
              foregroundPainter: _ProgressRingPainter(progress),
              child: SizedBox(
                width: 226,
                height: 226,
                child: Center(
                  child: Transform.scale(
                    scale: scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.skyLight.withValues(
                              alpha: 0.05 + (t * 0.05),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.skyLight.withValues(
                                  alpha: 0.15 * t,
                                ),
                                blurRadius: 40 + (20 * t),
                                spreadRadius: 10 + (10 * t),
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
                          child: const Icon(
                            Icons.self_improvement,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final value = progress.value.clamp(0.0, 1.0);
    if (value <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = AppColors.skyLight.withValues(alpha: 0.45);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      value * 2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
