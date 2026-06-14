// lib/domain/entities/meal_recommendation_entity.dart

import 'package:equatable/equatable.dart';
import 'nigerian_food_entity.dart';

class MealEntity extends Equatable {
  final String mealType;
  final NigerianFoodEntity food;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MealEntity({
    required this.mealType,
    required this.food,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  List<Object?> get props => [mealType, food, calories, protein, carbs, fat];
}

class NutritionEntity extends Equatable {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final int sodium;

  const NutritionEntity({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sodium,
  });

  @override
  List<Object?> get props => [calories, protein, carbs, fat, fiber, sodium];
}

class DrugFoodInteractionWarningEntity extends Equatable {
  final String medication;
  final String food;
  final String interaction;
  final String recommendation;
  final int severity;

  const DrugFoodInteractionWarningEntity({
    required this.medication,
    required this.food,
    required this.interaction,
    required this.recommendation,
    required this.severity,
  });

  String get severityLabel {
    switch (severity) {
      case 3:
        return '🚫 CRITICAL';
      case 2:
        return '⚠️ WARNING';
      default:
        return 'ℹ️ INFO';
    }
  }

  @override
  List<Object?> get props => [medication, food, interaction, recommendation, severity];
}

class DailyMealPlanEntity extends Equatable {
  final DateTime date;
  final MealEntity breakfast;
  final MealEntity lunch;
  final MealEntity dinner;
  final NutritionEntity totalNutrition;
  final List<DrugFoodInteractionWarningEntity> warnings;
  final String dailyAdvice;
  final String bmiAdvice;
  final int calorieTarget;

  const DailyMealPlanEntity({
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.totalNutrition,
    required this.warnings,
    required this.dailyAdvice,
    required this.bmiAdvice,
    required this.calorieTarget,
  });

  @override
  List<Object?> get props => [
    date,
    breakfast,
    lunch,
    dinner,
    totalNutrition,
    warnings,
    dailyAdvice,
    bmiAdvice,
    calorieTarget,
  ];
}
