import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_state.dart';
import '../../analytics/data/providers.dart';
import '../domain/repositories/protection_repository.dart';
import 'repositories/protection_repository_impl.dart';

final protectionRepositoryProvider = Provider<ProtectionRepository>((ref) {
  return ProtectionRepositoryImpl();
});

/// Aggregate protection help across the last 7 days (blocked + interventions),
/// for the dashboard appreciation card. Degrades to `null` (card hidden) when
/// unauthenticated, deviceless, or the analytics fetch fails — the dashboard
/// must never surface an error for a purely encouraging card.
final weeklyAppreciationProvider = FutureProvider.autoDispose<int?>((
  ref,
) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated || auth.deviceId == null) return null;
  try {
    final analytics = await ref
        .read(analyticsRepositoryProvider)
        .fetch(deviceId: auth.deviceId!, days: 7);
    return analytics.totals.blocked + analytics.totals.interventions;
  } catch (_) {
    return null;
  }
});
