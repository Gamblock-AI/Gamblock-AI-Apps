import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';

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
    setState(() { _loading = true; _error = null; });
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
      setState(() => _error = 'Pendaftaran gagal. Email mungkin sudah terdaftar.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add, size: 48, color: AppColors.navy),
                const SizedBox(height: 16),
                Text('Daftar Akun', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy), textAlign: TextAlign.center),
                const SizedBox(height: 32),

                // Role selector
                Text('Saya mendaftar sebagai', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.navy)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _RoleCard(icon: Icons.person, label: 'Mahasiswa', sub: 'Member', selected: _role == 'user', onTap: () => setState(() => _role = 'user'))),
                  const SizedBox(width: 12),
                  Expanded(child: _RoleCard(icon: Icons.shield, label: 'Dosen / Pendamping', sub: 'Kepala', selected: _role == 'partner', onTap: () => setState(() => _role = 'partner'))),
                ]),
                const SizedBox(height: 24),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.crimson.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.crimson.withValues(alpha: 0.2))),
                    child: Text(_error!, style: const TextStyle(color: AppColors.crimson, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
                TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 16),
                TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outlined))),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_role == 'partner' ? 'Buat Akun & Lanjut ke Grup' : 'Daftar'),
                ),
                const SizedBox(height: 16),
                TextButton(onPressed: () => context.go('/login'), child: const Text('Sudah punya akun? Masuk')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.label, required this.sub, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.navy : AppColors.navy.withValues(alpha: 0.15), width: selected ? 2 : 1),
          color: selected ? AppColors.navy.withValues(alpha: 0.05) : null,
        ),
        child: Column(children: [
          Icon(icon, color: selected ? AppColors.navy : AppColors.navy.withValues(alpha: 0.5), size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? AppColors.navy : AppColors.navy.withValues(alpha: 0.6)), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 10, color: AppColors.navy.withValues(alpha: 0.4))),
        ]),
      ),
    );
  }
}
