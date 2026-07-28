/// A completed calming exercise ("momen jeda") recorded on-device so the
/// dashboard can acknowledge it later. Carries only the kind, timestamps, and
/// acknowledgment state — never any browsing context.
class PauseMoment {
  const PauseMoment({
    required this.completedAt,
    required this.kind,
    this.acknowledged = false,
  });

  /// 'grounding' | 'breathing'
  final String kind;
  final DateTime completedAt;
  final bool acknowledged;

  PauseMoment copyWith({bool? acknowledged}) => PauseMoment(
    completedAt: completedAt,
    kind: kind,
    acknowledged: acknowledged ?? this.acknowledged,
  );

  Map<String, Object?> toJson() => {
    'completed_at': completedAt.toIso8601String(),
    'kind': kind,
    'acknowledged': acknowledged,
  };

  static PauseMoment? fromJson(Object? json) {
    if (json is! Map) return null;
    final completedAt = DateTime.tryParse(json['completed_at']?.toString() ?? '');
    final kind = json['kind']?.toString();
    if (completedAt == null || kind == null) return null;
    return PauseMoment(
      completedAt: completedAt,
      kind: kind,
      acknowledged: json['acknowledged'] == true,
    );
  }
}
