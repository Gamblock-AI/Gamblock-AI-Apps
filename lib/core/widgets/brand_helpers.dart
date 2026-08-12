import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Big display headline text style (mirrors web `text-display`). Defaults to
/// navy for the light theme.
TextStyle displayStyle(BuildContext context, {Color color = AppColors.navy}) =>
    Theme.of(context).textTheme.displaySmall!.copyWith(
      color: color,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.05,
    );

/// Primary brand CTA — a full-width pill button. `accent` uses crimson (the
/// website's action color); otherwise navy. `outline` renders a bordered light
/// button. Name kept (`darkCtaButton`) for back-compat with existing imports.
Widget darkCtaButton(
  BuildContext context,
  String label,
  VoidCallback onTap, {
  bool primary = true,
  bool accent = false,
  IconData? icon,
}) {
  final bg = accent ? AppColors.blueAccent : AppColors.navy;
  if (!primary) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(onPressed: onTap, child: _label(label, icon)),
    );
  }
  return SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size.fromHeight(54),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: _label(label, icon),
    ),
  );
}

Widget _label(String label, IconData? icon) {
  final text = Text(
    label,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );
  if (icon == null) return text;
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [Icon(icon, size: 20), const SizedBox(width: 8), text],
  );
}
