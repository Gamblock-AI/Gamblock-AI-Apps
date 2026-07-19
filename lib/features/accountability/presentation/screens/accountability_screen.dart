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
              ApprovalRequestHistory(requests: _requests),
            ],
          ],
        ),
      ),
    );
  }
}
