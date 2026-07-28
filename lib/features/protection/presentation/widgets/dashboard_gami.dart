import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

/// Deterministic contextual mascot state for the dashboard hero, in priority
/// order: all missions resolved, a recent unacknowledged pause, the first
/// open of the day, then the neutral default. Pure selection — no fetching,
/// no randomness — so the hero stays calm and predictable.
class DashboardGamiPresentation {
  const DashboardGamiPresentation(this.asset, this.lineBuilder);

  final String asset;
  final String Function(AppLocalizations l10n)? lineBuilder;
}

DashboardGamiPresentation resolveDashboardGami({
  required bool missionsAllDone,
  required bool pauseTaken,
  required bool firstOpenToday,
}) {
  if (missionsAllDone) {
    return DashboardGamiPresentation(
      'assets/images/gami-celebrate.webp',
      (l10n) => l10n.dashboardGamiAllDone,
    );
  }
  if (pauseTaken) {
    return DashboardGamiPresentation(
      'assets/images/gami-meditate.webp',
      (l10n) => l10n.dashboardGamiPauseTaken,
    );
  }
  if (firstOpenToday) {
    return DashboardGamiPresentation(
      'assets/images/gami-wave.webp',
      (l10n) => l10n.dashboardGamiFirstOpen,
    );
  }
  return const DashboardGamiPresentation('assets/images/gami.webp', null);
}
