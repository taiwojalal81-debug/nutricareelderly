// lib/data/models/nigerian_food_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nutricare_elderly/domain/entities/nigerian_food_entity.dart';

part 'nigerian_food_model.g.dart';

@JsonSerializable()
class NigerianFoodModel extends NigerianFoodEntity {
  const NigerianFoodModel({
    required String id,
    required String foodName,
    required String description,
    required int portionSizeGrams,
    required double caloriesPerPortion,
    required double proteinG,
    required double carbsG,
    required double fatG,
    required double fiberG,
    required int potassiumMg,
    required int sodiumMg,
    required List<String> suitableForConditions,
    required String mealCategory,
    String? imageUrl,
  }) : super(
    id: id,
    foodName: foodName,
    description: description,
    portionSizeGrams: portionSizeGrams,
    caloriesPerPortion: caloriesPerPortion,
    proteinG: proteinG,
    carbsG: carbsG,
    fatG: fatG,
    fiberG: fiberG,
    potassiumMg: potassiumMg,
    sodiumMg: sodiumMg,
    suitableForConditions: suitableForConditions,
    mealCategory: mealCategory,
    imageUrl: imageUrl,
  );

  factory NigerianFoodModel.fromJson(Map<String, dynamic> json) {
    return _$NigerianFoodModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NigerianFoodModelToJson(this);

  factory NigerianFoodModel.fromEntity(NigerianFoodEntity entity) => NigerianFoodModel(
    id: entity.id,
    foodName: entity.foodName,
    description: entity.description,
    portionSizeGrams: entity.portionSizeGrams,
    caloriesPerPortion: entity.caloriesPerPortion,
    proteinG: entity.proteinG,
    carbsG: entity.carbsG,
    fatG: entity.fatG,
    fiberG: entity.fiberG,
    potassiumMg: entity.potassiumMg,
    sodiumMg: entity.sodiumMg,
    suitableForConditions: entity.suitableForConditions,
    mealCategory: entity.mealCategory,
    imageUrl: entity.imageUrl,
  );
}
