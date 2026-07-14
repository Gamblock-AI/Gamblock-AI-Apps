import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Selectable role card on the register screen (Member vs Kepala — PRD §2.1).
class RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.navy
        : AppColors.navy.withValues(alpha: 0.4);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.navy.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.navy
                : AppColors.navy.withValues(alpha: 0.15),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.navy.withValues(alpha: 0.4),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
