// lib/domain/entities/condition_entity.dart

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'condition_entity.g.dart';

@HiveType(typeId: 3)
class ConditionEntity extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String conditionName;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String dietaryRestrictions;
  @HiveField(4)
  final String nutritionFocus;

  const ConditionEntity({
    required this.id,
    required this.conditionName,
    required this.description,
    required this.dietaryRestrictions,
    required this.nutritionFocus,
  });

  @override
  List<Object?> get props => [id, conditionName, description, dietaryRestrictions, nutritionFocus];
}
