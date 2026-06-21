import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Large active/inactive protection status banner shown at the top of the
/// protection screen.
class StatusBanner extends StatelessWidget {
  final bool isActive;
  final String runtimeStatus;
  final String modelVersion;

  const StatusBanner({
    super.key,
    required this.isActive,
    required this.runtimeStatus,
    required this.modelVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.sage.withValues(alpha: 0.08)
            : AppColors.crimson.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: (isActive ? AppColors.sage : AppColors.crimson).withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(isActive ? Icons.shield : Icons.warning,
            size: 40, color: isActive ? AppColors.sage : AppColors.crimson),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isActive ? AppLocalizations.of(context)!.protectionActiveTitle : AppLocalizations.of(context)!.protectionInactive,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isActive ? AppColors.sage : AppColors.crimson)),
            const SizedBox(height: 4),
            Text(runtimeStatus,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.navy.withValues(alpha: 0.6))),
            const SizedBox(height: 2),
            Text('AI Model: $modelVersion',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.navy.withValues(alpha: 0.4))),
          ]),
        ),
      ]),
    );
  }
}
