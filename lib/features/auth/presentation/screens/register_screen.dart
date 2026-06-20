import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/feedback/haptics.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../widgets/role_card.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'user';
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await ref.read(authProvider.notifier).register(
            _emailCtrl.text.trim(),
            _passCtrl.text,
            _nameCtrl.text.trim(),
          );
      if (user != null && mounted) {
        if (_role == 'partner') {
          context.go('/onboarding/create-group');
        } else {
          context.go('/onboarding');
        }
      }
    } catch (e) {
      setState(() => _error = AppMessages.friendlyMessage(e));
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(16)),
                    child: const Text('G', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 20),
                  const EyebrowPill(label: 'mulai gratis', color: AppColors.crimson),
                  const SizedBox(height: 14),
                  Text('Buat akun\nbaru.',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.navy, letterSpacing: -1.0, height: 1.05)),
                  const SizedBox(height: 8),
                  Text('100% gratis & privat — dirancang untuk mahasiswa Indonesia.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.navy.withValues(alpha: 0.55))),
                  const SizedBox(height: 28),
                  Text('Saya mendaftar sebagai',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.navy, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: RoleCard(icon: Icons.person, label: 'Mahasiswa', sub: 'Member', selected: _role == 'user', onTap: () => setState(() => _role = 'user'))),
                    const SizedBox(width: 12),
                    Expanded(child: RoleCard(icon: Icons.shield, label: 'Dosen / Pendamping', sub: 'Kepala', selected: _role == 'partner', onTap: () => setState(() => _role = 'partner'))),
                  ]),
                  const SizedBox(height: 20),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.crimson.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.crimson.withValues(alpha: 0.2))),
                      child: Text(_error!, style: const TextStyle(color: AppColors.crimson, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline))),
                  const SizedBox(height: 14),
                  TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 14),
                  TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outlined))),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.crimson, minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(_role == 'partner' ? 'Buat Akun & Lanjut ke Grup' : 'Daftar', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun?', style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6), fontSize: 14)),
                      TextButton(onPressed: () => context.go('/login'), child: const Text('Masuk', style: TextStyle(fontWeight: FontWeight.w700))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
