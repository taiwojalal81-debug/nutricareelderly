// lib/domain/repositories/meal_repository.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/nigerian_food_entity.dart';
import 'package:nutricare_elderly/domain/entities/meal_recommendation_entity.dart';

abstract class MealRepository {
  Future<Result<DailyMealPlanEntity>> generateDailyMeals({
    required String userId,
    String? ethnicity,
  });

  Future<Result<List<NigerianFoodEntity>>> getNigerianFoods({
    String? mealCategory,
    List<String>? conditionFilters,
  });

  Future<Result<NigerianFoodEntity>> getFoodById(String foodId);

  Future<Result<List<DailyMealPlanEntity>>> getMealHistory({
    required String userId,
    required int daysBack,
  });
}
