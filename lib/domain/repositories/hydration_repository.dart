// lib/domain/repositories/hydration_repository.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/hydration_entity.dart';

abstract class HydrationRepository {
  Future<Result<HydrationEntity?>> getDailyHydration(String userId, DateTime date);
  Future<Result<HydrationEntity>> updateHydration({
    required String userId,
    required DateTime date,
    required int glassesCount,
  });
}
