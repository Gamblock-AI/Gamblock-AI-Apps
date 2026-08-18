class ProtectionStatus {
  const ProtectionStatus({
    required this.platform,
    required this.status,
    required this.serviceRunning,
    required this.sensorStatus,
    required this.permissionStatus,
    required this.rulesetVersion,
    required this.modelVersion,
    this.supportsControlledRemoval = false,
    this.deviceAdminActive = false,
    this.degradedReasonCode,
    this.lastEventAt,
  });

  final String platform;
  final String status;
  final bool serviceRunning;
  final String sensorStatus;
  final String permissionStatus;
  final String rulesetVersion;
  final String modelVersion;
  final bool supportsControlledRemoval;
  final bool deviceAdminActive;
  final String? degradedReasonCode;
  final DateTime? lastEventAt;

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isDegraded => status == 'degraded';
}
