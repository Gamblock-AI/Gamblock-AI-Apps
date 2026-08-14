import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/pressable.dart';

/// Clean, tactile, solid action button for mini games (reset, shuffle, pause, change difficulty).
/// Replaces the faint/transparent ghost OutlinedButton with a crisp solid surface.
class MiniGameActionButton extends StatelessWidget {
  const MiniGameActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && onTap != null;

    final bgColor = isInteractive
        ? Colors.white.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.55);
    final borderColor = isInteractive
        ? AppColors.navy.withValues(alpha: 0.12)
        : AppColors.navy.withValues(alpha: 0.05);
    final contentColor = isInteractive
        ? AppColors.navyDark
        : AppColors.mutedForeground.withValues(alpha: 0.45);

    return Pressable(
      onTap: isInteractive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            if (isInteractive)
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: contentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: contentColor,
                fontSize: 13,
                fontWeight: isInteractive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
