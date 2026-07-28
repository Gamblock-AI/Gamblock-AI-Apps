import '../entities/journey_snapshot.dart';

class PracticeSummary {
  const PracticeSummary({required this.kinds, required this.count});

  final Set<String> kinds;
  final int count;
}

class EducationSummary {
  const EducationSummary({required this.started, required this.completed});

  final int started;
  final int completed;
}

abstract class JourneyRepository {
  /// Fixed 90-day window (same as the web) so badge state never shifts with
  /// the analytics period toggle.
  Future<JourneySnapshot> fetchSnapshot();

  Future<PracticeSummary> fetchPracticeSummary();

  Future<EducationSummary> fetchEducationSummary(String locale);
}
