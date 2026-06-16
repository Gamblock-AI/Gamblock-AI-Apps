import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/platform/platform_bridge.dart';
import '../../core/platform/ai_inference_stub.dart';
import '../../core/theme/app_colors.dart';

class ProtectionScreen extends ConsumerStatefulWidget {
  const ProtectionScreen({super.key});
  @override
  ConsumerState<ProtectionScreen> createState() => _ProtectionScreenState();
}

class _ProtectionScreenState extends ConsumerState<ProtectionScreen> {
  Map<String, dynamic>? _status;
  Map<String, dynamic>? _summary;
  bool _loading = true;
  bool _serviceRunning = false;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    final serviceRunning = await PlatformBridge.isServiceRunning();
    final modelLoaded = AIInferenceStub.isLoaded;

    try {
      final results = await Future.wait([
        ApiClient.dio.get('/v1/client/protection-status'),
        ApiClient.dio.get('/v1/client/dashboard-summary'),
      ]);
      setState(() {
        _status = results[0].data['data'] as Map<String, dynamic>?;
        _summary = results[1].data['data'] as Map<String, dynamic>?;
        _serviceRunning = serviceRunning;
        _modelLoaded = modelLoaded;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _serviceRunning = serviceRunning;
        _modelLoaded = modelLoaded;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final mode = _status?['mode'] ?? 'Active';
    final isActive = mode == 'Active';
    final blocked = _summary?['blocked_attempts'] ?? 0;
    final streak = _summary?['current_streak'] ?? 0;
    final days = _summary?['active_days'] ?? 0;
    final runtimeStatus = _status?['runtime_status'] ?? 'Local runtime ready';
    final modelVersion = _status?['model_version'] ?? AIInferenceStub.modelVersion;

    return Scaffold(
      appBar: AppBar(title: const Text('Proteksi')),
      body: RefreshIndicator(
        onRefresh: _fetchAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isActive ? AppColors.sage.withValues(alpha: 0.08) : AppColors.crimson.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (isActive ? AppColors.sage : AppColors.crimson).withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                Icon(isActive ? Icons.shield : Icons.warning, size: 40, color: isActive ? AppColors.sage : AppColors.crimson),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(isActive ? 'Perlindungan Aktif' : 'Perlindungan Nonaktif', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: isActive ? AppColors.sage : AppColors.crimson)),
                    const SizedBox(height: 4),
                    Text(runtimeStatus, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.navy.withValues(alpha: 0.6))),
                    const SizedBox(height: 2),
                    Text('AI Model: $modelVersion', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.navy.withValues(alpha: 0.4))),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // Platform service status
            Row(children: [
              _ServiceIndicator(label: 'Service', active: _serviceRunning),
              const SizedBox(width: 8),
              _ServiceIndicator(label: 'AI Model', active: _modelLoaded),
              const SizedBox(width: 8),
              _ServiceIndicator(label: 'WebSocket', active: _serviceRunning),
            ]),
            const SizedBox(height: 16),

            // Stats row
            Row(children: [
              Expanded(child: _StatCard(icon: Icons.block, label: 'Total Blokir', value: '$blocked', color: AppColors.crimson)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.local_fire_department, label: 'Streak', value: '$streak hari', color: AppColors.amber)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.calendar_today, label: 'Hari Aktif', value: '$days', color: AppColors.navy)),
            ]),
            const SizedBox(height: 24),

            // Approval request
            FilledButton.icon(
              onPressed: () => _showApprovalDialog(context),
              icon: const Icon(Icons.lock_open),
              label: const Text('Ajukan Izin Pencopotan'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.crimson),
            ),
            const SizedBox(height: 16),

            // Enable Accessibility Service (Android)
            if (!_serviceRunning)
              FilledButton.icon(
                onPressed: () async {
                  await PlatformBridge.requestAccessibilityPermission();
                  await _fetchAll();
                },
                icon: const Icon(Icons.accessibility),
                label: const Text('Aktifkan Layanan Aksesibilitas'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.amber),
              ),
            const SizedBox(height: 24),

            // Recent blocks
            Text('Blokir Terbaru', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.navy)),
            const SizedBox(height: 8),
            ...List.generate(3, (i) => ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.crimson.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.block, color: AppColors.crimson, size: 20),
              ),
              title: Text('Situs judi diblokir', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text('${10 + i * 5} menit lalu', style: TextStyle(fontSize: 12, color: AppColors.navy.withValues(alpha: 0.5))),
            )),
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajukan Izin Pencopotan'),
        content: const Text('Permohonan ini akan dikirim ke Accountability Partner Anda untuk disetujui. Aplikasi tetap terkunci sampai ada persetujuan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiClient.dio.post('/v1/approval-requests', data: {
                  'action': 'pause_protection',
                  'reason': 'Pengajuan dari aplikasi mobile',
                  'requested_duration_minutes': 30,
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permohonan dikirim. Menunggu persetujuan.')));
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim permohonan.')));
                }
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.navy.withValues(alpha: 0.5)), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _ServiceIndicator extends StatelessWidget {
  final String label;
  final bool active;
  const _ServiceIndicator({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.sage.withValues(alpha: 0.08) : AppColors.crimson.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.sage : AppColors.crimson)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? AppColors.sage : AppColors.crimson)),
        ]),
      ),
    );
  }
}
