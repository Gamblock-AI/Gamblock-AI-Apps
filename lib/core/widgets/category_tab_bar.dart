import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// One category pill item for [CategoryTabBar].
class CategoryTab {
  final IconData icon;
  final String label;

  const CategoryTab(this.icon, this.label);
}

/// Horizontally scrollable category pills — mirrors the wireframe category
/// tabs. Active pill is filled with the blue accent + glow; inactive pills are
/// white cards with muted text.
class CategoryTabBar extends StatelessWidget {
  final List<CategoryTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsets padding;

  const CategoryTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            _CategoryPill(
              tab: tabs[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final CategoryTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: selected ? AppColors.accentGlow : AppColors.cardSoftShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              size: AppIconSize.sm,
              color: selected ? Colors.white : AppColors.inkMuted,
            ),
            const SizedBox(width: 6),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
