import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../accountability/domain/entities/accountability_models.dart';

/// Keeps partner approval and emergency access actions together in a compact layout.
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

    final hasPartner = membership != null;

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Partner Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (hasPartner ? AppColors.navy : AppColors.mutedForeground)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people_alt_outlined,
                  color: hasPartner ? AppColors.navy : AppColors.mutedForeground,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membership?.partnerName ?? l10n.partnerNone,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      membership == null
                          ? l10n.protectionPartnerRequired
                          : pending != null
                              ? l10n.protectionRequestPending
                              : approved != null
                                  ? l10n.protectionRequestApproved
                                  : l10n.protectionPartnerReady,
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Side-by-Side Action Buttons for Partner Approval
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: approved != null
                      ? FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.sage,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () => onApplyApproval(approved),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              l10n.protectionApplyApproval,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      : FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed:
                              membership == null || pending != null || isLoading
                                  ? null
                                  : onRequestApproval,
                          icon: const Icon(Icons.lock_clock_outlined, size: 16),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              pending == null
                                  ? l10n.protectionRequestAction
                                  : l10n.protectionRequestPending,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      foregroundColor: AppColors.navy,
                      side: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onManagePartner,
                    icon: const Icon(Icons.person_search_outlined, size: 16),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n.partnerManageAction,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // Emergency Section Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.crimson.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.key_outlined,
                  color: AppColors.crimson,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.emergencyTitle,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                    ),
                    Text(
                      emergencyRequest == null
                          ? l10n.emergencyBody
                          : l10n.emergencyStatus(
                              _formatEmergencyStatus(
                                  context, emergencyRequest!.status),
                            ),
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Side-by-Side Action Buttons for Emergency
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      foregroundColor: AppColors.navy,
                      side: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading || requestInProgress
                        ? null
                        : onRequestEmergency,
                    child: Text(
                      l10n.emergencyRequestAction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      foregroundColor: AppColors.navy,
                      side: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : onEnterEmergencyKey,
                    child: Text(
                      l10n.emergencyEnterKeyAction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatEmergencyStatus(BuildContext context, String status) {
  final l10n = AppLocalizations.of(context)!;
  switch (status.toLowerCase()) {
    case 'pending':
      return l10n.statusPending;
    case 'reviewed':
      return l10n.statusReviewed;
    case 'approved':
      return l10n.statusApproved;
    case 'rejected':
    case 'denied':
      return l10n.statusRejected;
    case 'expired':
      return l10n.statusExpired;
    default:
      return status
          .split('_')
          .where((w) => w.isNotEmpty)
          .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
  }
}
