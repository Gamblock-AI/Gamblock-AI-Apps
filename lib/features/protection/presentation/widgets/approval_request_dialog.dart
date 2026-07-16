import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

class ApprovalDraft {
  const ApprovalDraft({
    required this.action,
    required this.reason,
    required this.durationMinutes,
  });

  final String action;
  final String reason;
  final int durationMinutes;
}

class ApprovalRequestDialog extends StatefulWidget {
  const ApprovalRequestDialog({super.key});

  @override
  State<ApprovalRequestDialog> createState() => _ApprovalRequestDialogState();
}

class _ApprovalRequestDialogState extends State<ApprovalRequestDialog> {
  final _reasonController = TextEditingController();
  String _action = 'pause_protection';
  int _duration = 30;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.protectionApprovalDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.protectionApprovalDialogBody),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _action,
              decoration: InputDecoration(
                labelText: l10n.protectionActionLabel,
              ),
              items: [
                DropdownMenuItem(
                  value: 'pause_protection',
                  child: Text(l10n.protectionPauseAction),
                ),
                DropdownMenuItem(
                  value: 'disable_protection',
                  child: Text(l10n.protectionDisableAction),
                ),
                DropdownMenuItem(
                  value: 'uninstall_detected',
                  child: Text(l10n.protectionUninstallAction),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _action = value);
              },
            ),
            if (_action == 'pause_protection') ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _duration,
                decoration: InputDecoration(
                  labelText: l10n.protectionDurationLabel,
                ),
                items: [15, 30, 60, 120]
                    .map(
                      (minutes) => DropdownMenuItem(
                        value: minutes,
                        child: Text(l10n.minutesCount(minutes)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _duration = value);
                },
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _reasonController,
              onChanged: (_) => setState(() {}),
              minLines: 2,
              maxLines: 4,
              maxLength: 240,
              decoration: InputDecoration(
                labelText: l10n.protectionReasonLabel,
                helperText: l10n.protectionReasonHelp,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _reasonController.text.trim().isEmpty
              ? null
              : () => Navigator.pop(
                  context,
                  ApprovalDraft(
                    action: _action,
                    reason: _reasonController.text.trim(),
                    durationMinutes: _action == 'pause_protection'
                        ? _duration
                        : 0,
                  ),
                ),
          child: Text(l10n.submit),
        ),
      ],
    );
  }
}
