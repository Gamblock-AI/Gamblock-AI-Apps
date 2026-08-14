import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/messaging/app_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_busy_indicator.dart';

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.navyLight, AppColors.navy],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navyLight.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.settingsChangePassword,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Form(
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
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    _passwordField(
                      controller: _current,
                      focusNode: _currentFocus,
                      label: l10n.settingsCurrentPassword,
                      show: _showCurrent,
                      serverError: _currentServerError,
                      autofillHints: const [AutofillHints.password],
                      onToggle: () =>
                          setState(() => _showCurrent = !_showCurrent),
                      validator: (value) => value == null || value.isEmpty
                          ? l10n.msgErrPasswordValidation
                          : null,
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    _passwordField(
                      controller: _confirmation,
                      label: l10n.settingsConfirmPassword,
                      show: _showConfirmation,
                      autofillHints: const [AutofillHints.newPassword],
                      onToggle: () => setState(
                        () => _showConfirmation = !_showConfirmation,
                      ),
                      validator: (value) => value != _next.text
                          ? l10n.settingsPasswordMismatch
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.muted,
                          foregroundColor: AppColors.navy,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const AppBusyIndicator(
                                size: 16,
                                strokeWidth: 2,
                                color: Colors.white,
                                trackColor: Color(0x55FFFFFF),
                              )
                            : Text(
                                l10n.save,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        isDense: true,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
        suffixIcon: IconButton(
          tooltip: show ? l10n.settingsHidePassword : l10n.settingsShowPassword,
          onPressed: onToggle,
          icon: Icon(
            show ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
