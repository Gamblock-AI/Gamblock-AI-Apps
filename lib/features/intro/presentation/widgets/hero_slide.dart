import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'intro_hero_surface.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../../../../core/widgets/brand_helpers.dart';

/// First intro slide: brand hero.
class HeroSlide extends StatelessWidget {
  const HeroSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroHeroSurface(
      asset: 'assets/images/gami-wave.webp',
      fallbackAsset: 'assets/images/gami.webp',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowPill(
            label: AppLocalizations.of(context)!.introAiShield,
            color: AppColors.blueAccent,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.introHeroTitle,
            textAlign: TextAlign.left,
            style: displayStyle(context),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              AppLocalizations.of(context)!.introHeroDesc,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
