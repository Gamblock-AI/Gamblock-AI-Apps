import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/protection_analytics.dart';

class ProtectionTrendChart extends StatelessWidget {
  const ProtectionTrendChart({super.key, required this.days});

  final List<ProtectionAnalyticsDay> days;

  @override
  Widget build(BuildContext context) {
    final maxValue = days.fold<int>(
      1,
      (value, day) => math.max(value, math.max(day.blocked, day.interventions)),
    );
    final locale = Localizations.localeOf(context).toLanguageTag();
    final labelFormat = DateFormat(days.length > 7 ? 'd' : 'E', locale);
    final summary =
        '${days.fold<int>(0, (sum, day) => sum + day.blocked)} blocked, '
        '${days.fold<int>(0, (sum, day) => sum + day.interventions)} interventions';

    return Semantics(
      label: summary,
      child: Container(
        height: 210,
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final day in days)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: (day.blocked / maxValue).clamp(
                              0.04,
                              1.0,
                            ),
                            child: Container(
                              width: days.length > 7 ? 5 : 14,
                              decoration: BoxDecoration(
                                color: AppColors.crimson,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labelFormat.format(day.date.toLocal()),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
    );
  }
}
