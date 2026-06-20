import '../entities/organization.dart';

/// Domain contract for joining/creating a monitoring group (PRD §2.2).
abstract class OrganizationRepository {
  Future<Organization> joinByGroupCode(String groupCode);
  Future<Organization> create({required String name});
}
