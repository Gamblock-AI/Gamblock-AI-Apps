class AccountabilityMembership {
  const AccountabilityMembership({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.partnerName,
    required this.status,
  });

  final String id;
  final String groupId;
  final String groupName;
  final String partnerName;
  final String status;

  bool get isActive => status == 'active';

  factory AccountabilityMembership.fromWorkspace(
    Map<String, dynamic> membership,
    Map<String, dynamic>? group,
  ) {
    return AccountabilityMembership(
      id: membership['id']?.toString() ?? '',
      groupId: membership['group_id']?.toString() ?? '',
      groupName: group?['name']?.toString() ?? '',
      partnerName: group?['owner_name']?.toString() ?? '',
      status: membership['status']?.toString() ?? 'active',
    );
  }
}

class AccountabilityOverview {
  const AccountabilityOverview({required this.activeMembership});

  final AccountabilityMembership? activeMembership;
}

class AccountabilityGroupPreview {
  const AccountabilityGroupPreview({
    required this.id,
    required this.name,
    required this.description,
    required this.partnerName,
  });

  final String id;
  final String name;
  final String description;
  final String partnerName;

  factory AccountabilityGroupPreview.fromJson(Map<String, dynamic> json) {
    return AccountabilityGroupPreview(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      partnerName: json['owner_name']?.toString() ?? '',
    );
  }
}

class ApprovalRequest {
  const ApprovalRequest({
    required this.id,
    required this.deviceId,
    required this.membershipId,
    required this.action,
    required this.actionLabel,
    required this.status,
    required this.statusLabel,
    required this.reason,
    required this.durationMinutes,
    this.resolvedAt,
    this.appliedAt,
    this.grantExpiresAt,
  });

  final String id;
  final String deviceId;
  final String membershipId;
  final String action;
  final String actionLabel;
  final String status;
  final String statusLabel;
  final String reason;
  final int durationMinutes;
  final DateTime? resolvedAt;
  final DateTime? appliedAt;
  final DateTime? grantExpiresAt;

  bool get isPending => status == 'pending';
  bool get canApply => status == 'approved' && appliedAt == null;

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String key) =>
        DateTime.tryParse(json[key]?.toString() ?? '');
    return ApprovalRequest(
      id: json['id']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      membershipId: json['membership_id']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      actionLabel: json['action_label']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      durationMinutes:
          int.tryParse(json['requested_duration_minutes']?.toString() ?? '') ??
          0,
      resolvedAt: parse('resolved_at'),
      appliedAt: parse('applied_at'),
      grantExpiresAt: parse('grant_expires_at'),
    );
  }
}

class EmergencyRequest {
  const EmergencyRequest({
    required this.id,
    required this.deviceId,
    required this.status,
    required this.requestExpiresAt,
    this.keyExpiresAt,
  });

  final String id;
  final String deviceId;
  final String status;
  final DateTime requestExpiresAt;
  final DateTime? keyExpiresAt;

  factory EmergencyRequest.fromJson(Map<String, dynamic> json) {
    return EmergencyRequest(
      id: json['id']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      requestExpiresAt:
          DateTime.tryParse(json['request_expires_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      keyExpiresAt: DateTime.tryParse(json['key_expires_at']?.toString() ?? ''),
    );
  }
}
