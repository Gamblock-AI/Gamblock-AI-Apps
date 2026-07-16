import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../domain/entities/protection_analytics.dart';

/// Displays the four aggregate protection counters in a responsive two-column grid.
class AnalyticsTotalsGrid extends StatelessWidget {
  const AnalyticsTotalsGrid({super.key, required this.totals});

  final ProtectionAnalyticsTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatTile(
          label: l10n.analyticsBlocked,
          value: '${totals.blocked}',
          icon: Icons.block,
          color: AppColors.crimson,
        ),
        StatTile(
          label: l10n.analyticsInterventions,
          value: '${totals.interventions}',
          icon: Icons.self_improvement,
          color: AppColors.navy,
        ),
        StatTile(
          label: l10n.analyticsTamper,
          value: '${totals.tamperEvents}',
          icon: Icons.security,
          color: AppColors.amber,
        ),
        StatTile(
          label: l10n.analyticsPermission,
          value: '${totals.permissionRevoked}',
          icon: Icons.warning_amber,
          color: AppColors.sage,
        ),
      ],
    );
  }
}
