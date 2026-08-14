import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import 'highlight_headline.dart';

/// One immersive onboarding page. The generated art remains decorative while
/// Flutter renders localized copy, navigation, and accessibility semantics.
class OnboardingSlide extends StatelessWidget {
  final String portraitAsset;
  final String landscapeAsset;
  final Color markerColor;
  final String lead;
  final String highlight;
  final String tail;
  final String subtitle;
  final Widget action;
  final bool isActive;
  final double parallax;

  const OnboardingSlide({
    super.key,
    required this.portraitAsset,
    required this.landscapeAsset,
    required this.markerColor,
    required this.lead,
    required this.highlight,
    required this.tail,
    required this.subtitle,
    required this.action,
    this.isActive = true,
    this.parallax = 0,
  });

  /// Uses the landscape composition only for genuinely wide windows. A tablet
  /// held in portrait keeps the portrait artwork even when its width is large.
  static bool usesLandscapeLayout(Size size) =>
      size.width >= 720 && size.width >= size.height * 1.15;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final isWide = usesLandscapeLayout(size);
        final compactHeight = size.height < 680;
        final backgroundAsset = isWide ? landscapeAsset : portraitAsset;
        final effectiveParallax = disableAnimations ? 0.0 : parallax;
        final headlineSize = isWide
            ? (compactHeight ? 28.0 : 34.0)
            : (compactHeight ? 24.0 : 30.0);

        Widget content = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 480 : 410),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HighlightHeadline(
                lead: lead,
                highlight: highlight,
                tail: tail,
                textColor: Colors.white,
                markerColor: markerColor,
                fontSize: headlineSize,
              ),
              SizedBox(height: compactHeight ? 8 : 12),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: compactHeight ? 13 : 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: 0.1,
                  shadows: const [
                    Shadow(
                      color: Color(0x66000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compactHeight ? 16 : 24),
              Align(
                alignment: isWide
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: action,
              ),
            ],
          ),
        );

        if (!disableAnimations) {
          content = content
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 100.ms, duration: 320.ms)
              .slideY(
                begin: 0.06,
                end: 0,
                delay: 100.ms,
                duration: 360.ms,
                curve: Curves.easeOutCubic,
              );
        }

        return ColoredBox(
          color: AppColors.navyDark,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: -28,
                right: -28,
                top: -16,
                bottom: -16,
                child: Transform.translate(
                  offset: Offset(effectiveParallax * (isWide ? 18 : 12), 0),
                  child: Image.asset(
                    backgroundAsset,
                    key: const ValueKey('onboarding-background'),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                    excludeFromSemantics: true,
                    errorBuilder: (context, error, stackTrace) =>
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.navyGradient,
                          ),
                        ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: isWide
                          ? LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.navyDark.withValues(alpha: 0.96),
                                AppColors.navyDark.withValues(alpha: 0.82),
                                AppColors.navyDark.withValues(alpha: 0.20),
                                Colors.transparent,
                              ],
                              stops: const [0, 0.34, 0.66, 1],
                            )
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.navyDark.withValues(alpha: 0.08),
                                AppColors.navyDark.withValues(alpha: 0.18),
                                AppColors.navyDark.withValues(alpha: 0.76),
                                AppColors.navyDark.withValues(alpha: 0.96),
                              ],
                              stops: const [0, 0.46, 0.66, 1],
                            ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 64 : 24,
                    isWide ? 88 : 116,
                    isWide ? 32 : 24,
                    compactHeight ? 18 : 28,
                  ),
                  child: Align(
                    alignment: isWide
                        ? Alignment.centerLeft
                        : Alignment.bottomLeft,
                    child: content,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
