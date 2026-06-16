import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';

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
  bool _copied = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Nama grup diperlukan');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final response = await ApiClient.dio.post('/v1/organizations', data: {'name': name});
      final data = response.data['data'];
      if (data != null) {
        setState(() {
          _groupCode = data['group_code'] as String?;
          _groupName = data['name'] as String?;
        });
      }
    } catch (e) {
      setState(() => _error = 'Gagal membuat grup. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copyCode() {
    if (_groupCode != null) {
      Clipboard.setData(ClipboardData(text: _groupCode!));
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _copied = false); });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show group code after creation
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
                  const Icon(Icons.check_circle, size: 56, color: AppColors.sage),
                  const SizedBox(height: 16),
                  Text('Grup Berhasil Dibuat!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  if (_groupName != null) Text(_groupName!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.navy.withValues(alpha: 0.6))),
                  const SizedBox(height: 32),
                  Text('Kode Grup', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.navy.withValues(alpha: 0.6))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.navy.withValues(alpha: 0.15)),
                    ),
                    child: Text(_groupCode!, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 8, color: AppColors.navy)),
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: _copyCode, icon: Icon(_copied ? Icons.check : Icons.copy), label: Text(_copied ? 'Tersalin' : 'Salin'))),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton.icon(onPressed: () => context.go('/dashboard'), icon: const Icon(Icons.arrow_forward), label: const Text('Dashboard'))),
                  ]),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Creation form
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
                Text('Buat Grup Monitoring', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Sebagai Dosen/Pendamping, buat grup untuk mengawasi mahasiswa Anda', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.navy.withValues(alpha: 0.6)), textAlign: TextAlign.center),
                const SizedBox(height: 40),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.crimson.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.crimson.withValues(alpha: 0.2))),
                    child: Text(_error!, style: const TextStyle(color: AppColors.crimson, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
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
                  child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Buat Grup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
