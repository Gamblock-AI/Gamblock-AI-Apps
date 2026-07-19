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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
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
          .register(
            _emailCtrl.text.trim(),
            _passCtrl.text,
            _nameCtrl.text.trim(),
          );
      if (user != null && mounted) {
        context.go('/setup');
      }
    } catch (e) {
      setState(() => _error = AppMessages.friendlyMessage(context, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandLockup(),
          const SizedBox(height: 24),
          AuthScreenHeader(
            eyebrow: l10n.authStartFree,
            title: l10n.authCreateAccountTitle,
            description: l10n.authRegisterDesc,
          ),
          const SizedBox(height: 28),
          if (_error != null) ...[
            AuthFormError(message: _error!),
            const SizedBox(height: 16),
          ],
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                AuthInputField(
                  controller: _nameCtrl,
                  label: l10n.authFullName,
                  icon: Icons.person_outline,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value?.trim().length ?? 0) < 3
                      ? l10n.authNameMinimum
                      : null,
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 14),
                AuthInputField(
                  controller: _passCtrl,
                  label: l10n.authPassword,
                  icon: Icons.lock_outlined,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  validator: (value) => (value?.length ?? 0) < 8
                      ? l10n.authPasswordMinimum
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AuthSubmitButton(
            label: l10n.authRegister,
            isLoading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 16),
          AuthSwitchPrompt(
            prompt: l10n.authHasAccount,
            actionLabel: l10n.authLoginBtn,
            onAction: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
