import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Explains whether the displayed aggregates have reached the backend yet.
class AnalyticsDataStateNotice extends StatelessWidget {
  const AnalyticsDataStateNotice({super.key, required this.dataState});

  final String? dataState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSynced = dataState == 'synced';
    final iconBg = isSynced
        ? AppColors.sage.withValues(alpha: 0.12)
        : AppColors.azure;
    final iconColor = isSynced ? AppColors.sage : AppColors.navy;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isSynced
              ? AppColors.sage.withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: AppColors.cardSoftShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isSynced ? Icons.cloud_done_rounded : Icons.shield_outlined,
              size: 22,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSynced
                      ? l10n.analyticsDataSynced
                      : l10n.analyticsDataLocalOnly,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.analyticsPrivacyNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                    fontSize: 12,
                    height: 1.45,
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
