import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/gami_card.dart';
import '../../data/providers.dart';

/// Weekly appreciation on the protection dashboard: period counts only,
/// never "today" claims, no fear/shame framing. Renders nothing while
/// loading, on error, or when there was nothing to appreciate.
class ProtectionWeeklyAppreciation extends ConsumerWidget {
  const ProtectionWeeklyAppreciation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(weeklyAppreciationProvider).valueOrNull;
    if (count == null || count <= 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GamiCard(
        title: l10n.dashboardAppreciationTitle,
        message: l10n.dashboardAppreciationBody(count),
        asset: 'assets/images/gami-celebrate.webp',
        radius: AppRadius.banner,
      ),
    );
  }
}
