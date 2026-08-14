class AccountabilityMembership {
  const AccountabilityMembership({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.partnerName,
    this.partnerAvatarUrl,
    required this.status,
    required this.sharing,
  });

  final String id;
  final String groupId;
  final String groupName;
  final String partnerName;
  final String? partnerAvatarUrl;
  final String status;
  final AccountabilitySharing sharing;

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
      partnerAvatarUrl: group?['owner_avatar_url']?.toString(),
      status: membership['status']?.toString() ?? 'active',
      sharing: AccountabilitySharing.fromJson(
        membership['sharing'] is Map
            ? Map<String, dynamic>.from(membership['sharing'] as Map)
            : const {},
      ),
    );
  }
}

class AccountabilitySharing {
  const AccountabilitySharing({
    this.protectionHealth = true,
    this.protectionActivity = true,
    this.recoveryEngagement = true,
    this.educationProgress = true,
  });
  final bool protectionHealth;
  final bool protectionActivity;
  final bool recoveryEngagement;
  final bool educationProgress;

  factory AccountabilitySharing.fromJson(Map<String, dynamic> json) =>
      AccountabilitySharing(
        protectionHealth: json['protection_health'] == true,
        protectionActivity: json['protection_activity'] == true,
        recoveryEngagement: json['recovery_engagement'] == true,
        educationProgress: json['education_progress'] == true,
      );

  Map<String, dynamic> toJson() => {
    'protection_health': protectionHealth,
    'protection_activity': protectionActivity,
    'recovery_engagement': recoveryEngagement,
    'education_progress': educationProgress,
  };

  AccountabilitySharing copyWith({
    bool? protectionHealth,
    bool? protectionActivity,
    bool? recoveryEngagement,
    bool? educationProgress,
  }) => AccountabilitySharing(
    protectionHealth: protectionHealth ?? this.protectionHealth,
    protectionActivity: protectionActivity ?? this.protectionActivity,
    recoveryEngagement: recoveryEngagement ?? this.recoveryEngagement,
    educationProgress: educationProgress ?? this.educationProgress,
  );
}

class AccountabilityExitRequest {
  const AccountabilityExitRequest({
    required this.id,
    required this.kind,
    required this.status,
  });
  final String id;
  final String kind;
  final String status;
  bool get canCancel => kind == 'normal' && status == 'pending';
  factory AccountabilityExitRequest.fromJson(Map<String, dynamic> json) =>
      AccountabilityExitRequest(
        id: json['id']?.toString() ?? '',
        kind: json['kind']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
      );
}

class AccountabilityOverview {
  const AccountabilityOverview({
    required this.activeMembership,
    this.pendingExitRequest,
  });

  final AccountabilityMembership? activeMembership;
  final AccountabilityExitRequest? pendingExitRequest;
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
