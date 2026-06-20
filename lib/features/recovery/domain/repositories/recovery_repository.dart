import '../entities/reflection_entry.dart';

/// Domain contract for the recovery hub (reflections/journals + mood).
abstract class RecoveryRepository {
  Future<List<ReflectionEntry>> fetchReflections();
  Future<void> submitReflection({required String text, required String mood});
}
