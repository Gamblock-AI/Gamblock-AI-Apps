import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Static presentation stage for onboarding artwork.
///
/// The soft halo and grounding shadow are deliberately fixed so the artwork
/// feels anchored in the composition without introducing a floating effect.
class IntroAssetStage extends StatelessWidget {
  final String asset;
  final String fallbackAsset;
  final double minImageSize;
  final double maxImageSize;

  const IntroAssetStage({
    super.key,
    required this.asset,
    required this.fallbackAsset,
    this.minImageSize = 180,
    this.maxImageSize = 240,
  });

  @override
  Widget build(BuildContext context) {
    final imageSize = (MediaQuery.sizeOf(context).width * 0.52)
        .clamp(minImageSize, maxImageSize)
        .toDouble();

    return SizedBox(
      width: double.infinity,
      height: imageSize + 28,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: imageSize * 0.08,
            child: Container(
              width: imageSize * 0.94,
              height: imageSize * 0.76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.skyLight.withValues(alpha: 0.62),
                    AppColors.skyLight.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            child: Container(
              width: imageSize * 0.38,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sky.withValues(alpha: 0.20),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Image.asset(
            asset,
            height: imageSize,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              fallbackAsset,
              height: imageSize,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}
