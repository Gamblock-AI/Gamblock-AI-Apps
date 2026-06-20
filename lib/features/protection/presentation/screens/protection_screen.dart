import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/protection_repository_impl.dart';
import '../../domain/entities/protection_status.dart';
import '../../domain/repositories/protection_repository.dart';
import '../../../dashboard/domain/entities/dashboard_summary.dart';
import '../../../../core/platform/platform_bridge.dart';
import '../../../../core/platform/ai_inference_stub.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_widgets.dart';
import '../widgets/stat_card.dart';
import '../widgets/service_indicator.dart';
import '../widgets/recent_blocks_list.dart';
import '../widgets/status_banner.dart';
import '../widgets/approval_request_dialog.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/feedback/feedback.dart';

class ProtectionScreen extends ConsumerStatefulWidget {
  const ProtectionScreen({super.key});
  @override
  ConsumerState<ProtectionScreen> createState() => _ProtectionScreenState();
}

final protectionRepositoryProvider = Provider<ProtectionRepository>((ref) {
  return ProtectionRepositoryImpl();
});

class _ProtectionScreenState extends ConsumerState<ProtectionScreen> {
  ProtectionStatus? _status;
  DashboardSummary? _summary;
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
    final repo = ref.read(protectionRepositoryProvider);
    try {
      final status = await repo.fetchStatus();
      final summary = await repo.fetchSummary();
      setState(() {
        _status = status;
        _summary = summary;
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

  Future<void> _submitApproval() async {
    final repo = ref.read(protectionRepositoryProvider);
    try {
      await repo.requestApproval(
        action: 'pause_protection',
        reason: 'Pengajuan dari aplikasi mobile',
        durationMinutes: 30,
      );
      if (mounted) {
        AppFeedback.success(context, 'Permohonan dikirim. Menunggu persetujuan.');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final status = _status;
    final isActive = status?.isActive ?? true;
    final blocked = _summary?.blockedAttempts ?? 0;
    final streak = _summary?.currentStreak ?? 0;
    final days = _summary?.activeDays ?? 0;
    final runtimeStatus = status?.runtimeStatus ?? 'Local runtime ready';
    final modelVersion = status?.modelVersion ?? AIInferenceStub.modelVersion;

    return Scaffold(
      appBar: AppBar(title: const Text('Proteksi')),
      body: RefreshIndicator(
        onRefresh: _fetchAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            EyebrowPill(label: 'perlindungan aktif', color: AppColors.sage),
            const SizedBox(height: 10),
            Text('Anda terlindungi.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.navy,
                    letterSpacing: -0.8,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('On-Device AI bekerja diam-diam di latar belakang perangkat Anda.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.navy.withValues(alpha: 0.55))),
            const SizedBox(height: 20),
            StatusBanner(isActive: isActive, runtimeStatus: runtimeStatus, modelVersion: modelVersion),
            const SizedBox(height: 12),
            Row(children: [
              ServiceIndicator(label: 'Service', active: _serviceRunning),
              const SizedBox(width: 8),
              ServiceIndicator(label: 'AI Model', active: _modelLoaded),
              const SizedBox(width: 8),
              ServiceIndicator(label: 'WebSocket', active: _serviceRunning),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: StatCard(
                      icon: Icons.block,
                      label: 'Total Blokir',
                      value: '$blocked',
                      color: AppColors.crimson)),
              const SizedBox(width: 12),
              Expanded(
                  child: StatCard(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '$streak hari',
                      color: AppColors.amber)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: StatCard(
                      icon: Icons.calendar_today,
                      label: 'Hari Aktif',
                      value: '$days',
                      color: AppColors.navy)),
              const SizedBox(width: 12),
              Expanded(
                  child: StatCard(
                      icon: Icons.self_improvement,
                      label: 'Mood',
                      value: '🙂',
                      color: AppColors.sage)),
            ]),
            const SizedBox(height: 24),
            const RecentBlocksList(),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showApprovalDialog(context),
              icon: const Icon(Icons.lock_open),
              label: const Text('Ajukan Izin Pencopotan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ApprovalRequestDialog(onConfirm: _submitApproval),
    );
  }
}

