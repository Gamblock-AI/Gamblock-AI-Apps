import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/feedback/haptics.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/auth/auth_state.dart';
import '../widgets/auth_brand_lockup.dart';
import '../widgets/auth_form_error.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_screen_frame.dart';
import '../widgets/auth_screen_header.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_switch_prompt.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _submitted = false;
  bool _loading = false;
  String? _error;
  String? _passwordChangeToken;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
      final user = await ref
          .read(authProvider.notifier)
          .login(_emailCtrl.text.trim(), _passCtrl.text);
      if (user?['password_change_required'] == true && mounted) {
        setState(() {
          _passwordChangeToken = user?['password_change_token']?.toString();
          _passCtrl.clear();
          _submitted = false;
        });
      } else if (user?['verification_required'] == true && mounted) {
        _goToPhoneVerification(user);
      } else if (user != null && mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = AppMessages.friendlyMessage(context, e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitInitialPassword() async {
    final token = _passwordChangeToken;
    setState(() {
      _submitted = true;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (token == null || _passCtrl.text.length < 8) {
      setState(
        () => _error = AppLocalizations.of(context)!.authPasswordChangeMin,
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await ref
          .read(authProvider.notifier)
          .completeInitialPasswordChange(token, _passCtrl.text);
      if (user?['verification_required'] == true && mounted) {
        _goToPhoneVerification(user);
      } else if (user != null && mounted) {
        context.go('/dashboard');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToPhoneVerification(Map<String, dynamic>? data) {
    final token = data?['verification_token']?.toString();
    if (token == null || token.isEmpty) return;
    final user = data?['user'];
    context.go(
      '/verify-phone',
      extra: {
        'verification_token': token,
        'phone': user is Map ? user['phone_e164']?.toString() ?? '' : '',
      },
    );
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
            title: _passwordChangeToken == null
                ? l10n.authWelcomeBack
                : l10n.authCreateNewPassword,
            description: _passwordChangeToken == null
                ? l10n.authLoginDesc
                : l10n.authTempPasswordDesc,
          ),
          const SizedBox(height: 32),
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
                if (_passwordChangeToken == null)
                  AuthInputField(
                    controller: _emailCtrl,
                    label: l10n.authEmail,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return l10n.msgErrEmailRequired;
                      if (!email.contains('@')) return l10n.authEmailInvalid;
                      return null;
                    },
                  ),
                if (_passwordChangeToken == null) const SizedBox(height: 14),
                AuthInputField(
                  controller: _passCtrl,
                  label: _passwordChangeToken == null
                      ? l10n.authPassword
                      : l10n.authNewPasswordLabel,
                  icon: Icons.lock_outlined,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.authPasswordRequired;
                    }
                    if (_passwordChangeToken != null && value.length < 8) {
                      return l10n.authPasswordMinShort;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _passwordChangeToken == null
                      ? _submit()
                      : _submitInitialPassword(),
                ),
              ],
            ),
          ),
          if (_passwordChangeToken == null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading
                    ? null
                    : () => context.go('/forgot-password'),
                child: Text(l10n.authForgotPassword),
              ),
            ),
          const SizedBox(height: 8),
          AuthSubmitButton(
            label: _passwordChangeToken == null
                ? l10n.authLoginBtn
                : l10n.authSaveAndLogin,
            isLoading: _loading,
            onPressed: _passwordChangeToken == null
                ? _submit
                : _submitInitialPassword,
          ),
          const SizedBox(height: 16),
          if (_passwordChangeToken == null)
            AuthSwitchPrompt(
              prompt: l10n.authNoAccount,
              actionLabel: l10n.authRegister,
              onAction: () => context.go('/register'),
            ),
        ],
      ),
    );
  }
}
