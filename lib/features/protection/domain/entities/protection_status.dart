/// Runtime protection status reported by the backend client endpoint.
class ProtectionStatus {
  final String mode;
  final String runtimeStatus;
  final String rulesetVersion;
  final String modelVersion;
  final String lastSync;

  const ProtectionStatus({
    required this.mode,
    required this.runtimeStatus,
    required this.rulesetVersion,
    required this.modelVersion,
    required this.lastSync,
  });

  bool get isActive => mode == 'Active';

  factory ProtectionStatus.fromJson(Map<String, dynamic> json) {
    return ProtectionStatus(
      mode: json['mode']?.toString() ?? 'Active',
      runtimeStatus:
          json['runtime_status']?.toString() ?? 'Local runtime ready',
      rulesetVersion: json['ruleset_version']?.toString() ?? '',
      modelVersion: json['model_version']?.toString() ?? '',
      lastSync: json['last_sync']?.toString() ?? '',
    );
  }
}
