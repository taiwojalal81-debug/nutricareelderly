// lib/domain/entities/health_profile_entity.dart

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'health_profile_entity.g.dart';

@HiveType(typeId: 0)
class HealthProfileEntity extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final double weightKg;
  @HiveField(3)
  final int heightCm;
  @HiveField(4)
  final double bmi;
  @HiveField(5)
  final String bmiCategory;
  @HiveField(6)
  final String? bloodType;
  @HiveField(7)
  final String? allergies;

  const HealthProfileEntity({
    required this.id,
    required this.userId,
    required this.weightKg,
    required this.heightCm,
    required this.bmi,
    required this.bmiCategory,
    this.bloodType,
    this.allergies,
  });

  @override
  List<Object?> get props => [id, userId, weightKg, heightCm, bmi, bmiCategory, bloodType, allergies];
}
