import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/entities/daily_mission.dart';

/// One server-verified mission row: title, fixed EXP value, and a truthful
/// locked/claimable/claimed/skipped state. The claim button is enabled only
/// from server-derived eligibility; the tile is never a completion toggle.
class MissionTaskTile extends StatelessWidget {
  const MissionTaskTile({
    super.key,
    required this.task,
    required this.claiming,
    required this.onClaim,
    required this.onLockedAction,
  });

  final MissionTask task;
  final bool claiming;
  final VoidCallback onClaim;
  final VoidCallback onLockedAction;

  String _title(AppLocalizations l10n) {
    switch (task.number) {
      case 1:
        return l10n.mission1;
      case 2:
        return l10n.mission2;
      case 3:
        return l10n.mission3;
      case 4:
        return l10n.mission4;
      default:
        return l10n.mission5;
    }
  }

  String _actionLabel(AppLocalizations l10n) {
    switch (task.number) {
      case 1:
        return l10n.missionAction1;
      case 2:
        return l10n.missionAction2;
      case 3:
        return l10n.missionAction3;
      case 4:
        return l10n.missionAction4;
      default:
        return l10n.missionAction5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final resolved = task.isResolved;

    final Color statusColor;
    final IconData statusIcon;
    if (resolved) {
      statusColor = AppColors.sage;
      statusIcon = task.completed
          ? Icons.check_circle_rounded
          : Icons.remove_circle_outline;
    } else if (task.claimable) {
      statusColor = AppColors.amber;
      statusIcon = Icons.star_rounded;
    } else {
      statusColor = AppColors.mutedForeground;
      statusIcon = Icons.lock_outline_rounded;
    }

    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return AnimatedContainer(
      duration: disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: task.claimable
            ? AppColors.amber.withValues(alpha: 0.08)
            : resolved
            ? AppColors.sage.withValues(alpha: 0.06)
            : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: task.claimable
              ? AppColors.amber.withValues(alpha: 0.4)
              : resolved
              ? AppColors.sage.withValues(alpha: 0.35)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  statusIcon,
                  size: AppIconSize.md,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(l10n),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                        height: 1.3,
                      ),
                    ),
                    if (!task.isPrimary)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.missionBonusLabel,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (context) {
                  final chip = Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color: AppColors.amber.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      l10n.missionExpReward(task.expReward),
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  );
                  if (disableAnimations || !task.completed) return chip;
                  // Small net-neutral "done" pulse when the claim lands.
                  return chip
                      .animate()
                      .scaleXY(end: 1.12, duration: 140.ms, curve: Curves.easeOut)
                      .then()
                      .scaleXY(end: 1 / 1.12, duration: 140.ms);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (task.completed)
            Row(
              children: [
                const Icon(
                  Icons.check_rounded,
                  size: AppIconSize.sm,
                  color: AppColors.sage,
                ),
                const SizedBox(width: 5),
                Text(
                  l10n.missionClaimedLabel,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.sage,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else if (task.status == 'skipped')
            Text(
              l10n.missionSkippedLabel,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (task.claimable)
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                onPressed: claiming ? null : onClaim,
                child: claiming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.missionClaim(task.expReward),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.missionLockedLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onLockedAction,
                  child: Text(
                    _actionLabel(l10n),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
