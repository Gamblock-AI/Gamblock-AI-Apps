import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage key for the dashboard-tour-seen flag. Exposed so development
/// tooling can clear it without duplicating the string.
const dashboardTourSeenKey = 'dashboard_tour_seen_v1';

/// Persists whether the first-time dashboard tour has already run, following
/// the same secure-storage pattern as `onboarding_state.dart`.
class TourSeenStore {
  TourSeenStore(this._storage);

  final FlutterSecureStorage _storage;

  Future<bool> isSeen() async {
    return (await _storage.read(key: dashboardTourSeenKey)) == 'true';
  }

  Future<void> markSeen() async {
    await _storage.write(key: dashboardTourSeenKey, value: 'true');
  }
}

final tourSeenStoreProvider = Provider<TourSeenStore>((ref) {
  return TourSeenStore(const FlutterSecureStorage());
});

/// Resolves once at startup; the tour host listens to it before starting.
final tourSeenProvider = FutureProvider<bool>((ref) {
  return ref.watch(tourSeenStoreProvider).isSeen();
});
