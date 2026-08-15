import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Animated breathing focal point used by the Pattern Interrupt exercise.
/// A luminous progress ring visualises the sanctioned pause filling up — calm and
/// digit-free with layered glowing glass aura.
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
            final t = disableAnimations ? 0.5 : animation.value;
            final scale = disableAnimations ? 1.0 : 0.88 + (t * 0.12);
            return CustomPaint(
              foregroundPainter: _ProgressRingPainter(progress),
              child: SizedBox(
                width: 210,
                height: 210,
                child: Center(
                  child: Transform.scale(
                    scale: scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ambient glowing halo
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.sky.withValues(
                              alpha: 0.08 + (t * 0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.sky.withValues(
                                  alpha: 0.25 * t + 0.1,
                                ),
                                blurRadius: 40 + (25 * t),
                                spreadRadius: 8 + (12 * t),
                              ),
                            ],
                          ),
                        ),
                        // Inner frosted glass core
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.25),
                                AppColors.skyDark.withValues(alpha: 0.40),
                                const Color(0xFF0F172A).withValues(alpha: 0.70),
                              ],
                              stops: const [0.0, 0.65, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45 + (t * 0.2)),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.15),
                                blurRadius: 16,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.self_improvement_rounded,
                              size: 58,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
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
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 4;

    // Background track ring
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    final value = progress.value.clamp(0.0, 1.0);
    if (value <= 0) return;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [AppColors.sky, AppColors.skyLight, AppColors.sky],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      value * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
