import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Weekly block-count bar chart. Seven bars; the last is highlighted as today.
class WeeklyTrendChart extends StatelessWidget {
  final List<int> weeklyBlocks;

  const WeeklyTrendChart({super.key, required this.weeklyBlocks});

  @override
  Widget build(BuildContext context) {
    final maxVal = weeklyBlocks.isEmpty
        ? 1
        : weeklyBlocks.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.08)),
      ),
      child: Column(children: [
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final h = maxVal > 0
                  ? (weeklyBlocks[i] / maxVal * 80).clamp(4.0, 80.0)
                  : 4.0;
              final isToday = i == 6;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${weeklyBlocks[i]}',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isToday
                                  ? AppColors.crimson
                                  : AppColors.navy.withValues(alpha: 0.5))),
                      const SizedBox(height: 4),
                      Container(
                          height: h,
                          decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.crimson
                                  : AppColors.navy.withValues(alpha: 0.3),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)))),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }
}
