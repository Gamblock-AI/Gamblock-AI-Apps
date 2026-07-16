import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';

/// Explains whether the displayed aggregates have reached the backend yet.
class AnalyticsDataStateNotice extends StatelessWidget {
  const AnalyticsDataStateNotice({super.key, required this.dataState});

  final String? dataState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSynced = dataState == 'synced';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isSynced
                  ? Icons.cloud_done_outlined
                  : Icons.phone_android_outlined,
              size: 18,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isSynced
                    ? l10n.analyticsDataSynced
                    : l10n.analyticsDataLocalOnly,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.analyticsPrivacyNote,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.mutedForeground,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
