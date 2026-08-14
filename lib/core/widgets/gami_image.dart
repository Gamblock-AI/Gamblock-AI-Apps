import 'package:flutter/material.dart';

/// Loads a Gami pose with a consistent, transparent fallback.
class GamiImage extends StatelessWidget {
  const GamiImage({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.semanticLabel,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final int? cacheWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      cacheWidth: cacheWidth,
      excludeFromSemantics: semanticLabel == null,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) {
        if (asset == 'assets/images/gami.webp') {
          return SizedBox(width: width, height: height);
        }
        return Image.asset(
          'assets/images/gami.webp',
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          cacheWidth: cacheWidth,
          excludeFromSemantics: semanticLabel == null,
          semanticLabel: semanticLabel,
        );
      },
    );
  }
}
