import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Big display headline text style (mirrors web `text-display`).
TextStyle displayStyle(BuildContext context, {Color color = Colors.white}) =>
    Theme.of(context).textTheme.displaySmall!.copyWith(
      color: color,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.05,
    );

/// Crimson filled button used on dark surfaces.
Widget darkCtaButton(BuildContext context, String label, VoidCallback onTap,
    {bool primary = true}) {
  return SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: primary ? AppColors.crimson : Colors.white.withValues(alpha: 0.08),
        foregroundColor: primary ? Colors.white : Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: primary ? null : BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    ),
  );
}
