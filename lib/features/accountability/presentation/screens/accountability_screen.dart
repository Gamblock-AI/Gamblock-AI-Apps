import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/partner_invite_form.dart';
import '../widgets/partner_invite_link_card.dart';
import '../widgets/partner_status_card.dart';

class AccountabilityScreen extends ConsumerStatefulWidget {
  const AccountabilityScreen({super.key});

  @override
  ConsumerState<AccountabilityScreen> createState() =>
      _AccountabilityScreenState();
}

class _AccountabilityScreenState extends ConsumerState<AccountabilityScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  Object? _error;
  PartnerOverview? _partners;
  List<ApprovalRequest> _requests = const [];
  String? _inviteUrl;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _emailController.dispose();
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
        repository.fetchPartners(),
        repository.fetchApprovalRequests(),
      ]);
      if (!mounted) return;
      setState(() {
        _partners = values[0] as PartnerOverview;
        _requests = values[1] as List<ApprovalRequest>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _invite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _loading = true);
    try {
      final invite = await ref
          .read(accountabilityRepositoryProvider)
          .invitePartner(email);
      if (!mounted) return;
      setState(() => _inviteUrl = invite.inviteUrl);
      AppFeedback.success(
        context,
        AppLocalizations.of(context)!.partnerInviteCreated,
      );
      await _load();
    } catch (error) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copyInviteUrl() async {
    final inviteUrl = _inviteUrl;
    if (inviteUrl == null) return;
    await Clipboard.setData(ClipboardData(text: inviteUrl));
    if (mounted) {
      AppFeedback.success(
        context,
        AppLocalizations.of(context)!.partnerInviteCopied,
      );
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

    final active = _partners?.activePartner;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.partnerTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (_loading && _partners == null)
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
              PartnerStatusCard(partner: active),
              if (active == null) ...[
                const SizedBox(height: 16),
                PartnerInviteForm(
                  emailController: _emailController,
                  isLoading: _loading,
                  onInvite: _invite,
                ),
              ],
              if (_inviteUrl != null && _inviteUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                PartnerInviteLinkCard(
                  inviteUrl: _inviteUrl!,
                  onCopy: _copyInviteUrl,
                ),
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
