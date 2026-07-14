import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Confirmation dialog for submitting an uninstall/pause approval request to
/// the accountability partner (PRD §5). Calls [onConfirm] when approved.
class ApprovalRequestDialog extends StatelessWidget {
  final Future<void> Function() onConfirm;

  const ApprovalRequestDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.protectionRequestUninstall),
      content: Text(
        '${AppLocalizations.of(context)!.protectionApprovalDesc} ${AppLocalizations.of(context)!.protectionAppLockedDesc}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(context);
            await onConfirm();
          },
          child: Text(AppLocalizations.of(context)!.submit),
        ),
      ],
    );
  }
}
