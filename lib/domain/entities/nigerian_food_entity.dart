// lib/domain/entities/nigerian_food_entity.dart

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'nigerian_food_entity.g.dart';

@HiveType(typeId: 2)
class NigerianFoodEntity extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String foodName;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final int portionSizeGrams;
  @HiveField(4)
  final double caloriesPerPortion;
  @HiveField(5)
  final double proteinG;
  @HiveField(6)
  final double carbsG;
  @HiveField(7)
  final double fatG;
  @HiveField(8)
  final double fiberG;
  @HiveField(9)
  final int potassiumMg;
  @HiveField(10)
  final int sodiumMg;
  @HiveField(11)
  final List<String> suitableForConditions;
  @HiveField(12)
  final String mealCategory;
  @HiveField(13)
  final String? ethnicity;
  @HiveField(14)
  final String? recipe;
  @HiveField(15)
  final String? imageUrl;

  const NigerianFoodEntity({
    required this.id,
    required this.foodName,
    required this.description,
    required this.portionSizeGrams,
    required this.caloriesPerPortion,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.potassiumMg,
    required this.sodiumMg,
    required this.suitableForConditions,
    required this.mealCategory,
    this.ethnicity,
    this.recipe,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    foodName,
    description,
    portionSizeGrams,
    caloriesPerPortion,
    proteinG,
    carbsG,
    fatG,
    fiberG,
    potassiumMg,
    sodiumMg,
    suitableForConditions,
    mealCategory,
    ethnicity,
    recipe,
    imageUrl,
  ];
}
