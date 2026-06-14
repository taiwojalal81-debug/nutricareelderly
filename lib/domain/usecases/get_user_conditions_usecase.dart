// lib/domain/usecases/get_user_conditions_usecase.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/condition_entity.dart';
import 'package:nutricare_elderly/domain/repositories/health_repository.dart';

class GetUserConditionsUseCase {
  final HealthRepository healthRepository;

  GetUserConditionsUseCase(this.healthRepository);

  Future<Result<List<ConditionEntity>>> call(String userId) async {
    return await healthRepository.getUserConditions(userId);
  }
}
