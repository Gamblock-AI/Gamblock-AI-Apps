import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'eyebrow_pill.dart';

/// Section heading — optional eyebrow pill, a navy title, and a muted subtitle
/// (mirrors the website's `SectionHeading`).
class SectionHeading extends StatelessWidget {
  final String? eyebrow;
  final Color eyebrowColor;
  final String title;
  final String? subtitle;

  const SectionHeading({
    super.key,
    this.eyebrow,
    this.eyebrowColor = AppColors.blueAccent,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          EyebrowPill(label: eyebrow!, color: eyebrowColor),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          style: t.headlineSmall?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: t.bodyMedium?.copyWith(
              color: AppColors.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
