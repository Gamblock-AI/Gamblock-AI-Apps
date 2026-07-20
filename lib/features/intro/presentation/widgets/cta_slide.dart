import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'slide_shell.dart';
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
          const SizedBox(height: 40),
          Image.asset('assets/images/gami-cta.webp', height: 180),
          const SizedBox(height: 24),
          EyebrowPill(
            label: AppLocalizations.of(context)!.introCtaBtn,
            color: AppColors.crimson,
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.introCtaTitle,
            textAlign: TextAlign.center,
            style: displayStyle(context),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.introCtaDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_android,
                color: AppColors.mutedForeground,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'android',
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.desktop_windows,
                color: AppColors.mutedForeground,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'windows',
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
