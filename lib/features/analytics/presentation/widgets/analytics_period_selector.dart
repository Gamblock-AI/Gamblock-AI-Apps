import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';

/// Lets the user switch between the two supported aggregate reporting periods.
class AnalyticsPeriodSelector extends StatelessWidget {
  const AnalyticsPeriodSelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  final int selectedDays;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<int>(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.sky.withValues(alpha: 0.2),
        selectedForegroundColor: AppColors.navy,
        foregroundColor: AppColors.mutedForeground,
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      segments: [
        ButtonSegment(
          value: 7,
          label: Text(l10n.analyticsSevenDays),
          icon: const Icon(Icons.calendar_today_rounded, size: 16),
        ),
        ButtonSegment(
          value: 30,
          label: Text(l10n.analyticsThirtyDays),
          icon: const Icon(Icons.date_range_rounded, size: 16),
        ),
      ],
      selected: {selectedDays},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
