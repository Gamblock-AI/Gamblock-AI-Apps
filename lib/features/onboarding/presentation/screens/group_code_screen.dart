import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/feedback/haptics.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../data/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/error_banner.dart';

class GroupCodeScreen extends ConsumerStatefulWidget {
  const GroupCodeScreen({super.key});
  @override
  ConsumerState<GroupCodeScreen> createState() => _GroupCodeScreenState();
}

class _GroupCodeScreenState extends ConsumerState<GroupCodeScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    Haptics.medium();
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length < 4) {
      setState(() => _error = 'Masukkan kode grup yang valid');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(organizationRepositoryProvider);
    try {
      await repo.joinByGroupCode(code);
      if (mounted) context.go('/protection');
    } catch (e) {
      setState(() => _error = AppMessages.friendlyMessage(e));
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
                const Icon(Icons.group_add, size: 56, color: AppColors.navy),
                const SizedBox(height: 16),
                Text('Masukkan Kode Grup',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: AppColors.navy),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Dapatkan kode dari Dosen atau Pendamping Anda',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.navy.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 40),
                if (_error != null) ...[
                  ErrorBanner(message: _error!),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                      color: AppColors.navy),
                  decoration: InputDecoration(
                    hintText: 'XXXXXX',
                    hintStyle: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        color: AppColors.navy.withValues(alpha: 0.2)),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Kode 6 karakter',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.navy.withValues(alpha: 0.4)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _loading ? null : _join,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Gabung'),
                ),
                const SizedBox(height: 24),
                TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Kembali ke Login')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
