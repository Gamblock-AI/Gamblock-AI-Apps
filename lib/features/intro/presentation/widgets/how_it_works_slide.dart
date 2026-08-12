import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'slide_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/icon_chip.dart';
import '../../../../core/widgets/brand_helpers.dart';

/// Third intro slide: the three-step how-it-works flow.
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
        AppColors.violetAccent,
      ),
    ];
    return SlideShell(
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
          const SizedBox(height: 22),
          ...steps.indexed.map((entry) {
            final s = entry.$2;
            final card = Padding(
              padding: EdgeInsets.only(
                bottom: entry.$1 == steps.length - 1 ? 0 : 12,
              ),
              child: GlassCard(
                padding: const EdgeInsets.all(17),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconChip(icon: s.$2, color: s.$5, size: 46),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.$1,
                            style: TextStyle(
                              color: AppColors.navyLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.7,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            s.$3,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.$4,
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 13.5,
                              height: 1.38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
            if (MediaQuery.disableAnimationsOf(context)) return card;
            return card
                .animate(delay: (100 + 60 * entry.$1).ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
          }),
        ],
      ),
    );
  }
}
