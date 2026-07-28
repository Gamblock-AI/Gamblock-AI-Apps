import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/feedback/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gami_card.dart';
import '../../../pattern_interrupt/data/providers.dart';

/// Gentle acknowledgment of a recent pause (grounding/breathing) the user
/// took: "the pause you took was a real step". Same-day vs yesterday is
/// derived from the stored local date — deterministic. Dismissing marks all
/// pauses acknowledged.
class PauseAcknowledgmentCard extends ConsumerWidget {
  const PauseAcknowledgmentCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pause = ref.watch(recentPauseProvider).valueOrNull;
    if (pause == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final formatter = DateFormat('yyyy-MM-dd');
    final sameDay =
        formatter.format(pause.completedAt) == formatter.format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GamiCard(
        title: l10n.pauseAckTitle,
        asset: 'assets/images/gami-meditate.webp',
        message: sameDay ? l10n.pauseAckToday : l10n.pauseAckYesterday,
        action: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.navy,
            visualDensity: VisualDensity.compact,
          ),
          onPressed: () async {
            Haptics.selection();
            await ref.read(pauseMomentsRepositoryProvider).acknowledgeAll();
            ref.invalidate(recentPauseProvider);
          },
          child: Text(l10n.pauseAckDismiss),
        ),
      ),
    );
  }
}
