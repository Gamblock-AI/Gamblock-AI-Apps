import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'highlight_headline.dart';
import 'mascot_stage.dart';
import 'wave_clipper.dart';

/// One onboarding page: a gradient wave-clipped header carrying a step badge,
/// the motivational headline, and a supporting subtitle; below it, a white
/// body holds the animated [MascotStage] framed by geometric doodles. The
/// mascot slightly overlaps the wave edge so header and body read as one
/// composition.
///
/// [isActive] drives the staggered entrance animations (replayed every time
/// the page becomes current) and [parallax] shifts the mascot and doodle
/// layers at different depths while swiping. Entrance animations are skipped
/// entirely when the platform requests reduced motion.
class OnboardingSlide extends StatelessWidget {
  final Color headerColor;
  final Color headerDark;
  final Color textColor;
  final Color markerColor;
  final Color? doodleColor;
  final String asset;
  final String fallbackAsset;
  final String lead;
  final String highlight;
  final String tail;
  final String subtitle;
  final String? stepBadge;
  final bool showHeart;
  final bool isActive;
  final double parallax;

  const OnboardingSlide({
    super.key,
    required this.headerColor,
    required this.headerDark,
    required this.textColor,
    required this.markerColor,
    required this.asset,
    required this.lead,
    required this.highlight,
    required this.tail,
    required this.subtitle,
    this.doodleColor,
    this.fallbackAsset = 'assets/images/gami.webp',
    this.stepBadge,
    this.showHeart = false,
    this.isActive = true,
    this.parallax = 0,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isWide = width >= 720;
        final compactHeight = height < 680;
        final headerHeight = height * (isWide ? 0.44 : 0.47);
        final mascotWidth = (width * (isWide ? 0.34 : 0.72)).clamp(
          180.0,
          isWide ? 380.0 : 360.0,
        );
        final bodyHeight = (height - headerHeight).clamp(0.0, double.infinity);
        final overlap = math.min(
          isWide ? 34.0 : 26.0,
          bodyHeight * 0.16,
        );
        final topInset = MediaQuery.viewPaddingOf(context).top;
        final doodles = doodleColor ?? headerColor;

        Widget headlineBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stepBadge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  stepBadge!,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            HighlightHeadline(
              lead: lead,
              highlight: highlight,
              tail: tail,
              textColor: textColor,
              markerColor: markerColor,
              fontSize: isWide ? 42 : (compactHeight ? 28 : 32),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.82),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
          ],
        );
        if (!disableAnimations) {
          headlineBlock = headlineBlock
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 120.ms, duration: 300.ms);
        }

        Widget header = ClipPath(
          clipper: const WaveClipper(),
          child: Container(
            width: double.infinity,
            height: headerHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [headerColor, headerDark],
              ),
            ),
            child: Stack(
              children: [
                // Darker echo of the wave edge, offset downward for depth.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -18,
                  height: headerHeight,
                  child: ClipPath(
                    clipper: const WaveClipper(),
                    child: ColoredBox(
                      color: headerDark.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                // Aurora blobs soften the gradient and add dimension.
                Positioned(
                  right: -70,
                  top: -60,
                  child: _aurora(250, 0.16),
                ),
                Positioned(
                  left: -50,
                  bottom: 30,
                  child: _aurora(170, 0.12),
                ),
                Positioned(
                  left: width * 0.48,
                  top: headerHeight * 0.24,
                  child: _aurora(110, 0.10),
                ),
                // Fine dot-grid texture.
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: const _DotTexturePainter()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 48 : 28,
                    topInset + (compactHeight ? 76 : 88),
                    isWide ? 48 : 28,
                    32,
                  ),
                  child: Align(
                    alignment: isWide
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: headlineBlock,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        if (!disableAnimations) {
          header = header
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: 350.ms)
              .slideY(
                begin: 0.08,
                end: 0,
                duration: 350.ms,
                curve: Curves.easeOutCubic,
              );
        }

        Widget mascot = MascotStage(
          asset: asset,
          fallbackAsset: fallbackAsset,
          mascotWidth: mascotWidth,
          accent: headerColor,
        );
        if (!disableAnimations) {
          mascot = mascot
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 180.ms, duration: 320.ms)
              .scale(
                begin: const Offset(0.92, 0.92),
                delay: 180.ms,
                duration: 320.ms,
                curve: Curves.easeOutBack,
              );
        }

        return ColoredBox(
          color: Colors.white,
          child: Column(
            children: [
              header,
              Expanded(
                child: Padding(
                  // Reserve room for the floating arrow button overlay.
                  padding: const EdgeInsets.only(bottom: 108),
                  child: Transform.translate(
                    offset: Offset(parallax * 14, 0),
                    child: CustomPaint(
                      painter: _DoodlesPainter(
                        accent: doodles,
                        showHeart: showHeart,
                      ),
                      child: Center(
                        child: Transform.translate(
                          // Lift the mascot so it overlaps the wave edge.
                          offset: Offset(parallax * 26, -overlap),
                          child: mascot,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _aurora(double diameter, double alpha) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: alpha),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// Fine dot grid drawn across the header for a subtle crafted texture.
class _DotTexturePainter extends CustomPainter {
  const _DotTexturePainter();

  static const _spacing = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    for (double y = _spacing / 2; y < size.height; y += _spacing) {
      for (double x = _spacing / 2; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), 1.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotTexturePainter oldDelegate) => false;
}

/// Geometric hand-drawn decorations framing the mascot: four-point sparkles,
/// rings, dots, and plus signs in the slide's header color (optionally a tiny
/// crimson heart as a brand accent). Kept away from the center so the mascot
/// composition stays clean.
class _DoodlesPainter extends CustomPainter {
  final Color accent;
  final bool showHeart;

  const _DoodlesPainter({required this.accent, this.showHeart = false});

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = accent.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = accent.withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;

    // Four-point sparkles at the corners of the composition.
    _sparkle(canvas, Offset(size.width * 0.13, size.height * 0.13), 11, fill);
    _sparkle(canvas, Offset(size.width * 0.88, size.height * 0.19), 8, fill);
    _sparkle(canvas, Offset(size.width * 0.17, size.height * 0.58), 8, fill);
    _sparkle(canvas, Offset(size.width * 0.85, size.height * 0.64), 10, fill);

    // Rings.
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.30), 7, line);
    canvas.drawCircle(Offset(size.width * 0.77, size.height * 0.42), 5, line);

    // Dots.
    canvas.drawCircle(Offset(size.width * 0.31, size.height * 0.09), 3.5, fill);
    canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.11), 3, fill);
    canvas.drawCircle(Offset(size.width * 0.10, size.height * 0.38), 3, fill);
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.46), 3.5, fill);

    // Plus signs near the bottom corners.
    _plus(canvas, Offset(size.width * 0.22, size.height * 0.76), 7, line);
    _plus(canvas, Offset(size.width * 0.80, size.height * 0.78), 6, line);

    // Small brand-accent heart on the self-care slide.
    if (showHeart) {
      final heart = Paint()
        ..color = const Color(0xFFC8102E).withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      _heart(canvas, Offset(size.width * 0.72, size.height * 0.20), 6.5, heart);
    }
  }

  /// A four-point sparkle: concave curves between the cardinal points.
  void _sparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final r = radius;
    final c = radius * 0.18;
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(center.dx + c, center.dy - c, center.dx + r, center.dy)
      ..quadraticBezierTo(center.dx + c, center.dy + c, center.dx, center.dy + r)
      ..quadraticBezierTo(center.dx - c, center.dy + c, center.dx - r, center.dy)
      ..quadraticBezierTo(center.dx - c, center.dy - c, center.dx, center.dy - r)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _plus(Canvas canvas, Offset center, double arm, Paint paint) {
    canvas.drawLine(
      center + Offset(0, -arm),
      center + Offset(0, arm),
      paint,
    );
    canvas.drawLine(
      center + Offset(-arm, 0),
      center + Offset(arm, 0),
      paint,
    );
  }

  void _heart(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy + radius)
      ..cubicTo(
        center.dx - radius * 1.4,
        center.dy - radius * 0.2,
        center.dx - radius * 0.6,
        center.dy - radius * 1.1,
        center.dx,
        center.dy - radius * 0.35,
      )
      ..cubicTo(
        center.dx + radius * 0.6,
        center.dy - radius * 1.1,
        center.dx + radius * 1.4,
        center.dy - radius * 0.2,
        center.dx,
        center.dy + radius,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DoodlesPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.showHeart != showHeart;
}
