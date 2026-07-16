import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';

/// Presents the local dummy-artifact self-test result.
Future<void> showSelfTestResultDialog(
  BuildContext context,
  Map<String, dynamic> result,
) {
  final passed = result['passed'] == true;
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        passed ? Icons.check_circle_outline : Icons.error_outline,
        color: passed ? AppColors.sage : AppColors.crimson,
      ),
      title: Text(passed ? l10n.selfTestPassed : l10n.selfTestFailed),
      content: Text(
        result['reason_code']?.toString() ?? l10n.selfTestFixtureBody,
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}
