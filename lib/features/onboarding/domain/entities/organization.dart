/// A monitoring group an organization joins (PRD §2.2: Group Code linking).
class Organization {
  final String id;
  final String name;
  final String slug;
  final String groupCode;
  final String status;
  final int members;

  const Organization({
    required this.id,
    required this.name,
    required this.slug,
    required this.groupCode,
    required this.status,
    required this.members,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      groupCode: json['group_code']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      members: json['members'] is int ? json['members'] as int : 0,
    );
  }
}
