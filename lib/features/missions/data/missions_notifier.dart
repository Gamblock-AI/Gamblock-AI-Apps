import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/daily_mission.dart';
import '../domain/repositories/missions_repository.dart';

enum MissionsStatus { loading, ready, error, hidden }

class MissionsState {
  const MissionsState({
    this.status = MissionsStatus.loading,
    this.mission,
    this.error,
    this.claimingNumber,
  });

  final MissionsStatus status;
  final DailyMission? mission;
  final Object? error;
  final int? claimingNumber;

  MissionsState copyWith({
    MissionsStatus? status,
    DailyMission? mission,
    Object? error,
    int? claimingNumber,
    bool clearError = false,
    bool clearClaiming = false,
  }) {
    return MissionsState(
      status: status ?? this.status,
      mission: mission ?? this.mission,
      error: clearError ? null : (error ?? this.error),
      claimingNumber: clearClaiming ? null : (claimingNumber ?? claimingNumber),
    );
  }
}

class MissionClaimResult {
  const MissionClaimResult({required this.leveledUp, required this.expEarned});

  final bool leveledUp;
  final int expEarned;
}

/// Owns the daily-mission state for the dashboard. Non-student sessions and
/// 403 responses collapse to [MissionsStatus.hidden] so the dashboard stays
/// quiet instead of surfacing an error the user cannot act on.
class MissionsNotifier extends StateNotifier<MissionsState> {
  MissionsNotifier(this._repository, {required this.isStudentSession})
    : super(const MissionsState());

  final MissionsRepository _repository;
  final bool Function() isStudentSession;

  Future<void> load() async {
    if (!isStudentSession()) {
      state = const MissionsState(status: MissionsStatus.hidden);
      return;
    }
    state = MissionsState(
      status: state.mission == null ? MissionsStatus.loading : state.status,
      mission: state.mission,
    );
    try {
      final mission = await _repository.fetchToday();
      state = MissionsState(status: MissionsStatus.ready, mission: mission);
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) {
        state = const MissionsState(status: MissionsStatus.hidden);
        return;
      }
      state = MissionsState(
        status: state.mission == null ? MissionsStatus.error : state.status,
        mission: state.mission,
        error: error,
      );
    } catch (error) {
      state = MissionsState(
        status: state.mission == null ? MissionsStatus.error : state.status,
        mission: state.mission,
        error: error,
      );
    }
  }

  Future<MissionClaimResult> claim(int missionNumber) async {
    final previousLevel = state.mission?.experience.level ?? 0;
    state = MissionsState(
      status: state.status,
      mission: state.mission,
      claimingNumber: missionNumber,
    );
    try {
      final mission = await _repository.claim(missionNumber);
      state = MissionsState(status: MissionsStatus.ready, mission: mission);
      final claimed = mission.tasks
          .where((task) => task.number == missionNumber)
          .toList();
      return MissionClaimResult(
        leveledUp: mission.experience.level > previousLevel,
        expEarned: claimed.isEmpty ? 0 : claimed.first.expReward,
      );
    } catch (error) {
      state = MissionsState(status: state.status, mission: state.mission);
      rethrow;
    }
  }
}
