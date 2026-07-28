/// Aggregate-only progress snapshot inputs for the journey badges. Mirrors
/// the backend `/v1/client/progress` payload fields the badges need — counts
/// and dates only, never browsing data.
class ProgressActivityDay {
  const ProgressActivityDay({
    required this.date,
    required this.checkIns,
    required this.practices,
    required this.journals,
    required this.missions,
    required this.education,
    required this.reviews,
  });

  final String date;
  final int checkIns;
  final int practices;
  final int journals;
  final int missions;
  final int education;
  final int reviews;

  bool get hasActivity =>
      checkIns + practices + journals + missions + education + reviews > 0;

  static ProgressActivityDay? fromJson(Object? json) {
    if (json is! Map) return null;
    int parse(String key) => int.tryParse(json[key]?.toString() ?? '') ?? 0;
    final date = json['date']?.toString();
    if (date == null) return null;
    return ProgressActivityDay(
      date: date,
      checkIns: parse('check_ins'),
      practices: parse('practices'),
      journals: parse('journals'),
      missions: parse('missions'),
      education: parse('education'),
      reviews: parse('reviews'),
    );
  }
}

class JourneySnapshot {
  const JourneySnapshot({
    required this.checkInCount,
    required this.activeDays,
    required this.reflections,
    required this.activityDays,
  });

  final int checkInCount;
  final int activeDays;
  final int reflections;
  final List<ProgressActivityDay> activityDays;

  static JourneySnapshot fromJson(Map<String, dynamic> json) {
    int parse(String key) => int.tryParse(json[key]?.toString() ?? '') ?? 0;
    final rawDays = json['activity_days'];
    return JourneySnapshot(
      checkInCount: parse('check_in_count'),
      activeDays: parse('active_days'),
      reflections: parse('reflections'),
      activityDays: [
        if (rawDays is List)
          for (final item in rawDays)
            if (ProgressActivityDay.fromJson(item) case final day?) day,
      ],
    );
  }
}
