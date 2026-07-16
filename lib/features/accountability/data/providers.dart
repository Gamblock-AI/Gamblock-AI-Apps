import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/accountability_repository.dart';
import 'repositories/accountability_repository_impl.dart';

final accountabilityRepositoryProvider = Provider<AccountabilityRepository>((
  ref,
) {
  return AccountabilityRepositoryImpl();
});
