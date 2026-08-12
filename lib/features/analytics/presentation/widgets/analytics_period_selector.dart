import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Glass period selector — mirrors the wireframe "date track": a translucent
/// pill track with a blue-gradient active pill for the chosen reporting period.
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: AppColors.cardSoftShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _PeriodPill(
              label: l10n.analyticsSevenDays,
              icon: Icons.calendar_today_rounded,
              selected: selectedDays == 7,
              onTap: () => onChanged(7),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _PeriodPill(
              label: l10n.analyticsThirtyDays,
              icon: Icons.date_range_rounded,
              selected: selectedDays == 30,
              onTap: () => onChanged(30),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.blueAccentGradient : null,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: selected ? AppColors.accentGlow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSize.sm,
              color: selected ? Colors.white : AppColors.inkMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
