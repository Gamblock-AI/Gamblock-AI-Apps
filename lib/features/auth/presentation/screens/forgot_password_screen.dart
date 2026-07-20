import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_state.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kata sandi berhasil diperbarui. Silakan masuk.'),
            ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode pemulihan baru telah diminta.')),
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
    return AuthScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandLockup(),
          const SizedBox(height: 24),
          AuthScreenHeader(
            title: _codeRequested
                ? 'Masukkan kode pemulihan'
                : 'Lupa kata sandi?',
            description: _codeRequested
                ? 'Kode 12 karakter telah dikirim bila email terdaftar. Kode berlaku 30 menit.'
                : 'Masukkan email akun. Kami akan mengirim kode tanpa membagikan status pendaftaran email.',
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
                  label: 'Email',
                  icon: Icons.email_outlined,
                  enabled: !_codeRequested,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) => (value?.contains('@') ?? false)
                      ? null
                      : 'Masukkan email yang valid.',
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
                        child: const Text('Ganti email'),
                      ),
                      TextButton(
                        onPressed: _loading ? null : _resendCode,
                        child: const Text('Kirim ulang kode'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AuthInputField(
                    controller: _codeController,
                    label: 'Kode pemulihan',
                    icon: Icons.password_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        (value?.replaceAll('-', '').trim().length == 12)
                        ? null
                        : 'Kode harus berisi 12 karakter.',
                  ),
                  const SizedBox(height: 14),
                  AuthInputField(
                    controller: _passwordController,
                    label: 'Kata sandi baru',
                    icon: Icons.lock_reset_outlined,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    validator: (value) => (value?.length ?? 0) >= 8
                        ? null
                        : 'Gunakan minimal 8 karakter.',
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          AuthSubmitButton(
            label: _codeRequested ? 'Buat kata sandi baru' : 'Kirim kode',
            isLoading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali ke login'),
          ),
        ],
      ),
    );
  }
}
