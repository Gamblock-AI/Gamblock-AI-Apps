import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_state.dart';
import '../domain/repositories/missions_repository.dart';
import 'missions_notifier.dart';
import 'repositories/missions_repository_impl.dart';

final missionsRepositoryProvider = Provider<MissionsRepository>(
  (ref) => MissionsRepositoryImpl(),
);

final missionsProvider = StateNotifierProvider<MissionsNotifier, MissionsState>(
  (ref) {
    return MissionsNotifier(
      ref.watch(missionsRepositoryProvider),
      isStudentSession: () {
        final auth = ref.read(authProvider);
        return auth.isAuthenticated && (auth.role == null || auth.role == 'user');
      },
    );
  },
);
