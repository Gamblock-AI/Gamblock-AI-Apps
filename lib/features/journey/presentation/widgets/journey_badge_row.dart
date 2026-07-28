import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/journey_badge.dart';

/// Material icon per badge id (mirrors the web's lucide choices).
IconData journeyBadgeIcon(String id) {
  switch (id) {
    case 'first_check_in':
      return Icons.verified_user_outlined;
    case 'five_active_days':
      return Icons.calendar_month_rounded;
    case 'fifteen_active_days':
      return Icons.directions_walk_rounded;
    case 'first_practice':
      return Icons.waves_rounded;
    case 'practice_explorer':
      return Icons.explore_outlined;
    case 'first_journal':
      return Icons.edit_note_rounded;
    case 'first_mission':
      return Icons.track_changes_rounded;
    case 'mission_ten_days':
      return Icons.flag_rounded;
    case 'first_review':
      return Icons.event_available_rounded;
    case 'first_education':
      return Icons.menu_book_rounded;
    case 'module_complete':
      return Icons.school_rounded;
    case 'level_five':
      return Icons.auto_awesome_rounded;
    case 'level_ten':
      return Icons.emoji_events_rounded;
    default:
      return Icons.star_border_rounded;
  }
}

/// Badge copy ported verbatim from the web catalog (progressExperience.*).
({String name, String criteria}) journeyBadgeCopy(
  AppLocalizations l10n,
  String id,
) {
  switch (id) {
    case 'first_check_in':
      return (
        name: l10n.journeyBadgeFirstCheckInName,
        criteria: l10n.journeyBadgeFirstCheckInCriteria,
      );
    case 'five_active_days':
      return (
        name: l10n.journeyBadgeFiveActiveDaysName,
        criteria: l10n.journeyBadgeFiveActiveDaysCriteria,
      );
    case 'fifteen_active_days':
      return (
        name: l10n.journeyBadgeFifteenActiveDaysName,
        criteria: l10n.journeyBadgeFifteenActiveDaysCriteria,
      );
    case 'first_practice':
      return (
        name: l10n.journeyBadgeFirstPracticeName,
        criteria: l10n.journeyBadgeFirstPracticeCriteria,
      );
    case 'practice_explorer':
      return (
        name: l10n.journeyBadgePracticeExplorerName,
        criteria: l10n.journeyBadgePracticeExplorerCriteria,
      );
    case 'first_journal':
      return (
        name: l10n.journeyBadgeFirstJournalName,
        criteria: l10n.journeyBadgeFirstJournalCriteria,
      );
    case 'first_mission':
      return (
        name: l10n.journeyBadgeFirstMissionName,
        criteria: l10n.journeyBadgeFirstMissionCriteria,
      );
    case 'mission_ten_days':
      return (
        name: l10n.journeyBadgeMissionTenDaysName,
        criteria: l10n.journeyBadgeMissionTenDaysCriteria,
      );
    case 'first_review':
      return (
        name: l10n.journeyBadgeFirstReviewName,
        criteria: l10n.journeyBadgeFirstReviewCriteria,
      );
    case 'first_education':
      return (
        name: l10n.journeyBadgeFirstEducationName,
        criteria: l10n.journeyBadgeFirstEducationCriteria,
      );
    case 'module_complete':
      return (
        name: l10n.journeyBadgeModuleCompleteName,
        criteria: l10n.journeyBadgeModuleCompleteCriteria,
      );
    case 'level_five':
      return (
        name: l10n.journeyBadgeLevelFiveName,
        criteria: l10n.journeyBadgeLevelFiveCriteria,
      );
    default:
      return (
        name: l10n.journeyBadgeLevelTenName,
        criteria: l10n.journeyBadgeLevelTenCriteria,
      );
  }
}

/// Compact badge row: earned rows use sage (genuine achievement), locked rows
/// stay muted with dashed framing. Criteria are always visible — no mystery
/// boxes, nothing losable.
class JourneyBadgeRow extends StatelessWidget {
  const JourneyBadgeRow({super.key, required this.badge});

  final JourneyBadge badge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final copy = journeyBadgeCopy(l10n, badge.id);
    final achieved = badge.achieved;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: achieved
            ? AppColors.surface
            : AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achieved
              ? AppColors.sage.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: achieved
                  ? AppColors.sage.withValues(alpha: 0.1)
                  : AppColors.muted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              journeyBadgeIcon(badge.id),
              size: 16,
              color: achieved
                  ? AppColors.sage
                  : AppColors.mutedForeground.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: achieved
                        ? AppColors.navy
                        : AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  copy.criteria,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
