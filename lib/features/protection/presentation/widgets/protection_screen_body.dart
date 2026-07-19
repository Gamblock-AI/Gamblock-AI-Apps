import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../accountability/domain/entities/accountability_models.dart';
import '../../domain/entities/protection_status.dart';
import 'protection_accountability_section.dart';
import 'protection_actions.dart';
import 'protection_status_card.dart';

/// Scrollable Protection content, kept separate from native state orchestration.
class ProtectionScreenBody extends StatelessWidget {
  const ProtectionScreenBody({
    super.key,
    required this.isLoading,
    required this.isActionLoading,
    required this.status,
    required this.error,
    required this.auth,
    required this.accountability,
    required this.requests,
    required this.emergencyRequest,
    required this.onRefresh,
    required this.onOpenSetup,
    required this.onRunSelfTest,
    required this.onRequestApproval,
    required this.onApplyApproval,
    required this.onManagePartner,
    required this.onRequestEmergency,
    required this.onEnterEmergencyKey,
    required this.onLogin,
    required this.onOpenAccountSetup,
  });

  final bool isLoading;
  final bool isActionLoading;
  final ProtectionStatus? status;
  final Object? error;
  final AuthState auth;
  final AccountabilityOverview? accountability;
  final List<ApprovalRequest> requests;
  final EmergencyRequest? emergencyRequest;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenSetup;
  final VoidCallback onRunSelfTest;
  final VoidCallback onRequestApproval;
  final ValueChanged<ApprovalRequest> onApplyApproval;
  final VoidCallback onManagePartner;
  final VoidCallback onRequestEmergency;
  final VoidCallback onEnterEmergencyKey;
  final VoidCallback onLogin;
  final VoidCallback onOpenAccountSetup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (isLoading && status == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            ProtectionStatusCard(status: status),
            const SizedBox(height: 16),
            ProtectionActions(
              isLoading: isActionLoading,
              onOpenSetup: onOpenSetup,
              onRunSelfTest: onRunSelfTest,
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              EmptyState(
                icon: Icons.cloud_off,
                title: l10n.protectionSyncError,
                hint: AppMessages.friendlyMessage(context, error!),
                actionLabel: l10n.retry,
                onAction: onRefresh,
              ),
            ],
            const SizedBox(height: 24),
            ProtectionAccountabilitySection(
              auth: auth,
              accountability: accountability,
              requests: requests,
              emergencyRequest: emergencyRequest,
              isLoading: isActionLoading,
              onRequestApproval: onRequestApproval,
              onApplyApproval: onApplyApproval,
              onManagePartner: onManagePartner,
              onRequestEmergency: onRequestEmergency,
              onEnterEmergencyKey: onEnterEmergencyKey,
              onLogin: onLogin,
              onOpenSetup: onOpenAccountSetup,
            ),
          ],
        ],
      ),
    );
  }
}
