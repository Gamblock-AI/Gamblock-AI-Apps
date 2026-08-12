import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// One entry in the FAB quick-actions sheet.
class QuickAction {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;

  const QuickAction({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.color,
  });
}

/// Bottom sheet launched from the center FAB with a few primary actions —
/// mirrors the wireframe FAB's "new item" sheet adapted to Gamblock.
Future<void> showQuickActionsSheet(
  BuildContext context, {
  required List<QuickAction> actions,
  required String title,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.banner),
        ),
        boxShadow: AppColors.cardSoftShadow,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inkMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.xs),
            _QuickActionTile(action: actions[i]),
          ],
        ],
      ),
    ),
  );
}

class _QuickActionTile extends StatelessWidget {
  final QuickAction action;
  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = action.color ?? AppColors.blueAccent;
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        action.onTap();
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(action.icon, color: color, size: AppIconSize.lg),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  if (action.subtitle != null)
                    Text(
                      action.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.inkMuted,
              size: AppIconSize.md,
            ),
          ],
        ),
      ),
    );
  }
}
