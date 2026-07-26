import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A compact, consistently styled label for grouped settings or list sections.
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.mutedForeground,
          letterSpacing: 1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
