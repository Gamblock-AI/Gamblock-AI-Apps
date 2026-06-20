import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/feedback/haptics.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../data/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/error_banner.dart';
import '../widgets/group_code_display.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  String? _groupCode;
  String? _groupName;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    Haptics.medium();
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Nama grup diperlukan');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(organizationRepositoryProvider);
    try {
      final org = await repo.create(name: name);
      setState(() {
        _groupCode = org.groupCode.isEmpty ? org.id : org.groupCode;
        _groupName = org.name;
      });
    } catch (e) {
      setState(() => _error = AppMessages.friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_groupCode != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GroupCodeDisplay(groupCode: _groupCode!, groupName: _groupName),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                const Icon(Icons.groups, size: 56, color: AppColors.navy),
                const SizedBox(height: 16),
                Text('Buat Grup Monitoring',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: AppColors.navy),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Sebagai Dosen/Pendamping, buat grup untuk mengawasi mahasiswa Anda',
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
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Grup',
                    hintText: 'Contoh: Kelas TI-2024A',
                    prefixIcon: Icon(Icons.group),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _loading ? null : _create,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Buat Grup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
