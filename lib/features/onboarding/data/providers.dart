import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/organization_repository.dart';
import 'repositories/organization_repository_impl.dart';

/// Shared Riverpod provider for the onboarding organization repository.
/// Defined once here so both the join and create screens read the same instance.
final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepositoryImpl();
});
