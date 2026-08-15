import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/protection_analytics.dart';

class ProtectionTrendChart extends StatelessWidget {
  const ProtectionTrendChart({super.key, required this.days});

  final List<ProtectionAnalyticsDay> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final hasData = days.any((d) => d.blocked > 0 || d.interventions > 0);
    final maxValue = days.fold<int>(
      1,
      (value, day) => math.max(value, math.max(day.blocked, day.interventions)),
    );
    final summary = l10n.analyticsChartSummary(
      days.fold<int>(0, (sum, day) => sum + day.blocked),
      days.fold<int>(0, (sum, day) => sum + day.interventions),
    );

    return Semantics(
      label: summary,
      child: SurfaceCard(
        elevated: false,
        radius: AppRadius.md,
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
                    _legendDot(AppColors.navy, l10n.analyticsLegendBlocked),
                    const SizedBox(width: 10),
                    _legendDot(AppColors.crimson, l10n.analyticsLegendInterventions),
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.azure.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bar_chart_rounded,
                                size: 24,
                                color: AppColors.navy,
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
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: disableAnimations ? 1.0 : 0.0,
                        end: 1.0,
                      ),
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, animation, _) => Row(
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
                                            ? Tooltip(
                                                message: l10n.analyticsDayTooltip(
                                                  day.blocked,
                                                  day.interventions,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    // Blocked Bar
                                                    FractionallySizedBox(
                                                      heightFactor:
                                                          _barHeight(
                                                                day.blocked,
                                                                maxValue,
                                                              ) *
                                                              animation,
                                                      child: Container(
                                                        width: days.length > 7
                                                            ? 4
                                                            : 8,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              AppColors.navy,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    4),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    // Interventions Bar
                                                    FractionallySizedBox(
                                                      heightFactor:
                                                          _barHeight(
                                                                day
                                                                    .interventions,
                                                                maxValue,
                                                              ) *
                                                              animation,
                                                      child: Container(
                                                        width: days.length > 7
                                                            ? 4
                                                            : 8,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              AppColors.crimson,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    4),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      days.length > 7
                                          ? DateFormat('d')
                                              .format(day.date.toLocal())
                                          : DateFormat.E(locale)
                                              .format(day.date.toLocal()),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Zero counts draw no bar at all; non-zero counts keep a visible minimum.
  static double _barHeight(int value, int maxValue) =>
      value == 0 ? 0.0 : (value / maxValue).clamp(0.05, 1.0);

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
