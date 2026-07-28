import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_state.dart';
import '../../missions/data/providers.dart';
import '../domain/entities/journey_badge.dart';
import '../domain/entities/journey_snapshot.dart';
import '../domain/repositories/journey_repository.dart';
import 'repositories/journey_repository_impl.dart';

final journeyRepositoryProvider = Provider<JourneyRepository>(
  (ref) => JourneyRepositoryImpl(),
);

class JourneyBadgesState {
  const JourneyBadgesState({
    required this.badges,
    required this.rhythmCount,
    this.unavailable = false,
  });

  const JourneyBadgesState.unavailable()
    : badges = const [],
      rhythmCount = 0,
      unavailable = true;

  final List<JourneyBadge> badges;

  /// Non-consecutive presence over the last 7 local days — a rhythm, never a
  /// streak that can break.
  final int rhythmCount;
  final bool unavailable;
}

/// Full 13-badge parity with the web, computed from the same account data
/// (fixed 90-day snapshot + practices + education progress + mission level).
/// Hidden (`null`) for non-student sessions; failed practice/education
/// sources degrade to empty like the web; a failed snapshot marks the state
/// unavailable.
final journeyBadgesProvider = FutureProvider.autoDispose
    .family<JourneyBadgesState?, String>((ref, locale) async {
      final auth = ref.watch(authProvider);
      final isStudent =
          auth.isAuthenticated && (auth.role == null || auth.role == 'user');
      if (!isStudent) return null;

      final repository = ref.watch(journeyRepositoryProvider);
      final missions = ref.watch(missionsProvider);
      final level = missions.mission?.experience.level ?? 0;

      final snapshotFuture = repository
          .fetchSnapshot()
          .then<JourneySnapshot?>((value) => value)
          .catchError((Object _) => null);
      final practicesFuture = repository.fetchPracticeSummary().catchError(
        (Object _) => const PracticeSummary(kinds: {}, count: 0),
      );
      final educationFuture = repository
          .fetchEducationSummary(locale)
          .catchError(
            (Object _) => const EducationSummary(started: 0, completed: 0),
          );

      final snapshot = await snapshotFuture;
      final practices = await practicesFuture;
      final education = await educationFuture;
      if (snapshot == null) return const JourneyBadgesState.unavailable();

      int countDays(int Function(ProgressActivityDay day) selector) {
        var count = 0;
        for (final day in snapshot.activityDays) {
          if (selector(day) > 0) count++;
        }
        return count;
      }

      final formatter = DateFormat('yyyy-MM-dd');
      final now = DateTime.now();
      final activityByDate = {
        for (final day in snapshot.activityDays) day.date: day,
      };
      var rhythmCount = 0;
      for (var offset = 0; offset < 7; offset++) {
        final key = formatter.format(now.subtract(Duration(days: offset)));
        if (activityByDate[key]?.hasActivity ?? false) rhythmCount++;
      }

      final badges = buildJourneyBadges(
        JourneyBadgeInput(
          checkInCount: snapshot.checkInCount,
          activeDays: snapshot.activeDays,
          reflections: snapshot.reflections,
          missionDays: countDays((day) => day.missions),
          reviewDays: countDays((day) => day.reviews),
          educationDays: countDays((day) => day.education),
          practiceKinds: practices.kinds,
          practiceCount: practices.count,
          modulesStarted: education.started,
          modulesCompleted: education.completed,
          level: level,
        ),
      );
      return JourneyBadgesState(badges: badges, rhythmCount: rhythmCount);
    });
