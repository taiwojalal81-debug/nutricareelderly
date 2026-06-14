// lib/domain/repositories/health_repository.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/health_profile_entity.dart';
import 'package:nutricare_elderly/domain/entities/condition_entity.dart';

abstract class HealthRepository {
  Future<Result<HealthProfileEntity>> createHealthProfile({
    required String userId,
    required double weightKg,
    required int heightCm,
    String? bloodType,
    String? allergies,
  });

  Future<Result<HealthProfileEntity>> getHealthProfile(String userId);

  Future<Result<HealthProfileEntity>> updateHealthProfile({
    required String userId,
    required double weightKg,
    required int heightCm,
    String? bloodType,
    String? allergies,
  });

  Future<Result<List<ConditionEntity>>> getAllConditions();

  Future<Result<void>> addUserCondition({
    required String userId,
    required String conditionId,
    String? severity,
  });

  Future<Result<List<ConditionEntity>>> getUserConditions(String userId);

  Future<Result<void>> removeUserCondition({
    required String userId,
    required String conditionId,
  });
}
