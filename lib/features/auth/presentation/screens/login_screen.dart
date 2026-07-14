import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/feedback/haptics.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';

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
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child:
                ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Brand lockup
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/gamblock-1.png',
                                height: 44,
                              ),
                              const SizedBox(width: 10),
                              Text.rich(
                                TextSpan(
                                  children: const [
                                    TextSpan(
                                      text: 'Gamblock',
                                      style: TextStyle(
                                        color: AppColors.navy,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '-AI',
                                      style: TextStyle(
                                        color: AppColors.crimson,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          EyebrowPill(
                            label: AppLocalizations.of(context)!.authLoginAgain,
                            color: AppColors.crimson,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            AppLocalizations.of(context)!.authWelcomeBack,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: AppColors.navy,
                                  letterSpacing: -1.0,
                                  height: 1.05,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.authLoginDesc,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.navy.withValues(alpha: 0.55),
                                ),
                          ),
                          const SizedBox(height: 32),
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.crimson.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.crimson.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppColors.crimson,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(
                                context,
                              )!.authEmail,
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passCtrl,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(
                                context,
                              )!.authPassword,
                              prefixIcon: Icon(Icons.lock_outlined),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.crimson,
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.authLoginBtn,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.authNoAccount,
                                style: TextStyle(
                                  color: AppColors.navy.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/register'),
                                child: Text(
                                  AppLocalizations.of(context)!.authRegister,
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
          ),
        ),
      ),
    );
  }
}
