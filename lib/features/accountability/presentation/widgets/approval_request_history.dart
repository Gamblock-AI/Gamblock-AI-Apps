import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
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
        Text(
          l10n.partnerRequestHistory,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
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
              child: Card(
                child: ListTile(
                  minTileHeight: 72,
                  leading: Icon(
                    request.status == 'approved'
                        ? Icons.check_circle_outline
                        : request.status == 'denied'
                        ? Icons.cancel_outlined
                        : Icons.schedule,
                    color: request.status == 'approved'
                        ? AppColors.sage
                        : request.status == 'denied'
                        ? AppColors.crimson
                        : AppColors.amber,
                  ),
                  title: Text(request.actionLabel),
                  subtitle: Text(
                    request.reason.isEmpty
                        ? request.statusLabel
                        : '${request.statusLabel} · ${request.reason}',
                  ),
                  trailing: request.isPending && onCancel != null
                      ? TextButton(
                          onPressed: () => onCancel!(request),
                          child: Text(l10n.cancel),
                        )
                      : null,
                ),
              ),
            ),
      ],
    );
  }
}
