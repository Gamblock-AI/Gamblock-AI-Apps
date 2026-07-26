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
        Icons.download,
        AppLocalizations.of(context)!.introHowItWorksStep1,
        AppLocalizations.of(context)!.introHowItWorksStep1Desc,
      ),
      (
        '02',
        Icons.auto_awesome,
        AppLocalizations.of(context)!.introHowItWorksStep2,
        AppLocalizations.of(context)!.introHowItWorksStep2Desc,
      ),
      (
        '03',
        Icons.favorite,
        AppLocalizations.of(context)!.introHowItWorksStep3,
        AppLocalizations.of(context)!.introHowItWorksStep3Desc,
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
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.introHowItWorksTitle,
            style: displayStyle(context),
          ),
          const SizedBox(height: 24),
          ...steps.indexed.map((entry) {
            final s = entry.$2;
            final card = Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconChip(icon: s.$2, color: AppColors.crimson),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.$1,
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.$3,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.$4,
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 13,
                                height: 1.4,
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
