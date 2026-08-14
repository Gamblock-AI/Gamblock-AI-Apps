import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Branded busy indicator with a static reduced-motion fallback.
class AppBusyIndicator extends StatelessWidget {
  const AppBusyIndicator({
    super.key,
    this.size = 24,
    this.color = AppColors.navy,
    this.trackColor,
    this.strokeWidth = 2.5,
  });

  final double size;
  final Color color;
  final Color? trackColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_horiz_rounded, size: size * 0.68, color: color),
      );
    }

    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: strokeWidth,
            color: trackColor ?? color.withValues(alpha: 0.16),
          ),
          CircularProgressIndicator(
            strokeWidth: strokeWidth,
            strokeCap: StrokeCap.round,
            color: color,
          ),
        ],
      ),
    );
  }
}
