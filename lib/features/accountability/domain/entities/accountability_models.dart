class PartnerLink {
  const PartnerLink({
    required this.id,
    required this.email,
    required this.status,
    required this.relationshipRole,
  });

  final String id;
  final String email;
  final String status;
  final String relationshipRole;

  bool get isActive => status == 'active';

  factory PartnerLink.fromJson(Map<String, dynamic> json) {
    return PartnerLink(
      id: json['id']?.toString() ?? '',
      email: json['partner_email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'invited',
      relationshipRole: json['relationship_role']?.toString() ?? 'owner',
    );
  }
}

class PartnerOverview {
  const PartnerOverview({required this.activePartner, required this.items});

  final PartnerLink? activePartner;
  final List<PartnerLink> items;
}

class ApprovalRequest {
  const ApprovalRequest({
    required this.id,
    required this.deviceId,
    required this.partnerLinkId,
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
  final String partnerLinkId;
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
      partnerLinkId: json['partner_link_id']?.toString() ?? '',
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

class PartnerInvitation {
  const PartnerInvitation({
    required this.id,
    required this.status,
    required this.inviteUrl,
  });

  final String id;
  final String status;
  final String inviteUrl;
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
