import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

/// Deterministic Gami greeting state for the protection dashboard. The
/// full-bleed hero keeps one consistent mascot scene across daily opens.
class DashboardGamiPresentation {
  const DashboardGamiPresentation(this.lineBuilder);

  final String Function(AppLocalizations l10n)? lineBuilder;
}

DashboardGamiPresentation resolveDashboardGami({required bool firstOpenToday}) {
  if (firstOpenToday) {
    return DashboardGamiPresentation((l10n) => l10n.dashboardGamiFirstOpen);
  }
  return const DashboardGamiPresentation(null);
}
