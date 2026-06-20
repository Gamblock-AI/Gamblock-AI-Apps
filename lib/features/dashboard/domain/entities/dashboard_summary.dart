/// Aggregated protection analytics shown on the Member dashboard (PRD §3.4-B).
/// Only aggregate scores — never raw URLs/browsing data (privacy by design).
class DashboardSummary {
  final String userName;
  final String protectionLabel;
  final int blockedAttempts;
  final int activeDays;
  final int currentStreak;

  const DashboardSummary({
    required this.userName,
    required this.protectionLabel,
    required this.blockedAttempts,
    required this.activeDays,
    required this.currentStreak,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      userName: json['user_name']?.toString() ?? '',
      protectionLabel: json['protection_label']?.toString() ?? '',
      blockedAttempts: _toInt(json['blocked_attempts']),
      activeDays: _toInt(json['active_days']),
      currentStreak: _toInt(json['current_streak']),
    );
  }

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
}
