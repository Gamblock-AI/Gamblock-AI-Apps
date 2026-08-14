import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/pressable.dart';

enum BrainAnswerState { idle, correct, incorrect }

class BrainAnswerOption extends StatelessWidget {
  const BrainAnswerOption({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final BrainAnswerState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bgColor, borderColor, textColor, icon) = switch (state) {
      BrainAnswerState.correct => (
        AppColors.sageLight.withValues(alpha: 0.3),
        AppColors.sage,
        AppColors.sageDark,
        Icons.check_circle_rounded,
      ),
      BrainAnswerState.incorrect => (
        AppColors.crimsonLight.withValues(alpha: 0.3),
        AppColors.crimson,
        AppColors.crimson,
        Icons.cancel_rounded,
      ),
      BrainAnswerState.idle => (
        Colors.white.withValues(alpha: 0.95),
        AppColors.navy.withValues(alpha: 0.12),
        AppColors.navyDark,
        null,
      ),
    };

    return Pressable(
      onTap: state == BrainAnswerState.idle ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: borderColor,
            width: state == BrainAnswerState.idle ? 1.5 : 2.0,
          ),
          boxShadow: [
            if (state == BrainAnswerState.idle)
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15.5,
                    fontWeight: state == BrainAnswerState.idle
                        ? FontWeight.w700
                        : FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            if (icon != null)
              Positioned(
                right: 0,
                child: Icon(icon, color: textColor, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}
