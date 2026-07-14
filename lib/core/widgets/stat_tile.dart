import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'icon_chip.dart';

/// Stat tile — a light card with a tinted icon chip, a large navy value and a
/// muted label (mirrors the website dashboard stat cards).
class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.navy,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconChip(icon: icon, color: color, size: 40),
          const SizedBox(height: 14),
          Text(
            value,
            style: t.headlineSmall?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: t.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
