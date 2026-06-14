// lib/domain/entities/medication_log_entity.dart

import 'package:equatable/equatable.dart';

class MedicationLogEntity extends Equatable {
  final String id;
  final String medicationId;
  final DateTime takenAt;
  final String status; // 'taken', 'skipped', 'missed'

  const MedicationLogEntity({
    required this.id,
    required this.medicationId,
    required this.takenAt,
    required this.status,
  });

  @override
  List<Object?> get props => [id, medicationId, takenAt, status];
}
