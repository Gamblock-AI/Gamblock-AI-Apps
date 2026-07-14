import 'package:flutter/material.dart';

/// Brand icon chip (mirrors web feature icon tiles).
class IconChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconChip({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
