import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Glass search field — translucent white fill, hairline white border, soft
/// shadow and a search icon (mirrors the wireframe search bar).
class GlassSearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final Widget? trailing;

  const GlassSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: AppColors.cardSoftShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.inkMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: AppIconSize.md,
            color: AppColors.inkMuted,
          ),
          suffixIcon: trailing,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
        ),
      ),
    );
  }
}
