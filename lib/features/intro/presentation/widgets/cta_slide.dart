import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'slide_shell.dart';
import 'intro_asset_stage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../../../../core/widgets/brand_helpers.dart';

/// Fifth/final intro slide: call-to-action.
class CtaSlide extends StatelessWidget {
  const CtaSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const IntroAssetStage(
            asset: 'assets/images/gami-cta.webp',
            fallbackAsset: 'assets/images/gami.webp',
            minImageSize: 176,
            maxImageSize: 220,
          ),
          const SizedBox(height: 18),
          EyebrowPill(
            label: AppLocalizations.of(context)!.introCtaBtn,
            color: AppColors.blueAccent,
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.introCtaTitle,
            textAlign: TextAlign.center,
            style: displayStyle(context),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Text(
              AppLocalizations.of(context)!.introCtaDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _platformBadge(
                icon: Icons.phone_android_rounded,
                label: AppLocalizations.of(context)!.introPlatformAndroid,
              ),
              _platformBadge(
                icon: Icons.desktop_windows_rounded,
                label: AppLocalizations.of(context)!.introPlatformWindows,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _platformBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.mutedForeground, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
