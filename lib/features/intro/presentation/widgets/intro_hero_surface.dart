import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shared hero surface for the intro flow.
///
/// The artwork is intentionally decorative: the content remains the primary
/// layer while the robot gives the onboarding screen the same quiet,
/// editorial header treatment as the web experience.
class IntroHeroSurface extends StatelessWidget {
  final String asset;
  final String fallbackAsset;
  final Widget child;

  const IntroHeroSurface({
    super.key,
    required this.asset,
    required this.fallbackAsset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isWide = width >= 720;
        final compactHeight = height < 680;
        final horizontalPadding = isWide ? 48.0 : 22.0;
        // Keep the copy below the language/skip toolbar, which floats above
        // the page view in IntroScreen.
        final topPadding = compactHeight ? 60.0 : (isWide ? 64.0 : 60.0);
        final bottomPadding = isWide ? 96.0 : 100.0;
        final contentWidth = isWide ? 600.0 : 460.0;
        final bodyWidth = (width - horizontalPadding * 2)
            .clamp(0.0, double.infinity)
            .toDouble();
        final bodyHeight = (height - topPadding - bottomPadding)
            .clamp(0.0, double.infinity)
            .toDouble();

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.meshGradient),
            ),
            Positioned(
              right: isWide ? -width * 0.10 : -width * 0.17,
              top: isWide ? -height * 0.10 : height * 0.18,
              width: isWide ? width * 0.68 : width * 0.98,
              height: isWide ? height * 1.18 : height * 0.80,
              child: Opacity(opacity: isWide ? 0.30 : 0.30, child: _artwork()),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isWide
                      ? LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.surface.withValues(alpha: 0.97),
                            AppColors.surface.withValues(alpha: 0.58),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.54, 1],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.surface.withValues(alpha: 0.96),
                            AppColors.surface.withValues(alpha: 0.58),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.46, 1],
                        ),
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                bottomPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: bodyWidth,
                  maxWidth: bodyWidth,
                  minHeight: bodyHeight,
                ),
                child: Align(
                  alignment: isWide ? Alignment.centerLeft : Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _artwork() {
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      alignment: Alignment.centerRight,
      excludeFromSemantics: true,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        fallbackAsset,
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
        excludeFromSemantics: true,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
