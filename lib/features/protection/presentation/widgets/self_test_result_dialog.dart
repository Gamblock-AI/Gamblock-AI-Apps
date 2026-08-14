import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/gami_image.dart';

String _formatReasonCode(BuildContext context, String? rawCode) {
  if (rawCode == null || rawCode.isEmpty) {
    return AppLocalizations.of(context)!.selfTestFixtureBody;
  }
  final l10n = AppLocalizations.of(context)!;
  switch (rawCode) {
    case 'fixtures_passed':
    case 'fixture_passed':
      return l10n.selfTestFixtureBody;
    case 'native_bridge_unavailable':
      return l10n.selfTestNativeUnavailable;
    case 'artifact_integrity_failed':
      return l10n.selfTestIntegrityFailed;
    case 'fixture_mismatch':
      return l10n.selfTestFixtureMismatch;
    case 'artifact_invalid':
      return l10n.selfTestArtifactInvalid;
    case 'browser_sensor_disconnected':
      return l10n.selfTestSensorDisconnected;
    case 'permission_accessibility_missing':
      return l10n.selfTestAccessibilityMissing;
    default:
      return rawCode
          .split('_')
          .map(
            (word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                : '',
          )
          .join(' ');
  }
}

/// Presents the local dummy-artifact self-test result.
Future<void> showSelfTestResultDialog(
  BuildContext context,
  Map<String, dynamic> result,
) {
  final passed = result['passed'] == true;
  final l10n = AppLocalizations.of(context)!;
  final reasonCode = result['reason_code']?.toString();
  final formattedMessage = _formatReasonCode(context, reasonCode);
  final modelVersion = result['model_version']?.toString();
  final rulesetVersion = result['ruleset_version']?.toString();

  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                (passed ? AppColors.sage : AppColors.crimson).withValues(
                  alpha: 0.10,
                ),
                Colors.white,
              ),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.banner),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 104,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      color: (passed ? AppColors.sage : AppColors.crimson)
                          .withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                  GamiImage(
                    asset: passed
                        ? 'assets/images/gami-thumbsup.webp'
                        : 'assets/images/gami-peek.webp',
                    height: 98,
                    width: 110,
                    cacheWidth: 280,
                  ),
                  Positioned(
                    right: 88,
                    bottom: 3,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: passed ? AppColors.sage : AppColors.crimson,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        passed ? Icons.check_rounded : Icons.close_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              passed ? l10n.selfTestPassed : l10n.selfTestFailed,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formattedMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            if (modelVersion != null || rulesetVersion != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 12,
                      color: AppColors.navy,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Model: ${modelVersion ?? 'v1'} · Rules: ${rulesetVersion ?? 'v1'}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.navy,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.close,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
