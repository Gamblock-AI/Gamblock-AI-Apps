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
    this.size = 140,
  });

  final Animation<double> animation;
  final Animation<double> progress;
  final bool disableAnimations;
  final String semanticsLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Semantics(
        label: semanticsLabel,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = disableAnimations ? 0.5 : animation.value;
            final scale = disableAnimations ? 1.0 : 0.92 + (t * 0.08);
            final haloSize = size * 0.84;
            final coreSize = size * 0.64;
            final imageSize = size * 0.40;

            return Center(
              child: SizedBox(
                width: size,
                height: size,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: CustomPaint(
                    foregroundPainter: _ProgressRingPainter(progress),
                    child: Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ambient glowing halo
                            Container(
                              width: haloSize,
                              height: haloSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.sky.withValues(
                                  alpha: 0.12 + (t * 0.12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.sky.withValues(
                                      alpha: 0.28 * t + 0.15,
                                    ),
                                    blurRadius: 28 + (18 * t),
                                    spreadRadius: 4 + (8 * t),
                                  ),
                                ],
                              ),
                            ),
                            // Inner frosted glass core
                            Container(
                              width: coreSize,
                              height: coreSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.32),
                                    AppColors.skyDark.withValues(alpha: 0.40),
                                    const Color(0xFF0F172A).withValues(alpha: 0.70),
                                  ],
                                  stops: const [0.0, 0.65, 1.0],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.50 + (t * 0.25)),
                                  width: 1.4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    blurRadius: 12,
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/gami-meditate.webp',
                                  width: imageSize,
                                  height: imageSize,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.self_improvement_rounded,
                                    size: imageSize * 0.8,
                                    color: Colors.white.withValues(alpha: 0.95),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
