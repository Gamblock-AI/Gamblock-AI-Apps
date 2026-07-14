import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'slide_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/brand_helpers.dart';

/// Second intro slide: the gambling crisis statistics.
class CrisisSlide extends StatelessWidget {
  const CrisisSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        'Rp286T',
        AppLocalizations.of(context)!.introCrisisStat2Desc,
        AppColors.crimson,
      ),
      (
        AppLocalizations.of(context)!.introCrisisStat2,
        AppLocalizations.of(context)!.introCrisisStat3Desc,
        AppColors.amber,
      ),
      (
        AppLocalizations.of(context)!.introCrisisStat1,
        AppLocalizations.of(context)!.introCrisisStat1Desc,
        AppColors.crimson,
      ),
    ];
    return SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowPill(
            label: AppLocalizations.of(context)!.introCrisisSubtitle,
            color: AppColors.crimson,
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.introCrisisTitle,
            style: displayStyle(context),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context)!.introCrisisDesc,
            style: TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...stats.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Text(
                      s.$1,
                      style: TextStyle(
                        color: s.$3,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(width: 16),
                    Expanded(
                      child: Text(
                        s.$2,
                        style: TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.introCrisisSource,
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
