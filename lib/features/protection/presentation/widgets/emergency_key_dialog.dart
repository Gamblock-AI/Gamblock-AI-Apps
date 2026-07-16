import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

/// Collects an emergency key without retaining it outside the active dialog.
Future<String?> showEmergencyKeyDialog(BuildContext context) async {
  final controller = TextEditingController();
  final key = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.emergencyKeyTitle),
      content: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.characters,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.emergencyKeyLabel,
          helperText: AppLocalizations.of(context)!.emergencyKeyHelp,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: Text(AppLocalizations.of(context)!.submit),
        ),
      ],
    ),
  );
  controller.dispose();
  return key;
}
