import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../accountability/domain/entities/accountability_models.dart';

/// Keeps partner approval and emergency access actions together on Protection.
class ProtectionAccountabilityCard extends StatelessWidget {
  const ProtectionAccountabilityCard({
    super.key,
    required this.accountability,
    required this.requests,
    required this.emergencyRequest,
    required this.isLoading,
    required this.onRequestApproval,
    required this.onApplyApproval,
    required this.onManagePartner,
    required this.onRequestEmergency,
    required this.onEnterEmergencyKey,
  });

  final AccountabilityOverview? accountability;
  final List<ApprovalRequest> requests;
  final EmergencyRequest? emergencyRequest;
  final bool isLoading;
  final VoidCallback onRequestApproval;
  final ValueChanged<ApprovalRequest> onApplyApproval;
  final VoidCallback onManagePartner;
  final VoidCallback onRequestEmergency;
  final VoidCallback onEnterEmergencyKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final membership = accountability?.activeMembership;
    final pending = requests.where((request) => request.isPending).firstOrNull;
    final approved = requests.where((request) => request.canApply).firstOrNull;
    final requestInProgress =
        emergencyRequest?.status == 'pending' ||
        emergencyRequest?.status == 'reviewed' ||
        emergencyRequest?.status == 'approved';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              membership?.partnerName ?? l10n.partnerNone,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              membership == null
                  ? l10n.protectionPartnerRequired
                  : pending != null
                  ? l10n.protectionRequestPending
                  : approved != null
                  ? l10n.protectionRequestApproved
                  : l10n.protectionPartnerReady,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            if (approved != null)
              FilledButton.icon(
                onPressed: isLoading ? null : () => onApplyApproval(approved),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l10n.protectionApplyApproval),
              )
            else
              FilledButton.icon(
                onPressed: membership == null || pending != null || isLoading
                    ? null
                    : onRequestApproval,
                icon: const Icon(Icons.lock_clock_outlined),
                label: Text(
                  pending == null
                      ? l10n.protectionRequestAction
                      : l10n.protectionRequestPending,
                ),
              ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onManagePartner,
              icon: const Icon(Icons.people_outline),
              label: Text(l10n.partnerManageAction),
            ),
            const Divider(height: 28),
            Text(
              l10n.emergencyTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              emergencyRequest == null
                  ? l10n.emergencyBody
                  : l10n.emergencyStatus(emergencyRequest!.status),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading || requestInProgress
                        ? null
                        : onRequestEmergency,
                    child: Text(l10n.emergencyRequestAction),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onEnterEmergencyKey,
                    child: Text(l10n.emergencyEnterKeyAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
