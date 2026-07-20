import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';

/// Provides the two native protection maintenance actions in a compact side-by-side row.
class ProtectionActions extends StatelessWidget {
  const ProtectionActions({
    super.key,
    required this.isLoading,
    required this.onOpenSetup,
    required this.onRunSelfTest,
  });

  final bool isLoading;
  final VoidCallback onOpenSetup;
  final VoidCallback onRunSelfTest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                foregroundColor: AppColors.navy,
                side: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: AppColors.surface,
              ),
              onPressed: isLoading ? null : onOpenSetup,
              icon: const Icon(Icons.tune_rounded, size: 16, color: AppColors.navy),
              label: Text(
                l10n.protectionSetupAction,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 42,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                foregroundColor: AppColors.navy,
                side: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: AppColors.surface,
              ),
              onPressed: isLoading ? null : onRunSelfTest,
              icon: const Icon(Icons.science_outlined, size: 16, color: AppColors.navy),
              label: Text(
                l10n.selfTestAction,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
