import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

/// The small invite form shown only when no partner is connected.
class PartnerInviteForm extends StatelessWidget {
  const PartnerInviteForm({
    super.key,
    required this.emailController,
    required this.isLoading,
    required this.onInvite,
  });

  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: l10n.partnerEmailLabel,
            helperText: l10n.partnerEmailHelp,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: isLoading ? null : onInvite,
          icon: const Icon(Icons.person_add_alt_1),
          label: Text(l10n.partnerInviteAction),
        ),
      ],
    );
  }
}
