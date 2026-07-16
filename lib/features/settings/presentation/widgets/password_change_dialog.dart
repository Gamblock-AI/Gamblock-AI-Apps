import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/feedback/feedback.dart';

class PasswordChange {
  const PasswordChange({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}

/// Validates a password change locally before the Settings screen submits it.
Future<PasswordChange?> showPasswordChangeDialog(BuildContext context) async {
  final current = TextEditingController();
  final next = TextEditingController();
  final confirmation = TextEditingController();
  final values = await showDialog<PasswordChange>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.settingsChangePassword),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.settingsCurrentPassword,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: next,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.settingsNewPassword,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmation,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.settingsConfirmPassword,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (next.text.length < 8 || next.text != confirmation.text) {
              AppFeedback.error(
                context,
                AppLocalizations.of(context)!.settingsPasswordMismatch,
              );
              return;
            }
            Navigator.pop(
              context,
              PasswordChange(
                currentPassword: current.text,
                newPassword: next.text,
              ),
            );
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    ),
  );
  current.dispose();
  next.dispose();
  confirmation.dispose();
  return values;
}
