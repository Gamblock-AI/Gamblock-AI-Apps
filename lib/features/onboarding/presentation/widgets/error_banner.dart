import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Inline error banner used across onboarding forms.
class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.crimson.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.crimson.withValues(alpha: 0.2))),
      child: Text(message,
          style: const TextStyle(
              color: AppColors.crimson,
              fontSize: 13,
              fontWeight: FontWeight.w600)),
    );
  }
}
