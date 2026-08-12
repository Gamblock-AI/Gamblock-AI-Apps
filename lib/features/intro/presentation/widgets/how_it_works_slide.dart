import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'intro_hero_surface.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/icon_chip.dart';
import '../../../../core/widgets/brand_helpers.dart';

/// Second intro slide: the three-step how-it-works flow.
class HowItWorksSlide extends StatelessWidget {
  const HowItWorksSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        '01',
        Icons.download_rounded,
        AppLocalizations.of(context)!.introHowItWorksStep1,
        AppLocalizations.of(context)!.introHowItWorksStep1Desc,
        AppColors.blueAccent,
      ),
      (
        '02',
        Icons.auto_awesome_rounded,
        AppLocalizations.of(context)!.introHowItWorksStep2,
        AppLocalizations.of(context)!.introHowItWorksStep2Desc,
        AppColors.skyDark,
      ),
      (
        '03',
        Icons.favorite_rounded,
        AppLocalizations.of(context)!.introHowItWorksStep3,
        AppLocalizations.of(context)!.introHowItWorksStep3Desc,
        AppColors.sage,
      ),
    ];
    final isWide = MediaQuery.sizeOf(context).width >= 760;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return IntroHeroSurface(
      asset: 'assets/images/gami-point.webp',
      fallbackAsset: 'assets/images/gami.webp',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowPill(
            label: AppLocalizations.of(context)!.introHowItWorksSubtitle,
            color: AppColors.navyLight,
          ),
          const SizedBox(height: 18),
          Text(
            AppLocalizations.of(context)!.introHowItWorksTitle,
            style: displayStyle(context),
          ),
          const SizedBox(height: 18),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: steps.indexed.map((entry) {
                final s = entry.$2;
                final card = _stepCard(s, isWide: true);
                final animated = disableAnimations
                    ? card
                    : card
                          .animate(delay: (100 + 60 * entry.$1).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(
                            begin: 0.05,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          );
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: entry.$1 == steps.length - 1 ? 0 : 10,
                    ),
                    child: animated,
                  ),
                );
              }).toList(),
            )
          else
            Column(
              children: steps.indexed.map((entry) {
                final s = entry.$2;
                final card = _stepCard(s, isWide: false);
                final animated = disableAnimations
                    ? card
                    : card
                          .animate(delay: (100 + 60 * entry.$1).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(
                            begin: 0.05,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          );
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.$1 == steps.length - 1 ? 0 : 10,
                  ),
                  child: animated,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _stepCard(
    (String, IconData, String, String, Color) step, {
    required bool isWide,
  }) {
    final number = step.$1;
    final icon = step.$2;
    final title = step.$3;
    final description = step.$4;
    final color = step.$5;

    return GlassCard(
      padding: EdgeInsets.all(isWide ? 14 : 15),
      child: isWide
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconChip(icon: icon, color: color, size: 40),
                    Text(
                      number,
                      style: const TextStyle(
                        color: AppColors.navyLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.7,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 12.5,
                    height: 1.36,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconChip(icon: icon, color: color, size: 42),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        number,
                        style: const TextStyle(
                          color: AppColors.navyLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.7,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 13,
                          height: 1.36,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
