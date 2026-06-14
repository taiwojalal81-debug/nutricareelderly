// lib/data/models/condition_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nutricare_elderly/domain/entities/condition_entity.dart';

part 'condition_model.g.dart';

@JsonSerializable()
class ConditionModel extends ConditionEntity {
  const ConditionModel({
    required String id,
    required String conditionName,
    required String description,
    required String dietaryRestrictions,
    required String nutritionFocus,
  }) : super(
    id: id,
    conditionName: conditionName,
    description: description,
    dietaryRestrictions: dietaryRestrictions,
    nutritionFocus: nutritionFocus,
  );

  factory ConditionModel.fromJson(Map<String, dynamic> json) => _$ConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConditionModelToJson(this);

  factory ConditionModel.fromEntity(ConditionEntity entity) => ConditionModel(
    id: entity.id,
    conditionName: entity.conditionName,
    description: entity.description,
    dietaryRestrictions: entity.dietaryRestrictions,
    nutritionFocus: entity.nutritionFocus,
  );
}
