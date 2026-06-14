// lib/data/models/weight_record_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nutricare_elderly/domain/entities/weight_record_entity.dart';

part 'weight_record_model.g.dart';

@JsonSerializable()
class WeightRecordModel extends WeightRecordEntity {
  const WeightRecordModel({
    required String id,
    required String userId,
    required double weightKg,
    required DateTime recordedDate,
    double? bmi,
    String? notes,
  }) : super(
    id: id,
    userId: userId,
    weightKg: weightKg,
    recordedDate: recordedDate,
    bmi: bmi,
    notes: notes,
  );

  factory WeightRecordModel.fromJson(Map<String, dynamic> json) => _$WeightRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordModelToJson(this);

  factory WeightRecordModel.fromEntity(WeightRecordEntity entity) => WeightRecordModel(
    id: entity.id,
    userId: entity.userId,
    weightKg: entity.weightKg,
    recordedDate: entity.recordedDate,
    bmi: entity.bmi,
    notes: entity.notes,
  );
}
