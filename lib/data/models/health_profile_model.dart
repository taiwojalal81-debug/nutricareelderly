// lib/data/models/health_profile_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nutricare_elderly/domain/entities/health_profile_entity.dart';

part 'health_profile_model.g.dart';

@JsonSerializable()
class HealthProfileModel extends HealthProfileEntity {
  const HealthProfileModel({
    required String id,
    required String userId,
    required double weightKg,
    required int heightCm,
    required double bmi,
    required String bmiCategory,
    String? bloodType,
    String? allergies,
  }) : super(
    id: id,
    userId: userId,
    weightKg: weightKg,
    heightCm: heightCm,
    bmi: bmi,
    bmiCategory: bmiCategory,
    bloodType: bloodType,
    allergies: allergies,
  );

  static String _calculateBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) {
    final double weight = (json['weight_kg'] as num?)?.toDouble() ?? 70.0;
    final int height = (json['height_cm'] as num?)?.toInt() ?? 170;
    final double calculatedBmi = weight / ((height / 100.0) * (height / 100.0));
    
    final Map<String, dynamic> sanitizedJson = Map<String, dynamic>.from(json);
    sanitizedJson['id'] = json['id']?.toString() ?? '';
    sanitizedJson['user_id'] = json['user_id']?.toString() ?? '';
    sanitizedJson['weight_kg'] = weight;
    sanitizedJson['height_cm'] = height;
    sanitizedJson['bmi'] = (json['bmi'] as num?)?.toDouble() ?? calculatedBmi;
    sanitizedJson['bmi_category'] = json['bmi_category'] ?? _calculateBmiCategory(calculatedBmi);
    
    return _$HealthProfileModelFromJson(sanitizedJson);
  }

  Map<String, dynamic> toJson() => _$HealthProfileModelToJson(this);

  factory HealthProfileModel.fromEntity(HealthProfileEntity entity) => HealthProfileModel(
    id: entity.id,
    userId: entity.userId,
    weightKg: entity.weightKg,
    heightCm: entity.heightCm,
    bmi: entity.bmi,
    bmiCategory: entity.bmiCategory,
    bloodType: entity.bloodType,
    allergies: entity.allergies,
  );
}
