import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';

/// Shared eyebrow, title, and description hierarchy for auth screens.
class AuthScreenHeader extends StatelessWidget {
  const AuthScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EyebrowPill(label: eyebrow, color: AppColors.crimson),
        const SizedBox(height: 14),
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.navy,
            letterSpacing: -1.0,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.navy.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
