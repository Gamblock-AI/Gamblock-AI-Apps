/// Server-verified daily-mission contract (`/v1/missions/today`). The
/// adjust/replace flow is deliberately web-only; Flutter displays status,
/// claims verified EXP, and links out for web-side activities.
class ExperienceProgress {
  const ExperienceProgress({
    required this.totalExp,
    required this.level,
    required this.levelProgress,
    required this.levelTarget,
  });

  final int totalExp;
  final int level;
  final int levelProgress;
  final int levelTarget;

  factory ExperienceProgress.fromJson(Map<String, dynamic> json) {
    int parse(String key) => int.tryParse(json[key]?.toString() ?? '') ?? 0;
    return ExperienceProgress(
      totalExp: parse('total_exp'),
      level: parse('level'),
      levelProgress: parse('level_progress'),
      levelTarget: parse('level_target'),
    );
  }
}

class MissionTask {
  const MissionTask({
    required this.number,
    required this.taskKey,
    required this.role,
    required this.completed,
    required this.claimable,
    required this.status,
    required this.verificationKey,
    required this.expReward,
    required this.replacedFrom,
  });

  final int number;
  final String taskKey;
  final String role;
  final bool completed;
  final bool claimable;

  /// One of `locked | claimable | claimed | skipped` (server-owned).
  final String status;
  final String verificationKey;
  final int expReward;
  final int replacedFrom;

  bool get isPrimary => role == 'primary';
  bool get isResolved => completed || status == 'skipped';

  factory MissionTask.fromJson(Map<String, dynamic> json) {
    int parseInt(String key) => int.tryParse(json[key]?.toString() ?? '') ?? 0;
    return MissionTask(
      number: parseInt('number'),
      taskKey: json['key']?.toString() ?? '',
      role: json['role']?.toString() ?? 'bonus',
      completed: json['completed'] == true,
      claimable: json['claimable'] == true,
      status: json['status']?.toString() ?? 'locked',
      verificationKey: json['verification_key']?.toString() ?? '',
      expReward: parseInt('exp_reward'),
      replacedFrom: parseInt('replaced_from'),
    );
  }
}

class DailyMission {
  const DailyMission({
    required this.date,
    required this.tasks,
    required this.experience,
    required this.resolvedCount,
    required this.totalCount,
  });

  final String date;
  final List<MissionTask> tasks;
  final ExperienceProgress experience;
  final int resolvedCount;
  final int totalCount;

  bool get allResolved => totalCount > 0 && resolvedCount >= totalCount;

  factory DailyMission.fromJson(Map<String, dynamic> json) {
    int parseInt(String key) => int.tryParse(json[key]?.toString() ?? '') ?? 0;
    final rawTasks = json['tasks'];
    return DailyMission(
      date: json['date']?.toString() ?? '',
      tasks: rawTasks is List
          ? rawTasks
                .whereType<Map<String, dynamic>>()
                .map(MissionTask.fromJson)
                .toList()
          : const [],
      experience: ExperienceProgress.fromJson(
        json['experience'] is Map<String, dynamic>
            ? json['experience'] as Map<String, dynamic>
            : const {},
      ),
      resolvedCount: parseInt('resolved_count'),
      totalCount: parseInt('total_count'),
    );
  }
}
