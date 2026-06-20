import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Small inline status pill for a platform service (Service / AI / WebSocket).
class ServiceIndicator extends StatelessWidget {
  final String label;
  final bool active;

  const ServiceIndicator({super.key, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.sage.withValues(alpha: 0.08)
              : AppColors.crimson.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.sage : AppColors.crimson)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.sage : AppColors.crimson)),
        ]),
      ),
    );
  }
}
