import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Wireframe section header row: title (16/700 ink) + trailing action that is
/// either a circular accent arrow button or a muted "View all" text link.
class AppSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onArrow;
  final VoidCallback? onViewAll;
  final String? viewAllLabel;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.onArrow,
    this.onViewAll,
    this.viewAllLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: t.titleMedium?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        if (onArrow != null)
          _ArrowButton(onTap: onArrow!)
        else if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.inkMuted,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              minimumSize: const Size(0, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              viewAllLabel ?? 'View all',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMuted,
              ),
            ),
          ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ArrowButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.blueAccent,
          shape: BoxShape.circle,
          boxShadow: AppColors.accentGlow,
        ),
        child: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.white,
          size: AppIconSize.sm,
        ),
      ),
    );
  }
}
