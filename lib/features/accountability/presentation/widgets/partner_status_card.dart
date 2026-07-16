import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/accountability_models.dart';

/// Summarises whether the current account has an active accountability partner.
class PartnerStatusCard extends StatelessWidget {
  const PartnerStatusCard({super.key, required this.partner});

  final PartnerLink? partner;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPartner = partner != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasPartner ? Icons.verified_user : Icons.person_add_alt_1,
                  color: hasPartner ? AppColors.sage : AppColors.amber,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    partner?.email ?? l10n.partnerNone,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasPartner ? l10n.partnerActiveBody : l10n.partnerNoneBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
