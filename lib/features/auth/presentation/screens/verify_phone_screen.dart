import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/feedback/haptics.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/auth_brand_lockup.dart';
import '../widgets/auth_form_error.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_screen_frame.dart';
import '../widgets/auth_screen_header.dart';
import '../widgets/auth_submit_button.dart';

/// WhatsApp OTP verification shown after registration or when an unverified
/// account signs in. Uses the short-lived verification token from the backend;
/// a successful code routes the student to the login screen.
class VerifyPhoneScreen extends ConsumerStatefulWidget {
  const VerifyPhoneScreen({
    super.key,
    this.verificationToken,
    this.phone,
  });

  final String? verificationToken;
  final String? phone;

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  bool _resending = false;
  String? _error;
  String? _previewCode;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  String _maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return phone;
    return '${digits.substring(0, 3)}****${digits.substring(digits.length - 4)}';
  }

  Future<void> _verify() async {
    final token = widget.verificationToken;
    final l10n = AppLocalizations.of(context)!;
    if (token == null || token.isEmpty) {
      setState(() => _error = l10n.authVerifyMissingBody);
      return;
    }
    Haptics.medium();
    if (_codeCtrl.text.trim().length != 6) {
      setState(() => _error = l10n.authVerifyCodeInvalid);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await ref
          .read(authProvider.notifier)
          .verifyPhone(token, _codeCtrl.text.trim());
      if (!mounted) return;
      if (ok) {
        context.go('/login');
      } else {
        setState(() => _error = l10n.authVerifyError);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = AppMessages.friendlyMessage(context, e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final token = widget.verificationToken;
    if (token == null || token.isEmpty) return;
    setState(() {
      _resending = true;
      _error = null;
      _previewCode = null;
    });
    try {
      final previewCode = await ref
          .read(authProvider.notifier)
          .resendPhone(token);
      if (!mounted) return;
      setState(() => _previewCode = previewCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.authVerifySent)),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = AppMessages.friendlyMessage(context, e));
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasToken =
        widget.verificationToken != null && widget.verificationToken!.isNotEmpty;
    return AuthScreenFrame(
      animate: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandLockup(),
          const SizedBox(height: 24),
          AuthScreenHeader(
            title: hasToken ? l10n.authVerifyPhoneTitle : l10n.authVerifyMissingTitle,
            description: hasToken
                ? l10n.authVerifyPhoneDesc(_maskPhone(widget.phone ?? ''))
                : l10n.authVerifyMissingBody,
          ),
          const SizedBox(height: 28),
          if (_error != null) ...[
            AuthFormError(message: _error!),
            const SizedBox(height: 16),
          ],
          if (hasToken) ...[
            AuthInputField(
              controller: _codeCtrl,
              label: l10n.authVerifyCodeLabel,
              icon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _verify(),
              validator: (value) =>
                  (value?.trim().length ?? 0) == 6 ? null : l10n.authVerifyCodeInvalid,
            ),
            const SizedBox(height: 16),
            AuthSubmitButton(
              label: l10n.authVerifyButton,
              isLoading: _loading,
              onPressed: _verify,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _resending || _loading ? null : _resend,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(_resending ? l10n.authVerifyResending : l10n.authVerifyResend),
            ),
            if (_previewCode != null && _previewCode!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.azure,
                  borderRadius: BorderRadius.circular(AppRadius.banner),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_outlined, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.authVerifyPreviewCodeHint(_previewCode!),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(l10n.authBackToLogin),
            ),
          ],
        ],
      ),
    );
  }
}
