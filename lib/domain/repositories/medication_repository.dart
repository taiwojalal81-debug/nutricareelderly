// lib/domain/repositories/medication_repository.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/medication_entity.dart';

abstract class MedicationRepository {
  Future<Result<MedicationEntity>> addMedication({
    required String userId,
    required String medicationName,
    required List<String> reminderTimes,
    String? dosage,
    String? frequency,
    String? reason,
  });

  Future<Result<List<MedicationEntity>>> getUserMedications(String userId);

  Future<Result<void>> updateMedication({
    required String medicationId,
    String? dosage,
    String? frequency,
    List<String>? reminderTimes,
    bool? active,
  });

  Future<Result<void>> removeMedication(String medicationId);
}
