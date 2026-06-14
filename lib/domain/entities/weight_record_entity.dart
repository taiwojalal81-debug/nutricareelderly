// lib/domain/entities/weight_record_entity.dart

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'weight_record_entity.g.dart';

@HiveType(typeId: 1)
class WeightRecordEntity extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final double weightKg;
  @HiveField(3)
  final DateTime recordedDate;
  @HiveField(4)
  final double? bmi;
  @HiveField(5)
  final String? notes;

  const WeightRecordEntity({
    required this.id,
    required this.userId,
    required this.weightKg,
    required this.recordedDate,
    this.bmi,
    this.notes,
  });

  @override
  List<Object?> get props => [id, userId, weightKg, recordedDate, bmi, notes];
}
