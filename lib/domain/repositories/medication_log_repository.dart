// lib/domain/repositories/medication_log_repository.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/medication_log_entity.dart';

abstract class MedicationLogRepository {
  Future<Result<MedicationLogEntity>> logMedication({
    required String medicationId,
    required String status,
    DateTime? takenAt,
  });

  Future<Result<List<MedicationLogEntity>>> getLogsForDate(String userId, DateTime date);
  
  Future<Result<void>> deleteMedicationLog({
    required String medicationId,
    required DateTime date,
  });
}
