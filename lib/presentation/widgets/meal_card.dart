// lib/presentation/widgets/meal_card.dart

import 'package:flutter/material.dart';
import 'package:nutricare_elderly/domain/entities/meal_recommendation_entity.dart';
import 'package:nutricare_elderly/presentation/widgets/high_contrast_card.dart';
import 'package:nutricare_elderly/theme/app_colors.dart';

class MealCard extends StatelessWidget {
  final MealEntity meal;

  const MealCard({
    Key? key,
    required this.meal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HighContrastCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal.mealType.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            meal.food.foodName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            meal.food.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NutritionInfo(
                label: 'Calories',
                value: '${meal.calories.toStringAsFixed(0)} kcal',
              ),
              _NutritionInfo(
                label: 'Protein',
                value: '${meal.protein.toStringAsFixed(1)}g',
              ),
              _NutritionInfo(
                label: 'Carbs',
                value: '${meal.carbs.toStringAsFixed(1)}g',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutritionInfo extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
