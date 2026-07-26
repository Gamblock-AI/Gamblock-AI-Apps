import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/feedback/feedback.dart';
import '../../../../core/feedback/haptics.dart';
import '../../../../core/messaging/app_messages.dart';
import '../widgets/auth_brand_lockup.dart';
import '../widgets/auth_form_error.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_screen_frame.dart';
import '../widgets/auth_screen_header.dart';
import '../widgets/auth_submit_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitted = false;
  bool _codeRequested = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    Haptics.medium();
    setState(() {
      _submitted = true;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = ref.read(authProvider.notifier);
      if (!_codeRequested) {
        await auth.requestPasswordReset(_emailController.text);
        if (mounted) {
          setState(() {
            _codeRequested = true;
            _submitted = false;
          });
        }
      } else {
        await auth.confirmPasswordReset(
          email: _emailController.text,
          code: _codeController.text,
          newPassword: _passwordController.text,
        );
        if (mounted) {
          AppFeedback.success(
            context,
            AppLocalizations.of(context)!.authResetSuccess,
          );
          context.go('/login');
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .requestPasswordReset(_emailController.text);
      if (mounted) {
        AppFeedback.success(
          context,
          AppLocalizations.of(context)!.authResetNewCodeRequested,
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _changeEmail() {
    setState(() {
      _submitted = false;
      _codeRequested = false;
      _codeController.clear();
      _passwordController.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScreenFrame(
      animate: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandLockup(),
          const SizedBox(height: 24),
          AuthScreenHeader(
            title: _codeRequested ? l10n.authResetTitleCode : l10n.authResetTitle,
            description:
                _codeRequested ? l10n.authResetDescCode : l10n.authResetDesc,
          ),
          const SizedBox(height: 28),
          if (_error != null) ...[
            AuthFormError(message: _error!),
            const SizedBox(height: 16),
          ],
          Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              children: [
                AuthInputField(
                  controller: _emailController,
                  label: l10n.authEmail,
                  icon: Icons.email_outlined,
                  enabled: !_codeRequested,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) => (value?.contains('@') ?? false)
                      ? null
                      : l10n.authEmailInvalid,
                  textInputAction: _codeRequested
                      ? TextInputAction.next
                      : TextInputAction.done,
                ),
                if (_codeRequested) ...[
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 4,
                    children: [
                      TextButton(
                        onPressed: _loading ? null : _changeEmail,
                        child: Text(l10n.authChangeEmail),
                      ),
                      TextButton(
                        onPressed: _loading ? null : _resendCode,
                        child: Text(l10n.authResendCode),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AuthInputField(
                    controller: _codeController,
                    label: l10n.authRecoveryCodeLabel,
                    icon: Icons.password_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        (value?.replaceAll('-', '').trim().length == 12)
                        ? null
                        : l10n.authRecoveryCodeInvalid,
                  ),
                  const SizedBox(height: 14),
                  AuthInputField(
                    controller: _passwordController,
                    label: l10n.authNewPasswordLabel,
                    icon: Icons.lock_reset_outlined,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    validator: (value) => (value?.length ?? 0) >= 8
                        ? null
                        : l10n.authPasswordMinChars,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          AuthSubmitButton(
            label: _codeRequested ? l10n.authCreateNewPassword : l10n.authSendCode,
            isLoading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.arrow_back),
            label: Text(l10n.authBackToLogin),
          ),
        ],
      ),
    );
  }
}
