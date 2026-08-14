import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'haptics.dart';

/// Centralized, dismissible feedback with consistent status accents.
class AppFeedback {
  AppFeedback._();

  static void success(BuildContext context, String message) {
    Haptics.success();
    _show(
      context,
      message: message,
      icon: Icons.check_rounded,
      accent: AppColors.sageLight,
    );
  }

  static void error(BuildContext context, String message) {
    Haptics.error();
    _show(
      context,
      message: message,
      icon: Icons.priority_high_rounded,
      accent: AppColors.crimsonLight,
      background: AppColors.navyDark,
    );
  }

  static void info(BuildContext context, String message) {
    Haptics.selection();
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      accent: AppColors.sky,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color accent,
    Color background = AppColors.navy,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: accent.withValues(alpha: 0.28)),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: background,
          showCloseIcon: true,
          closeIconColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
          ),
        ),
      );
  }
}
