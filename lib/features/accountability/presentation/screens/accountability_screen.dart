import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/feedback/feedback.dart';
import '../../../../core/messaging/app_messages.dart';
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
      builder: (context) => AlertDialog(
        title: Text(l10n.accountabilityJoinConfirmTitle),
        content: Text(l10n.accountabilityJoinConfirmBody(preview.partnerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.accountabilityJoinAction),
          ),
        ],
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
    var draft = membership.sharing;
    final saved = await showDialog<AccountabilitySharing>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Data agregat yang dibagikan'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Kesehatan perlindungan'),
                  subtitle: const Text(
                    'Status aktif, degradasi, dan izin — tanpa URL.',
                  ),
                  value: draft.protectionHealth,
                  onChanged: (value) => setDialogState(
                    () => draft = draft.copyWith(protectionHealth: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Aktivitas perlindungan'),
                  subtitle: const Text(
                    'Hitungan blokir dan intervensi agregat.',
                  ),
                  value: draft.protectionActivity,
                  onChanged: (value) => setDialogState(
                    () => draft = draft.copyWith(protectionActivity: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Keterlibatan pemulihan'),
                  subtitle: const Text(
                    'Ringkasan partisipasi, bukan isi jurnal atau mood.',
                  ),
                  value: draft.recoveryEngagement,
                  onChanged: (value) => setDialogState(
                    () => draft = draft.copyWith(recoveryEngagement: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Progres edukasi'),
                  value: draft.educationProgress,
                  onChanged: (value) => setDialogState(
                    () => draft = draft.copyWith(educationProgress: value),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Buang perubahan'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, draft),
              child: const Text('Simpan'),
            ),
          ],
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

  Future<void> _requestLeave(
    AccountabilityMembership membership,
    String kind,
  ) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          kind == 'unsafe'
              ? 'Keluar karena situasi tidak aman'
              : 'Ajukan keluar dari pendampingan',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kind == 'unsafe'
                  ? 'Berbagi data segera dihentikan dan permintaan normal yang tertunda dibatalkan.'
                  : 'Pendamping memiliki waktu hingga 72 jam untuk meninjau permintaan.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Alasan (opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Kirim permintaan'),
          ),
        ],
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
      appBar: AppBar(title: Text(l10n.partnerTitle)),
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
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        minTileHeight: 64,
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Privasi berbagi'),
                        subtitle: const Text(
                          'Atur jenis ringkasan agregat yang dapat dilihat pendamping.',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _loading
                            ? null
                            : () => _manageSharing(membership),
                      ),
                      const Divider(),
                      if (_overview?.pendingExitRequest case final exit?)
                        ListTile(
                          minTileHeight: 64,
                          leading: const Icon(Icons.schedule_outlined),
                          title: const Text(
                            'Permintaan keluar sedang ditinjau',
                          ),
                          subtitle: const Text(
                            'Anda dapat membatalkan permintaan normal selama masih tertunda.',
                          ),
                          trailing: exit.canCancel
                              ? TextButton(
                                  onPressed: _loading
                                      ? null
                                      : () => _cancelLeave(exit),
                                  child: const Text('Batalkan'),
                                )
                              : null,
                        )
                      else
                        ListTile(
                          minTileHeight: 64,
                          leading: const Icon(Icons.logout_outlined),
                          title: const Text('Keluar dari pendampingan'),
                          subtitle: const Text(
                            'Pilih alur normal atau hentikan berbagi segera bila situasi tidak aman.',
                          ),
                          trailing: PopupMenuButton<String>(
                            enabled: !_loading,
                            onSelected: (kind) =>
                                _requestLeave(membership, kind),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'normal',
                                child: Text('Ajukan keluar normal'),
                              ),
                              PopupMenuItem(
                                value: 'unsafe',
                                child: Text('Situasi tidak aman'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (membership == null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.accountabilityJoinTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.accountabilityJoinBody),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          autocorrect: false,
                          maxLength: 12,
                          decoration: InputDecoration(
                            labelText: l10n.onboardingGroupCode,
                            hintText: 'ABCD234567',
                          ),
                        ),
                        FilledButton(
                          onPressed: _loading ? null : _previewGroup,
                          child: Text(l10n.accountabilityPreviewAction),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_preview case final preview?) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            preview.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.accountabilityManagedBy(preview.partnerName),
                          ),
                          if (preview.description.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(preview.description),
                          ],
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _loading ? null : _joinGroup,
                            icon: const Icon(Icons.verified_user_outlined),
                            label: Text(l10n.accountabilityJoinAction),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
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
