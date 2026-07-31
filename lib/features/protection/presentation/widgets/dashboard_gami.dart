import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

/// Deterministic mascot state for the protection dashboard. It only marks the
/// first open of the day, then returns to the neutral protection state.
class DashboardGamiPresentation {
  const DashboardGamiPresentation(this.asset, this.lineBuilder);

  final String asset;
  final String Function(AppLocalizations l10n)? lineBuilder;
}

DashboardGamiPresentation resolveDashboardGami({
  required bool firstOpenToday,
}) {
  if (firstOpenToday) {
    return DashboardGamiPresentation(
      'assets/images/gami-wave.webp',
      (l10n) => l10n.dashboardGamiFirstOpen,
    );
  }
  return const DashboardGamiPresentation('assets/images/gami.webp', null);
}
