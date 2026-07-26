import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../data/missions_notifier.dart';
import '../../data/providers.dart';

/// Journey-title tiers shared verbatim with the website (`levelTitle1..7`).
String _levelTitle(AppLocalizations l10n, int level) {
  if (level >= 18) return l10n.levelTitle7;
  if (level >= 14) return l10n.levelTitle6;
  if (level >= 10) return l10n.levelTitle5;
  if (level >= 7) return l10n.levelTitle4;
  if (level >= 4) return l10n.levelTitle3;
  if (level >= 2) return l10n.levelTitle2;
  return l10n.levelTitle1;
}

/// Compact level/EXP pill for the dashboard hero (navy gradient surface).
class MissionLevelChip extends ConsumerWidget {
  const MissionLevelChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(missionsProvider);
    final experience = state.mission?.experience;
    if (state.status != MissionsStatus.ready || experience == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final progress = experience.levelTarget <= 0
        ? 0.0
        : (experience.levelProgress / experience.levelTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: AppIconSize.sm,
                color: AppColors.amber,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${l10n.levelLabel(experience.level)} · '
                  '${_levelTitle(l10n, experience.level)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.levelExpProgress(
                  experience.levelProgress,
                  experience.levelTarget,
                ),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: SizedBox(
              height: 5,
              width: 180,
              child: Stack(
                children: [
                  Container(color: Colors.white.withValues(alpha: 0.15)),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(color: AppColors.sky),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
