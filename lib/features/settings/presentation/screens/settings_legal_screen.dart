import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bar_title.dart';

/// A long-form legal/help section.
class SettingsLegalSection {
  const SettingsLegalSection({required this.title, required this.body});

  final String title;
  final List<String> body;
}

/// Shared layout for the in-app Privacy Policy and Help Center screens. It
/// mirrors the website's LegalPage (title, updated label, intro, numbered
/// sections) using the app's own theme tokens.
class SettingsLegalScreen extends StatelessWidget {
  const SettingsLegalScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.updatedLabel,
    required this.intro,
    required this.sections,
  });

  final IconData icon;
  final String title;
  final String updatedLabel;
  final String intro;
  final List<SettingsLegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: AppBarTitle(icon: icon, title: title),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            updatedLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.navyLight.withValues(alpha: 0.6),
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            intro,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedForeground,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < sections.length; i++) ...[
            _LegalSectionCard(
              number: i + 1,
              section: sections[i],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  const _LegalSectionCard({required this.number, required this.section});

  final int number;
  final SettingsLegalSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
            children: [
              TextSpan(
                text: '$number. ',
                style: const TextStyle(color: AppColors.crimson),
              ),
              TextSpan(text: section.title),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (final paragraph in section.body) ...[
          Text(
            paragraph,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedForeground,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
