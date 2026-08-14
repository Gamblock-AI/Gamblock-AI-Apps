/// Pure data model for a guided-tour step. Mirrors the website's
/// `TourStep { target, titleKey, bodyKey }` contract: [targetKey] is the
/// identifier of the widget highlighted by the spotlight, and the l10n keys
/// resolve through `AppLocalizations`.
class TourStep {
  const TourStep({
    required this.targetKey,
    required this.titleKey,
    required this.bodyKey,
  });

  final String targetKey;
  final String titleKey;
  final String bodyKey;
}

/// Student dashboard tour for the mobile client. All targets are visible on
/// the `/dashboard` route and the shell without cross-screen navigation,
/// mirroring the website's mobile student tour.
const List<TourStep> kDashboardTourSteps = [
  TourStep(
    targetKey: 'tour-welcome',
    titleKey: 'tourWelcomeTitle',
    bodyKey: 'tourWelcomeBody',
  ),
  TourStep(
    targetKey: 'tour-hero',
    titleKey: 'tourHeroTitle',
    bodyKey: 'tourHeroBody',
  ),
  TourStep(
    targetKey: 'tour-protection',
    titleKey: 'tourProtectionTitle',
    bodyKey: 'tourProtectionBody',
  ),
  TourStep(
    targetKey: 'tour-fab',
    titleKey: 'tourFabTitle',
    bodyKey: 'tourFabBody',
  ),
  TourStep(
    targetKey: 'tour-nav',
    titleKey: 'tourNavTitle',
    bodyKey: 'tourNavBody',
  ),
  TourStep(
    targetKey: 'tour-profile',
    titleKey: 'tourProfileTitle',
    bodyKey: 'tourProfileBody',
  ),
];
