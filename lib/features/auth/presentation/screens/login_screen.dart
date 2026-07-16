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
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    Haptics.medium();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await ref
          .read(authProvider.notifier)
          .login(_emailCtrl.text.trim(), _passCtrl.text);
      if (user != null && mounted) {
        context.go('/protection');
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
      animate: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandLockup(),
          const SizedBox(height: 24),
          AuthScreenHeader(
            eyebrow: l10n.authLoginAgain,
            title: l10n.authWelcomeBack,
            description: l10n.authLoginDesc,
          ),
          const SizedBox(height: 32),
          if (_error != null) ...[
            AuthFormError(message: _error!),
            const SizedBox(height: 16),
          ],
          AuthInputField(
            controller: _emailCtrl,
            label: l10n.authEmail,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AuthInputField(
            controller: _passCtrl,
            label: l10n.authPassword,
            icon: Icons.lock_outlined,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          AuthSubmitButton(
            label: l10n.authLoginBtn,
            isLoading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 16),
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
