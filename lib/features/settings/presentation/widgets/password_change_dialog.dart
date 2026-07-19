import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/messaging/app_messages.dart';

class PasswordChange {
  const PasswordChange({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}

typedef SubmitPasswordChange = Future<void> Function(PasswordChange change);

/// Keeps the dialog open while the request runs so a rejected current password
/// can be corrected without re-entering every field.
Future<bool> showPasswordChangeDialog(
  BuildContext context, {
  required SubmitPasswordChange onSubmit,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PasswordChangeDialog(onSubmit: onSubmit),
  ).then((value) => value ?? false);
}

class _PasswordChangeDialog extends StatefulWidget {
  const _PasswordChangeDialog({required this.onSubmit});

  final SubmitPasswordChange onSubmit;

  @override
  State<_PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<_PasswordChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirmation = TextEditingController();
  final _currentFocus = FocusNode();
  final _nextFocus = FocusNode();
  bool _submitting = false;
  bool _showCurrent = false;
  bool _showNext = false;
  bool _showConfirmation = false;
  String? _currentServerError;
  String? _nextServerError;
  String? _formError;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirmation.dispose();
    _currentFocus.dispose();
    _nextFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentServerError = null;
      _nextServerError = null;
      _formError = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        PasswordChange(currentPassword: _current.text, newPassword: _next.text),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final code = AppMessages.codeOf(error);
      final message = AppMessages.friendlyMessage(context, error);
      setState(() {
        if (code == 'current_password_invalid') {
          _currentServerError = message;
        } else if (code == 'password_reuse_not_allowed') {
          _nextServerError = message;
        } else {
          _formError = message;
        }
      });
      if (code == 'current_password_invalid') {
        _currentFocus.requestFocus();
      } else if (code == 'password_reuse_not_allowed') {
        _nextFocus.requestFocus();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.settingsChangePassword),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_formError != null) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _formError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _passwordField(
                controller: _current,
                focusNode: _currentFocus,
                label: l10n.settingsCurrentPassword,
                show: _showCurrent,
                serverError: _currentServerError,
                autofillHints: const [AutofillHints.password],
                onToggle: () => setState(() => _showCurrent = !_showCurrent),
                validator: (value) => value == null || value.isEmpty
                    ? l10n.msgErrPasswordValidation
                    : null,
              ),
              const SizedBox(height: 12),
              _passwordField(
                controller: _next,
                focusNode: _nextFocus,
                label: l10n.settingsNewPassword,
                show: _showNext,
                serverError: _nextServerError,
                autofillHints: const [AutofillHints.newPassword],
                onToggle: () => setState(() => _showNext = !_showNext),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return l10n.settingsPasswordMismatch;
                  }
                  if (value == _current.text) {
                    return l10n.msgErrPasswordReuse;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _passwordField(
                controller: _confirmation,
                label: l10n.settingsConfirmPassword,
                show: _showConfirmation,
                autofillHints: const [AutofillHints.newPassword],
                onToggle: () =>
                    setState(() => _showConfirmation = !_showConfirmation),
                validator: (value) =>
                    value != _next.text ? l10n.settingsPasswordMismatch : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool show,
    required VoidCallback onToggle,
    required Iterable<String> autofillHints,
    required FormFieldValidator<String> validator,
    FocusNode? focusNode,
    String? serverError,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: !show,
      enabled: !_submitting,
      autofillHints: autofillHints,
      forceErrorText: serverError,
      validator: validator,
      onChanged: (_) {
        if (serverError == null) return;
        setState(() {
          if (controller == _current) _currentServerError = null;
          if (controller == _next) _nextServerError = null;
        });
      },
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          tooltip: show ? l10n.settingsHidePassword : l10n.settingsShowPassword,
          onPressed: onToggle,
          icon: Icon(show ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }
}
