import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/feedback/feedback.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../accountability/domain/entities/accountability_models.dart';
import '../../domain/entities/protection_status.dart';
import '../protection_coordinator.dart';
import '../widgets/approval_request_dialog.dart';
import '../widgets/emergency_key_dialog.dart';
import '../widgets/protection_screen_body.dart';
import '../widgets/self_test_result_dialog.dart';

class ProtectionScreen extends ConsumerStatefulWidget {
  const ProtectionScreen({super.key});

  @override
  ConsumerState<ProtectionScreen> createState() => _ProtectionScreenState();
}

class _ProtectionScreenState extends ConsumerState<ProtectionScreen> {
  ProtectionStatus? _status;
  AccountabilityOverview? _accountability;
  List<ApprovalRequest> _requests = const [];
  EmergencyRequest? _emergencyRequest;
  Object? _error;
  bool _loading = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    ProtectionStatus status;
    try {
      status = await ProtectionCoordinator(ref).fetchLocalStatus();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loading = false;
        });
      }
      return;
    }
    if (mounted) setState(() => _status = status);

    final accountability = await ProtectionCoordinator(
      ref,
    ).loadAccountability(ref.read(authProvider));
    if (!mounted) return;
    setState(() {
      _accountability = accountability.accountability;
      _requests = accountability.requests;
      _emergencyRequest = accountability.emergencyRequest;
      _error = accountability.error;
      _loading = false;
    });
  }

  Future<void> _openSetup() async {
    await ProtectionCoordinator(ref).openPlatformSetup();
    await _load();
  }

  Future<void> _runSelfTest() async {
    setState(() => _actionLoading = true);
    final result = await ProtectionCoordinator(ref).runLocalSelfTest();
    if (!mounted) return;
    setState(() => _actionLoading = false);
    await showSelfTestResultDialog(context, result);
  }

  Future<void> _requestApproval() async {
    final auth = ref.read(authProvider);
    final membership = _accountability?.activeMembership;
    if (auth.deviceId == null || membership == null) return;
    final draft = await showDialog<ApprovalDraft>(
      context: context,
      builder: (_) => const ApprovalRequestDialog(),
    );
    if (draft == null || !mounted) return;
    await _runAccountabilityAction(
      () => ProtectionCoordinator(ref).requestApproval(
        deviceId: auth.deviceId!,
        membershipId: membership.id,
        action: draft.action,
        reason: draft.reason,
        durationMinutes: draft.durationMinutes,
      ),
      AppLocalizations.of(context)!.protectionRequestSent,
    );
  }

  Future<void> _applyApproval(ApprovalRequest request) async {
    final deviceId = ref.read(authProvider).deviceId;
    if (deviceId == null) return;
    await _runAccountabilityAction(
      () => ProtectionCoordinator(
        ref,
      ).applyApproval(requestId: request.id, deviceId: deviceId),
      AppLocalizations.of(context)!.protectionApprovalApplied,
    );
  }

  Future<void> _requestEmergency() async {
    final deviceId = ref.read(authProvider).deviceId;
    if (deviceId == null) return;
    await _runAccountabilityAction(
      () => ProtectionCoordinator(ref).requestEmergency(deviceId),
      AppLocalizations.of(context)!.emergencyRequestCreated,
    );
  }

  Future<void> _enterEmergencyKey() async {
    final key = await showEmergencyKeyDialog(context);
    final deviceId = ref.read(authProvider).deviceId;
    if (key == null || key.isEmpty || deviceId == null || !mounted) return;
    await _runAccountabilityAction(
      () => ProtectionCoordinator(
        ref,
      ).applyEmergencyKey(deviceId: deviceId, emergencyKey: key),
      AppLocalizations.of(context)!.emergencyKeyApplied,
    );
  }

  Future<void> _runAccountabilityAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() => _actionLoading = true);
    try {
      await action();
      if (mounted) AppFeedback.success(context, successMessage);
      await _load();
    } catch (error) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.protectionTitle),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ProtectionScreenBody(
        isLoading: _loading,
        isActionLoading: _actionLoading,
        status: _status,
        error: _error,
        auth: auth,
        accountability: _accountability,
        requests: _requests,
        emergencyRequest: _emergencyRequest,
        onRefresh: _load,
        onOpenSetup: _openSetup,
        onRunSelfTest: _runSelfTest,
        onRequestApproval: _requestApproval,
        onApplyApproval: _applyApproval,
        onManagePartner: () => context.go('/accountability'),
        onRequestEmergency: _requestEmergency,
        onEnterEmergencyKey: _enterEmergencyKey,
        onLogin: () => context.go('/login'),
        onOpenAccountSetup: () => context.go('/setup'),
      ),
    );
  }
}
