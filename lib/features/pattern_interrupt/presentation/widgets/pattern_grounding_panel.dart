import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';

/// A quiet grounding exercise that gives users a direct route back to protection.
class PatternGroundingPanel extends StatelessWidget {
  const PatternGroundingPanel({super.key, required this.onReturnToProtection});

  final VoidCallback onReturnToProtection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('grounding'),
      children: [
        const Icon(Icons.self_improvement, color: AppColors.skyLight, size: 72),
        const SizedBox(height: 22),
        Text(
          l10n.patternGroundingTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.patternGroundingBody,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: onReturnToProtection,
          child: Text(l10n.patternReturnProtection),
        ),
      ],
    );
  }
}
