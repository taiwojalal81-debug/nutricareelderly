// lib/presentation/providers/health_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/domain/entities/condition_entity.dart';
import 'package:nutricare_elderly/domain/entities/health_profile_entity.dart';
import 'package:nutricare_elderly/domain/usecases/get_user_conditions_usecase.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/presentation/providers/repository_providers.dart';

final getUserConditionsUseCaseProvider = Provider<GetUserConditionsUseCase>((ref) {
  final healthRepository = ref.watch(healthRepositoryProvider);
  return GetUserConditionsUseCase(healthRepository);
});

// Get all conditions
final allConditionsProvider = FutureProvider<List<ConditionEntity>>((ref) async {
  final healthRepository = ref.watch(healthRepositoryProvider);
  final result = await healthRepository.getAllConditions();

  return result.when(
    success: (success) => success.data,
    failure: (failure) => [],
  );
});

// Get user health profile
final userHealthProfileProvider =
    FutureProvider<HealthProfileEntity?>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user == null) return null;

  final healthRepository = ref.watch(healthRepositoryProvider);
  final result = await healthRepository.getHealthProfile(user.id);

  return result.when(
    success: (success) {
      if (success.data.id.isEmpty) return null;
      return success.data;
    },
    failure: (failure) => null,
  );
});

// Get user conditions
final userConditionsProvider =
    FutureProvider<List<ConditionEntity>>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user == null) return [];

  final getUserConditionsUseCase = ref.watch(getUserConditionsUseCaseProvider);
  final result = await getUserConditionsUseCase.call(user.id);

  return result.when(
    success: (success) => success.data,
    failure: (failure) => [],
  );
});
