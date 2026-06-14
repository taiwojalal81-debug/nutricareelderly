// lib/data/models/medication_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nutricare_elderly/domain/entities/medication_entity.dart';

part 'medication_model.g.dart';

@JsonSerializable()
class MedicationModel extends MedicationEntity {
  const MedicationModel({
    required String id,
    required String userId,
    required String medicationName,
    String? dosage,
    String? frequency,
    DateTime? prescribedDate,
    String? reason,
    bool active = true,
  }) : super(
    id: id,
    userId: userId,
    medicationName: medicationName,
    dosage: dosage,
    frequency: frequency,
    prescribedDate: prescribedDate,
    reason: reason,
    active: active,
  );

  factory MedicationModel.fromJson(Map<String, dynamic> json) => _$MedicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationModelToJson(this);

  factory MedicationModel.fromEntity(MedicationEntity entity) => MedicationModel(
    id: entity.id,
    userId: entity.userId,
    medicationName: entity.medicationName,
    dosage: entity.dosage,
    frequency: entity.frequency,
    prescribedDate: entity.prescribedDate,
    reason: entity.reason,
    active: entity.active,
  );
}
