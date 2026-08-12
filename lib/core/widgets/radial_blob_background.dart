import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A single soft radial blob (mirrors the website pastel corner blobs):
/// `radial-gradient(circle, color 0%, transparent 70%)`.
class RadialBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double alpha;

  const RadialBlob({
    super.key,
    required this.color,
    this.size = 280,
    this.alpha = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// Full-screen decor backdrop with two soft corner blobs behind the content —
/// mirrors the website pastel mesh (`#EAF6FD` base with cyan/azure blobs).
/// Content sits above the blobs.
class BlobBackground extends StatelessWidget {
  final Widget child;
  final Color? blobColor;
  final Color? secondaryColor;
  final Color? backgroundColor;

  const BlobBackground({
    super.key,
    required this.child,
    this.blobColor = AppColors.skyLight,
    this.secondaryColor = AppColors.azure,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.background,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: RadialBlob(color: blobColor!, size: 300, alpha: 0.35),
          ),
          Positioned(
            top: -20,
            right: -60,
            child: RadialBlob(color: secondaryColor!, size: 250, alpha: 0.3),
          ),
          child,
        ],
      ),
    );
  }
}
