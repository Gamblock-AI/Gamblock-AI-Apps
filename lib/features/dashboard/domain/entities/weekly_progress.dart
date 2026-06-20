/// Weekly protection progress (block counts per day). Seven entries, last is today.
class WeeklyProgress {
  final List<int> weeklyBlocks;

  const WeeklyProgress({required this.weeklyBlocks});

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    final raw = json['weekly_blocks'];
    var list = <int>[];
    if (raw is List) {
      list = raw.map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList();
    }
    if (list.length < 7) {
      list = List.generate(7, (i) => i < list.length ? list[i] : 0);
    }
    return WeeklyProgress(weeklyBlocks: list);
  }
}
