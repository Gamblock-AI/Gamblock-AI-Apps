import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/accountability_models.dart';

/// Renders the local user's server-backed approval-request history.
class ApprovalRequestHistory extends StatelessWidget {
  const ApprovalRequestHistory({
    super.key,
    required this.requests,
    this.onCancel,
  });

  final List<ApprovalRequest> requests;
  final ValueChanged<ApprovalRequest>? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 16,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.partnerRequestHistory,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
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
          )
        else
          for (final request in requests)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                radius: AppRadius.md,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: (request.status == 'approved'
                                ? AppColors.sage
                                : request.status == 'denied'
                                    ? AppColors.crimson
                                    : AppColors.amber)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        request.status == 'approved'
                            ? Icons.check_circle_rounded
                            : request.status == 'denied'
                                ? Icons.cancel_rounded
                                : Icons.schedule_rounded,
                        color: request.status == 'approved'
                            ? AppColors.sage
                            : request.status == 'denied'
                                ? AppColors.crimson
                                : AppColors.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.actionLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            request.reason.isEmpty
                                ? request.statusLabel
                                : '${request.statusLabel} · ${request.reason}',
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (request.isPending && onCancel != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.crimson,
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => onCancel!(request),
                        child: Text(l10n.cancel),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
