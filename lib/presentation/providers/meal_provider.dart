// lib/presentation/providers/meal_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/domain/entities/meal_recommendation_entity.dart';
import 'package:nutricare_elderly/domain/usecases/generate_daily_meals_usecase.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/presentation/providers/repository_providers.dart';

final generateDailyMealsUseCaseProvider =
    Provider<GenerateDailyMealsUseCase>((ref) {
  final mealRepository = ref.watch(mealRepositoryProvider);
  return GenerateDailyMealsUseCase(mealRepository);
});

final selectedEthnicityProvider = StateProvider<String>((ref) => 'All');

// Generate daily meals
final dailyMealPlanProvider =
    FutureProvider<DailyMealPlanEntity?>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user == null) return null;

  final ethnicity = ref.watch(selectedEthnicityProvider);
  
  final generateDailyMealsUseCase =
      ref.watch(generateDailyMealsUseCaseProvider);
  final result = await generateDailyMealsUseCase.call(user.id, ethnicity: ethnicity);

  return result.when(
    success: (success) => success.data,
    failure: (failure) => null,
  );
});
