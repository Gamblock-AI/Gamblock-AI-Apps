import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Provides the two native protection maintenance actions as full-width interactive cards (1 row per action).
class ProtectionActions extends StatelessWidget {
  const ProtectionActions({
    super.key,
    required this.isLoading,
    required this.onOpenSetup,
    required this.onRunSelfTest,
  });

  final bool isLoading;
  final VoidCallback onOpenSetup;
  final VoidCallback onRunSelfTest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _ActionCard(
          icon: Icons.tune_rounded,
          iconColor: AppColors.navy,
          iconBgColor: AppColors.navy.withValues(alpha: 0.08),
          title: l10n.protectionSetupAction,
          subtitle: l10n.setupPlatformTitle,
          isLoading: isLoading,
          onTap: onOpenSetup,
        ),
        const SizedBox(height: 10),
        _ActionCard(
          icon: Icons.science_outlined,
          iconColor: AppColors.navy,
          iconBgColor: AppColors.blueAccent.withValues(alpha: 0.14),
          title: l10n.selfTestAction,
          subtitle: l10n.setupSelfTestTitle,
          isLoading: isLoading,
          onTap: onRunSelfTest,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
            boxShadow: AppColors.cardSoftShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 1.5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.inkMuted.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
