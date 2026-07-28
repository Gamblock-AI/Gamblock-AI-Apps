import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../missions/data/providers.dart';
import '../../data/providers.dart';
import 'journey_badge_row.dart';

/// Journey badges + presence rhythm on the analytics screen — the same 13
/// badges as the web, criteria always visible, locked badges behind a quiet
/// disclosure. No unlock animation and no haptics: this is a reflective
/// surface, not a celebration machine.
class JourneyBadgesSection extends ConsumerStatefulWidget {
  const JourneyBadgesSection({super.key});

  @override
  ConsumerState<JourneyBadgesSection> createState() =>
      _JourneyBadgesSectionState();
}

class _JourneyBadgesSectionState extends ConsumerState<JourneyBadgesSection> {
  bool _lockedOpen = false;

  @override
  void initState() {
    super.initState();
    // The analytics screen does not load missions; the badge level input
    // converges once this load completes (idempotent for the session).
    Future.microtask(() {
      if (!mounted) return;
      if (ref.read(missionsProvider).mission == null) {
        ref.read(missionsProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final stateAsync = ref.watch(journeyBadgesProvider(locale));
    final state = stateAsync.valueOrNull;

    if (stateAsync.hasValue && state == null) {
      // Non-student session: the section stays out of the way entirely.
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.journeyBadgesEyebrow.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: AppColors.navyLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.journeyBadgesTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.journeyBadgesBody,
              style: const TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            if (stateAsync.isLoading) ...[
              const SkeletonBox(
                width: double.infinity,
                height: 44,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(height: 6),
              const SkeletonBox(
                width: double.infinity,
                height: 44,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ] else if (state == null || state.unavailable)
              Text(
                l10n.journeyBadgesUnavailable,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
              )
            else ...[
              _RhythmLine(count: state.rhythmCount),
              const SizedBox(height: 12),
              for (final badge in state.badges.where((item) => item.achieved))
                JourneyBadgeRow(badge: badge),
              if (state.badges.any((item) => !item.achieved)) ...[
                InkWell(
                  onTap: () => setState(() => _lockedOpen = !_lockedOpen),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.journeyBadgesUpNext(
                              state.badges
                                  .where((item) => !item.achieved)
                                  .length,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        Icon(
                          _lockedOpen
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_lockedOpen)
                  for (final badge in state.badges.where(
                    (item) => !item.achieved,
                  ))
                    JourneyBadgeRow(badge: badge),
              ],
              const SizedBox(height: 4),
              Text(
                l10n.journeyBadgesCount(
                  state.badges.where((item) => item.achieved).length,
                  state.badges.length,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RhythmLine extends StatelessWidget {
  const _RhythmLine({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.azure.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.favorite_outline_rounded,
            size: 16,
            color: AppColors.navyLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.journeyRhythmLine(count),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.journeyRhythmHint,
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
