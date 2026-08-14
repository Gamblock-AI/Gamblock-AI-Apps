import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

class ColorChoiceButton extends StatelessWidget {
  const ColorChoiceButton({
    super.key,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
    this.selected = false,
    this.isCorrect,
    this.isDimmed = false,
  });

  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;
  final bool selected;
  final bool? isCorrect;
  final bool isDimmed;

  @override
  Widget build(BuildContext context) {
    IconData? feedbackIcon;
    Color effectiveBackgroundColor = color;
    Color effectiveForegroundColor =
        color == AppColors.amber ? AppColors.navyDark : Colors.white;
    List<BoxShadow> shadows = const [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ];
    BorderSide borderSide = BorderSide.none;

    if (selected) {
      if (isCorrect == true) {
        feedbackIcon = Icons.check_circle_rounded;
        effectiveBackgroundColor = AppColors.emerald;
        effectiveForegroundColor = Colors.white;
        borderSide = const BorderSide(color: Colors.white, width: 2.2);
        shadows = const [
          BoxShadow(
            color: Color(0x6610B981),
            blurRadius: 16,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ];
      } else if (isCorrect == false) {
        feedbackIcon = Icons.cancel_rounded;
        effectiveBackgroundColor = AppColors.crimson;
        effectiveForegroundColor = Colors.white;
        borderSide = const BorderSide(color: Colors.white, width: 2.2);
        shadows = const [
          BoxShadow(
            color: Color(0x66EF4444),
            blurRadius: 16,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ];
      }
    } else if (isCorrect == true) {
      feedbackIcon = Icons.check_circle_outline_rounded;
      effectiveBackgroundColor = AppColors.emerald;
      effectiveForegroundColor = Colors.white;
      borderSide = const BorderSide(color: Colors.white, width: 2.2);
      shadows = const [
        BoxShadow(
          color: Color(0x5510B981),
          blurRadius: 12,
          spreadRadius: 1,
          offset: Offset(0, 2),
        ),
      ];
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDimmed ? 0.30 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: isDimmed ? null : shadows,
        ),
        child: FilledButton(
          onPressed: enabled ? onTap : null,
          style: FilledButton.styleFrom(
            alignment: Alignment.center,
            backgroundColor: effectiveBackgroundColor,
            foregroundColor: effectiveForegroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              side: borderSide,
            ),
            elevation: 0,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (feedbackIcon != null) ...[
                  Icon(
                    feedbackIcon,
                    size: 20,
                    color: effectiveForegroundColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
