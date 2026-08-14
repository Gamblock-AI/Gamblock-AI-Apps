import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/accountability_models.dart';

/// Renders approval history as a compact, status-aware mobile timeline.
class ApprovalRequestHistory extends StatelessWidget {
  const ApprovalRequestHistory({
    super.key,
    required this.requests,
    this.onCancel,
  });

  final List<ApprovalRequest> requests;
  final ValueChanged<ApprovalRequest>? onCancel;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.sage;
      case 'denied':
      case 'rejected':
        return AppColors.crimson;
      case 'pending':
        return AppColors.amberDark;
      case 'expired':
      case 'cancelled':
      case 'canceled':
      default:
        return AppColors.navyLight;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_rounded;
      case 'denied':
      case 'rejected':
        return Icons.close_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      case 'expired':
        return Icons.history_rounded;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;
      default:
        return Icons.history_rounded;
    }
  }

  String _resolveActionTitle(BuildContext context, ApprovalRequest request) {
    final l10n = AppLocalizations.of(context)!;
    switch (request.action.toLowerCase()) {
      case 'uninstall_detected':
      case 'allow_uninstall':
        return l10n.accActionUninstall;
      case 'pause_protection':
        if (request.durationMinutes > 0) {
          return l10n.accActionPauseDuration(request.durationMinutes);
        }
        return l10n.accActionPause;
      case 'disable_service':
        return l10n.accActionDisable;
      case 'emergency_access':
        return l10n.accActionEmergency;
      default:
        final raw = request.actionLabel.trim();
        if (raw.isNotEmpty) {
          final lower = raw.toLowerCase();
          if (lower.contains('uninstall') || lower.contains('app removal')) {
            return l10n.accActionUninstall;
          }
          if (lower.contains('pause')) {
            if (request.durationMinutes > 0) {
              return l10n.accActionPauseDuration(request.durationMinutes);
            }
            return l10n.accActionPause;
          }
          if (lower.contains('disable')) {
            return l10n.accActionDisable;
          }
          if (lower.contains('emergency')) {
            return l10n.accActionEmergency;
          }
          return raw;
        }
        return request.action;
    }
  }

  String _resolveStatusLabel(BuildContext context, ApprovalRequest request) {
    final l10n = AppLocalizations.of(context)!;
    final key = request.status.toLowerCase();
    switch (key) {
      case 'approved':
        return l10n.accStatusApproved;
      case 'pending':
        return l10n.accStatusPending;
      case 'denied':
      case 'rejected':
        return l10n.accStatusDenied;
      case 'expired':
        return l10n.accStatusExpired;
      case 'cancelled':
      case 'canceled':
        return l10n.accStatusCancelled;
      default:
        final raw = request.statusLabel.trim();
        if (raw.isNotEmpty) {
          final labelKey = raw.toLowerCase();
          if (labelKey == 'approved' || labelKey == 'disetujui') {
            return l10n.accStatusApproved;
          }
          if (labelKey == 'pending' || labelKey == 'menunggu') {
            return l10n.accStatusPending;
          }
          if (labelKey == 'denied' ||
              labelKey == 'rejected' ||
              labelKey == 'ditolak') {
            return l10n.accStatusDenied;
          }
          if (labelKey == 'expired' || labelKey == 'kedaluwarsa') {
            return l10n.accStatusExpired;
          }
          if (labelKey == 'cancelled' ||
              labelKey == 'canceled' ||
              labelKey == 'dibatalkan') {
            return l10n.accStatusCancelled;
          }
          return raw;
        }
        return request.status;
    }
  }

  String _resolveReason(BuildContext context, String reason) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = reason.trim().toLowerCase();
    if (normalized == 'accessibility service disabled' ||
        normalized == 'accessibility_service_disabled' ||
        normalized == 'layanan aksesibilitas dinonaktifkan') {
      return l10n.accReasonAccessibilityDisabled;
    }
    if (normalized == 'troubleshooting app setup' ||
        normalized == 'troubleshooting_app_setup' ||
        normalized == 'perbaikan pengaturan aplikasi') {
      return l10n.accReasonTroubleshooting;
    }
    if (normalized == 'device administrator disabled' ||
        normalized == 'device_admin_disabled' ||
        normalized == 'administrator perangkat dinonaktifkan') {
      return l10n.accReasonDeviceAdminDisabled;
    }
    if (normalized == 'app update required' ||
        normalized == 'pembaruan aplikasi diperlukan') {
      return l10n.accReasonAppUpdate;
    }
    if (normalized == 'testing protection' ||
        normalized == 'pengujian perlindungan') {
      return l10n.accReasonTesting;
    }
    return reason;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 17,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              l10n.partnerRequestHistory,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.navyDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (requests.isEmpty)
          EmptyState(
            icon: Icons.inbox_outlined,
            title: l10n.partnerNoRequests,
            hint: l10n.partnerNoRequestsBody,
            compact: true,
          )
        else
          for (var index = 0; index < requests.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == requests.length - 1 ? 0 : 8,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 34,
                      child: Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _statusColor(
                                requests[index].status,
                              ).withValues(alpha: 0.13),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              _statusIcon(requests[index].status),
                              color: _statusColor(requests[index].status),
                              size: 17,
                            ),
                          ),
                          if (index < requests.length - 1)
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.navy.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildRequestCard(context, requests[index]),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, ApprovalRequest request) {
    final color = _statusColor(request.status);
    final actionText = _resolveActionTitle(context, request);
    final statusText = _resolveStatusLabel(context, request);
    final reasonText = _resolveReason(context, request.reason);

    return Semantics(
      container: true,
      label: '$actionText, $statusText',
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 11, 10, 11),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            color.withValues(alpha: 0.055),
            Colors.white.withValues(alpha: 0.94),
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actionText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDark,
                      fontSize: 13.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (reasonText.isNotEmpty) ...[
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            reasonText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (request.isPending && onCancel != null) ...[
              const SizedBox(width: 4),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.crimson,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                ),
                onPressed: () => onCancel!(request),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
