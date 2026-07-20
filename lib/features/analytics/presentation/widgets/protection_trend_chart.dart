import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/protection_analytics.dart';

class ProtectionTrendChart extends StatelessWidget {
  const ProtectionTrendChart({super.key, required this.days});

  final List<ProtectionAnalyticsDay> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isId = Localizations.localeOf(context).languageCode == 'id';
    final hasData = days.any((d) => d.blocked > 0 || d.interventions > 0);
    final maxValue = days.fold<int>(
      1,
      (value, day) => math.max(value, math.max(day.blocked, day.interventions)),
    );
    final summary =
        '${days.fold<int>(0, (sum, day) => sum + day.blocked)} blocked, '
        '${days.fold<int>(0, (sum, day) => sum + day.interventions)} interventions';

    const idDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Semantics(
      label: summary,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.analyticsChartTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        days.length > 7 ? l10n.analytics30Days : l10n.analytics7Days,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _legendDot(AppColors.crimson, l10n.analyticsLegendBlocked),
                    const SizedBox(width: 10),
                    _legendDot(AppColors.navy, l10n.analyticsLegendInterventions),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.6)),
            const SizedBox(height: 16),

            // Chart Graphic Box
            SizedBox(
              height: 160,
              child: Stack(
                children: [
                  // Horizontal Grid Lines
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) => Container(
                        height: 1,
                        color: AppColors.border.withValues(alpha: 0.4),
                      ),
                    ),
                  ),

                  // Empty State Overlay when data has zero counts
                  if (!hasData)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.navy.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.auto_graph_rounded,
                                color: AppColors.navy.withValues(alpha: 0.45),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.analyticsNoActivityTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy.withValues(alpha: 0.8),
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.analyticsNoActivityDesc,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.mutedForeground,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Days & Bars Content
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final day in days)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: hasData
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                // Blocked Bar
                                                FractionallySizedBox(
                                                  heightFactor:
                                                      (day.blocked / maxValue)
                                                          .clamp(0.05, 1.0),
                                                  child: Container(
                                                    width: days.length > 7
                                                        ? 4
                                                        : 8,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.crimson,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                        top: Radius.circular(4),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                // Interventions Bar
                                                FractionallySizedBox(
                                                  heightFactor: (day
                                                              .interventions /
                                                          maxValue)
                                                      .clamp(0.05, 1.0),
                                                  child: Container(
                                                    width: days.length > 7
                                                        ? 4
                                                        : 8,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.navy,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                        top: Radius.circular(4),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    days.length > 7
                                        ? DateFormat('d').format(day.date.toLocal())
                                        : (isId
                                            ? idDays[day.date.toLocal().weekday - 1]
                                            : enDays[day.date.toLocal().weekday - 1]),
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.mutedForeground,
                                          fontSize: days.length > 7 ? 8 : 10,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
