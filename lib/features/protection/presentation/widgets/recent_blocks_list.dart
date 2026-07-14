import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Static placeholder list of recent blocks. The backend only exposes aggregate
/// counts (privacy by design — PRD §3.4-C), so individual block entries are
/// illustrative until an aggregate timeline endpoint exists.
class RecentBlocksList extends StatelessWidget {
  final int count;

  const RecentBlocksList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.protectionRecentBlocks,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.navy),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          count,
          (i) => ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.crimson.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.block,
                color: AppColors.crimson,
                size: 20,
              ),
            ),
            title: Text(
              AppLocalizations.of(context)!.protectionSiteBlocked,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${10 + i * 5} menit lalu',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.navy.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
