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
        });
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
    if (token == null || _passCtrl.text.length < 8) {
      setState(() => _error = 'Kata sandi baru minimal 8 karakter.');
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
      if (user != null && mounted) context.go('/dashboard');
    } catch (error) {
      if (mounted) {
        setState(() => _error = AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await ref.read(authProvider.notifier).loginWithGoogle();
      if (user != null && mounted) {
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
            eyebrow: l10n.authLoginAgain,
            title: _passwordChangeToken == null
                ? l10n.authWelcomeBack
                : 'Buat kata sandi baru',
            description: _passwordChangeToken == null
                ? l10n.authLoginDesc
                : 'Kata sandi sementara hanya berlaku untuk langkah ini.',
          ),
          const SizedBox(height: 32),
          if (_error != null) ...[
            AuthFormError(message: _error!),
            const SizedBox(height: 16),
          ],
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      : 'Kata sandi baru',
                  icon: Icons.lock_outlined,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.authPasswordRequired;
                    }
                    if (_passwordChangeToken != null && value.length < 8) {
                      return 'Minimal 8 karakter';
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
                child: const Text('Lupa kata sandi?'),
              ),
            ),
          const SizedBox(height: 8),
          AuthSubmitButton(
            label: _passwordChangeToken == null
                ? l10n.authLoginBtn
                : 'Simpan dan masuk',
            isLoading: _loading,
            onPressed: _passwordChangeToken == null
                ? _submit
                : _submitInitialPassword,
          ),
          const SizedBox(height: 12),
          if (_passwordChangeToken == null)
            OutlinedButton.icon(
              onPressed: _loading ? null : _googleLogin,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Lanjutkan dengan Google'),
            ),
          if (_passwordChangeToken == null) const SizedBox(height: 16),
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
