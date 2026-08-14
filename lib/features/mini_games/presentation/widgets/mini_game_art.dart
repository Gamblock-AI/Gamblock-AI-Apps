import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';

class MiniGameArt extends StatelessWidget {
  const MiniGameArt({
    super.key,
    required this.icon,
    required this.color,
    required this.assetPath,
  });

  final IconData icon;
  final Color color;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: assetPath == null || assetPath!.isEmpty
          ? Icon(icon, color: color, size: 30)
          : Image.asset(
              assetPath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 30),
            ),
    );
  }
}
