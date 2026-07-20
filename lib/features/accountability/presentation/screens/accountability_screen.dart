import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/feedback/feedback.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/providers.dart';
import '../../domain/entities/accountability_models.dart';
import '../widgets/approval_request_history.dart';
import '../widgets/partner_status_card.dart';

class AccountabilityScreen extends ConsumerStatefulWidget {
  const AccountabilityScreen({super.key});

  @override
  ConsumerState<AccountabilityScreen> createState() =>
      _AccountabilityScreenState();
}

class _AccountabilityScreenState extends ConsumerState<AccountabilityScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  Object? _error;
  AccountabilityOverview? _overview;
  AccountabilityGroupPreview? _preview;
  List<ApprovalRequest> _requests = const [];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!ref.read(authProvider).isAuthenticated) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(accountabilityRepositoryProvider);
      final values = await Future.wait<Object>([
        repository.fetchWorkspace(),
        repository.fetchApprovalRequests(),
      ]);
      if (!mounted) return;
      setState(() {
        _overview = values[0] as AccountabilityOverview;
        _requests = values[1] as List<ApprovalRequest>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _previewGroup() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final preview = await ref
          .read(accountabilityRepositoryProvider)
          .previewGroup(code);
      if (mounted) setState(() => _preview = preview);
    } catch (error) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinGroup() async {
    final preview = _preview;
    if (preview == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.group_add_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.accountabilityJoinConfirmTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.accountabilityJoinConfirmBody(preview.partnerName),
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: AppColors.navy,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          l10n.accountabilityJoinAction,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    try {
      final result = await ref
          .read(accountabilityRepositoryProvider)
          .joinGroup(_codeController.text);
      if (!mounted) return;
      setState(() {
        _overview = result;
        _preview = null;
        _codeController.clear();
      });
      AppFeedback.success(context, l10n.accountabilityJoinSuccess);
    } catch (error) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _manageSharing(AccountabilityMembership membership) async {
    final l10n = AppLocalizations.of(context)!;
    var draft = membership.sharing;
    final saved = await showDialog<AccountabilitySharing>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Agregat Dibagikan',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Atur preferensi data agregat anonim untuk pendamping.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedForeground,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSharingOptionTile(
                        context,
                        icon: Icons.health_and_safety_outlined,
                        title: 'Kesehatan Perlindungan',
                        subtitle: 'Status aktif, degradasi, & izin (tanpa URL).',
                        value: draft.protectionHealth,
                        onChanged: (value) => setDialogState(
                          () => draft = draft.copyWith(protectionHealth: value),
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 44,
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      _buildSharingOptionTile(
                        context,
                        icon: Icons.bar_chart_outlined,
                        title: 'Aktivitas Perlindungan',
                        subtitle: 'Hitungan pemblokiran & intervensi agregat.',
                        value: draft.protectionActivity,
                        onChanged: (value) => setDialogState(
                          () => draft = draft.copyWith(protectionActivity: value),
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 44,
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      _buildSharingOptionTile(
                        context,
                        icon: Icons.self_improvement_outlined,
                        title: 'Keterlibatan Pemulihan',
                        subtitle: 'Ringkasan partisipasi (bukan isi jurnal).',
                        value: draft.recoveryEngagement,
                        onChanged: (value) => setDialogState(
                          () => draft = draft.copyWith(recoveryEngagement: value),
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 44,
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      _buildSharingOptionTile(
                        context,
                        icon: Icons.school_outlined,
                        title: 'Progres Edukasi',
                        subtitle: 'Penyelesaian modul psikoedukasi harian.',
                        value: draft.educationProgress,
                        onChanged: (value) => setDialogState(
                          () => draft = draft.copyWith(educationProgress: value),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.navy,
                            padding: EdgeInsets.zero,
                            side: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.8)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            l10n.cancel,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext, draft),
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: Text(
                            l10n.save,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (saved == null || !mounted) return;
    await _runAction(
      () => ref
          .read(accountabilityRepositoryProvider)
          .updateSharing(membership.id, saved),
      'Preferensi berbagi diperbarui.',
    );
  }

  Widget _buildSharingOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.navy.withValues(alpha: 0.1)
                  : AppColors.mutedForeground.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: value ? AppColors.navy : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                        fontSize: 12,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                        fontSize: 10,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLeave(
    AccountabilityMembership membership,
    String kind,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();
    final isUnsafe = kind == 'unsafe';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isUnsafe
                              ? const [Color(0xFFEF4444), Color(0xFFDC2626)]
                              : const [Color(0xFFF59E0B), Color(0xFFD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: (isUnsafe
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFF59E0B))
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        isUnsafe
                            ? Icons.warning_amber_rounded
                            : Icons.exit_to_app_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUnsafe
                                ? 'Keluar Situasi Tidak Aman'
                                : 'Ajukan Keluar Pendampingan',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                  letterSpacing: -0.3,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isUnsafe
                                ? 'Berbagi data segera dihentikan dan permintaan normal dibatalkan.'
                                : 'Pendamping memiliki waktu 72 jam untuk meninjau permintaan.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedForeground,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLength: 500,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Alasan (opsional)',
                    hintText: 'Berikan penjelasan singkat...',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.navy, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: AppColors.navy,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(
                            l10n.cancel,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: isUnsafe
                                ? AppColors.crimson
                                : AppColors.navy,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text(
                            'Kirim Permintaan',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final reason = reasonController.text;
    reasonController.dispose();
    if (confirmed != true || !mounted) return;
    await _runAction(
      () => ref
          .read(accountabilityRepositoryProvider)
          .requestLeave(membership.id, kind: kind, reason: reason),
      'Permintaan keluar dikirim.',
    );
  }

  Future<void> _cancelLeave(AccountabilityExitRequest request) async {
    await _runAction(
      () => ref.read(accountabilityRepositoryProvider).cancelLeave(request.id),
      'Permintaan keluar dibatalkan.',
    );
  }

  Future<void> _cancelApproval(ApprovalRequest request) async {
    await _runAction(
      () =>
          ref.read(accountabilityRepositoryProvider).cancelApproval(request.id),
      'Permintaan persetujuan dibatalkan.',
    );
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String success,
  ) async {
    setState(() => _loading = true);
    try {
      await action();
      if (mounted) {
        AppFeedback.success(context, success);
      }
      await _load();
    } catch (error) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.partnerTitle)),
        body: EmptyState(
          icon: Icons.people_outline,
          title: l10n.partnerSignInTitle,
          hint: l10n.partnerSignInBody,
          actionLabel: l10n.authLoginBtn,
          onAction: () => context.go('/login'),
        ),
      );
    }

    final membership = _overview?.activeMembership;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.group_work_rounded,
                size: 18,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.partnerTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (_loading && _overview == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              EmptyState(
                icon: Icons.cloud_off,
                title: l10n.partnerErrorTitle,
                hint: AppMessages.friendlyMessage(context, _error!),
                actionLabel: l10n.retry,
                onAction: _load,
              )
            else ...[
              PartnerStatusCard(membership: membership),
              if (membership != null) ...[
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        minTileHeight: 64,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.navy.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.privacy_tip_outlined,
                            color: AppColors.navy,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          l10n.partnerSharingPrivacy,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          l10n.partnerSharingDesc,
                          style: const TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.mutedForeground,
                        ),
                        onTap: _loading
                            ? null
                            : () => _manageSharing(membership),
                      ),
                      Divider(
                        height: 1,
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      if (_overview?.pendingExitRequest case final exit?)
                        ListTile(
                          minTileHeight: 64,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.schedule_outlined,
                              color: AppColors.amber,
                              size: 18,
                            ),
                          ),
                          title: const Text(
                            'Permintaan keluar sedang ditinjau',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: const Text(
                            'Anda dapat membatalkan permintaan normal selama masih tertunda.',
                            style: TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 12,
                            ),
                          ),
                          trailing: exit.canCancel
                              ? TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.crimson,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onPressed: _loading
                                      ? null
                                      : () => _cancelLeave(exit),
                                  child: Text(l10n.cancel),
                                )
                              : null,
                        )
                      else
                        ListTile(
                          minTileHeight: 64,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.crimson.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.logout_outlined,
                              color: AppColors.crimson,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            l10n.partnerLeaveSection,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: const Text(
                            'Pilih alur normal atau hentikan berbagi segera bila situasi tidak aman.',
                            style: TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 12,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            enabled: !_loading,
                            onSelected: (kind) =>
                                _requestLeave(membership, kind),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'normal',
                                child: Text(l10n.partnerLeaveNormal),
                              ),
                              PopupMenuItem(
                                value: 'unsafe',
                                child: Text(l10n.partnerLeaveUnsafe),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (membership == null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.navy.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.group_add_rounded,
                              color: AppColors.navy,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.accountabilityJoinTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.accountabilityJoinBody,
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        autocorrect: false,
                        maxLength: 12,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingGroupCode,
                          hintText: 'ABCD234567',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _loading ? null : _previewGroup,
                          child: Text(
                            l10n.accountabilityPreviewAction,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_preview case final preview?) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          preview.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.accountabilityManagedBy(preview.partnerName),
                          style: const TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                        if (preview.description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            preview.description,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.sage,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _loading ? null : _joinGroup,
                            icon: const Icon(Icons.verified_user_outlined,
                                size: 18),
                            label: Text(
                              l10n.accountabilityJoinAction,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              ApprovalRequestHistory(
                requests: _requests,
                onCancel: _cancelApproval,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
