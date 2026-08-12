import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'slide_shell.dart';
import 'intro_asset_stage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../../../../core/widgets/brand_helpers.dart';

/// First intro slide: brand hero.
class HeroSlide extends StatelessWidget {
  const HeroSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const IntroAssetStage(
            asset: 'assets/images/gami-wave.webp',
            fallbackAsset: 'assets/images/gami.webp',
            minImageSize: 188,
            maxImageSize: 240,
          ),
          const SizedBox(height: 20),
          EyebrowPill(
            label: AppLocalizations.of(context)!.introAiShield,
            color: AppColors.blueAccent,
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.introHeroTitle,
            textAlign: TextAlign.center,
            style: displayStyle(context),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Text(
              AppLocalizations.of(context)!.introHeroDesc,
              textAlign: TextAlign.center,
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
