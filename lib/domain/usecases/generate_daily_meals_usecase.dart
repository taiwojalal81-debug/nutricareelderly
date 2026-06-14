// lib/domain/usecases/generate_daily_meals_usecase.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/meal_recommendation_entity.dart';
import 'package:nutricare_elderly/domain/repositories/meal_repository.dart';

class GenerateDailyMealsUseCase {
  final MealRepository mealRepository;

  GenerateDailyMealsUseCase(this.mealRepository);

  Future<Result<DailyMealPlanEntity>> call(String userId, {String? ethnicity}) async {
    return await mealRepository.generateDailyMeals(userId: userId, ethnicity: ethnicity);
  }
}
