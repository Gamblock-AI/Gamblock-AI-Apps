/// Deterministic journey badges — a verbatim port of the website's
/// `lib/recovery/badges.ts`. Criteria never involve chance, comparison, or
/// anything that can be "lost"; order is stable and mirrors the copy catalog.
class JourneyBadgeInput {
  const JourneyBadgeInput({
    required this.checkInCount,
    required this.activeDays,
    required this.reflections,
    required this.missionDays,
    required this.reviewDays,
    required this.educationDays,
    required this.practiceKinds,
    required this.practiceCount,
    required this.modulesStarted,
    required this.modulesCompleted,
    required this.level,
  });

  final int checkInCount;
  final int activeDays;
  final int reflections;
  final int missionDays;
  final int reviewDays;
  final int educationDays;
  final Set<String> practiceKinds;
  final int practiceCount;
  final int modulesStarted;
  final int modulesCompleted;
  final int level;
}

class JourneyBadge {
  const JourneyBadge({required this.id, required this.achieved});

  final String id;
  final bool achieved;
}

const _allPracticeKinds = ['urge_surfing', 'grounding_54321', 'focus_sprint'];

List<JourneyBadge> buildJourneyBadges(JourneyBadgeInput input) {
  return [
    JourneyBadge(id: 'first_check_in', achieved: input.checkInCount >= 1),
    JourneyBadge(id: 'five_active_days', achieved: input.activeDays >= 5),
    JourneyBadge(id: 'fifteen_active_days', achieved: input.activeDays >= 15),
    JourneyBadge(id: 'first_practice', achieved: input.practiceCount >= 1),
    JourneyBadge(
      id: 'practice_explorer',
      achieved: _allPracticeKinds.every(input.practiceKinds.contains),
    ),
    JourneyBadge(id: 'first_journal', achieved: input.reflections >= 1),
    JourneyBadge(id: 'first_mission', achieved: input.missionDays >= 1),
    JourneyBadge(id: 'mission_ten_days', achieved: input.missionDays >= 10),
    JourneyBadge(id: 'first_review', achieved: input.reviewDays >= 1),
    JourneyBadge(
      id: 'first_education',
      achieved: input.educationDays >= 1 || input.modulesStarted >= 1,
    ),
    JourneyBadge(id: 'module_complete', achieved: input.modulesCompleted >= 1),
    JourneyBadge(id: 'level_five', achieved: input.level >= 5),
    JourneyBadge(id: 'level_ten', achieved: input.level >= 10),
  ];
}
