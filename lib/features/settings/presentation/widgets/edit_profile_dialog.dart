import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

/// Returns a non-empty display name selected in the profile editor.
Future<String?> showEditProfileDialog(
  BuildContext context, {
  required String? displayName,
}) async {
  final controller = TextEditingController(text: displayName);
  final value = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.settingsEditProfile),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 80,
        textCapitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.name],
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.authFullName,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    ),
  );
  controller.dispose();
  return value;
}
