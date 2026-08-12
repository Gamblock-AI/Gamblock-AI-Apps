import 'package:flutter/material.dart';

/// Clips the colored intro header with a soft organic wave along its bottom
/// edge, mirroring the onboarding reference style. Purely decorative.
class WaveClipper extends CustomClipper<Path> {
  const WaveClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height * 0.72)
      ..cubicTo(
        size.width * 0.28,
        size.height * 1.04,
        size.width * 0.58,
        size.height * 0.56,
        size.width,
        size.height * 0.84,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
