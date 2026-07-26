import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/feedback/feedback.dart';
import '../../../../core/feedback/haptics.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/gami_card.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../data/missions_notifier.dart';
import '../../data/providers.dart';
import '../../domain/entities/daily_mission.dart';
import 'mission_task_tile.dart';

/// Today's server-verified self-control missions on the protection dashboard.
/// Display + claim + link-out only; the adjust/replace flow stays web-side.
class DailyMissionsSection extends ConsumerWidget {
  const DailyMissionsSection({super.key});

  Future<void> _openWebPath(BuildContext context, String path) async {
    final locale = Localizations.localeOf(context).languageCode;
    final opened = await launchUrl(
      AppConfig.webUri('$locale/$path'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      AppFeedback.error(
        context,
        AppLocalizations.of(context)!.webPageOpenError,
      );
    }
  }

  void _handleLockedAction(BuildContext context, MissionTask task) {
    switch (task.number) {
      case 1:
        context.go('/setup');
      case 4:
        context.go('/accountability');
      case 2:
        _openWebPath(context, 'dashboard');
      default:
        _openWebPath(context, 'education');
    }
  }

  Future<void> _claim(
    BuildContext context,
    WidgetRef ref,
    MissionTask task,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await ref
          .read(missionsProvider.notifier)
          .claim(task.number);
      if (!context.mounted) return;
      Haptics.success();
      AppFeedback.success(
        context,
        result.leveledUp
            ? l10n.missionLevelUp
            : l10n.missionExpEarned(result.expEarned),
      );
    } catch (error) {
      if (!context.mounted) return;
      Haptics.error();
      AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(missionsProvider);

    if (state.status == MissionsStatus.hidden) {
      return const SizedBox.shrink();
    }

    final mission = state.mission;
    final Widget body;
    if (state.status == MissionsStatus.loading && mission == null) {
      body = const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonBox(width: double.infinity, height: 96),
          SizedBox(height: 8),
          SkeletonBox(width: double.infinity, height: 40),
        ],
      );
    } else if (state.status == MissionsStatus.error && mission == null) {
      body = Row(
        children: [
          const Icon(
            Icons.cloud_off,
            size: AppIconSize.md,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.msgErrLoadMissions,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(missionsProvider.notifier).load(),
            child: Text(l10n.retry),
          ),
        ],
      );
    } else if (mission != null) {
      final ordered = [
        ...mission.tasks.where((task) => task.isPrimary),
        ...mission.tasks.where((task) => !task.isPrimary),
      ];
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < ordered.length; i++) ...[
            MissionTaskTile(
              task: ordered[i],
              claiming: state.claimingNumber == ordered[i].number,
              onClaim: () => _claim(context, ref, ordered[i]),
              onLockedAction: () => _handleLockedAction(context, ordered[i]),
            ),
            if (i < ordered.length - 1) const SizedBox(height: 8),
          ],
          if (mission.allResolved) ...[
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final card = GamiCard(
                  asset: 'assets/images/gami-celebrate.webp',
                  message: l10n.missionsAllDone,
                );
                if (MediaQuery.disableAnimationsOf(context)) return card;
                return card
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
              },
            ),
          ],
        ],
      );
    } else {
      return const SizedBox.shrink();
    }

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  size: AppIconSize.md,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.missionsSectionTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.missionsSectionSubtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          body,
        ],
      ),
    );
  }
}
