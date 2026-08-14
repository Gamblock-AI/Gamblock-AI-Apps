import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Highlights an authentication error beside the form that produced it.
class AuthFormError extends StatelessWidget {
  const AuthFormError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.crimson.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.82),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.crimson.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: AppColors.crimson.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.crimson.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.priority_high_rounded,
                size: 18,
                color: AppColors.crimson,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.crimsonDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
