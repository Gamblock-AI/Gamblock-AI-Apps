import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_state.dart';
import '../domain/entities/pause_moment.dart';
import '../domain/repositories/pause_moments_repository.dart';
import 'repositories/pause_moments_repository_impl.dart';

final pauseMomentsRepositoryProvider = Provider<PauseMomentsRepository>((ref) {
  return PauseMomentsRepositoryImpl(
    isStudentSession: () {
      final auth = ref.read(authProvider);
      return auth.isAuthenticated && (auth.role == null || auth.role == 'user');
    },
  );
});

/// Newest unacknowledged pause within 48h, for the dashboard acknowledgment
/// card and the contextual hero mascot.
final recentPauseProvider = FutureProvider.autoDispose<PauseMoment?>((ref) {
  return ref.watch(pauseMomentsRepositoryProvider).unacknowledgedRecent();
});
