import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/widgets/gami_card.dart';
import '../../domain/entities/protection_analytics.dart';

/// Supportive appreciation card: frames blocks and interventions as helpful
/// pauses over the selected period. Aggregate counts only — never "today"
/// claims (analytics days are UTC-bucketed) and never fear or shame framing.
class ProtectionMilestoneCard extends StatelessWidget {
  const ProtectionMilestoneCard({super.key, required this.analytics});

  final ProtectionAnalytics? analytics;

  @override
  Widget build(BuildContext context) {
    final data = analytics;
    if (data == null) return const SizedBox.shrink();
    final helpedCount = data.totals.blocked + data.totals.interventions;
    if (helpedCount <= 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    // Owns its trailing gap so callers never duplicate the visibility rule.
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GamiCard(
        title: l10n.analyticsMilestoneTitle,
        message: l10n.analyticsMilestoneBody(helpedCount, data.periodDays),
      ),
    );
  }
}
