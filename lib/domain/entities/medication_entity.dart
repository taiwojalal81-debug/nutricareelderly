// lib/domain/entities/medication_entity.dart

import 'package:equatable/equatable.dart';

class MedicationEntity extends Equatable {
  final String id;
  final String userId;
  final String medicationName;
  final String? dosage;
  final String? frequency;
  final DateTime? prescribedDate;
  final String? reason;
  final bool active;
  final List<String> reminderTimes; // Format: ["08:00", "20:00"]

  const MedicationEntity({
    required this.id,
    required this.userId,
    required this.medicationName,
    this.dosage,
    this.frequency,
    this.prescribedDate,
    this.reason,
    this.active = true,
    this.reminderTimes = const [],
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        medicationName,
        dosage,
        frequency,
        prescribedDate,
        reason,
        active,
        reminderTimes
      ];
}
