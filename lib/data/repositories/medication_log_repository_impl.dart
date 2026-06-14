// lib/data/repositories/medication_log_repository_impl.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/data/services/medication_log_service.dart';
import 'package:nutricare_elderly/data/services/service_exception.dart';
import 'package:nutricare_elderly/domain/entities/medication_log_entity.dart';
import 'package:nutricare_elderly/domain/repositories/medication_log_repository.dart';

class MedicationLogRepositoryImpl implements MedicationLogRepository {
  final MedicationLogService medicationLogService;

  MedicationLogRepositoryImpl(this.medicationLogService);

  @override
  Future<Result<MedicationLogEntity>> logMedication({
    required String medicationId,
    required String status,
    DateTime? takenAt,
  }) async {
    try {
      final model = await medicationLogService.logMedication(
        medicationId: medicationId,
        status: status,
        takenAt: takenAt,
      );

      return Success(MedicationLogEntity(
        id: model.id,
        medicationId: model.medicationId,
        takenAt: model.takenAt,
        status: model.status,
      ));
    } on ServiceException catch (e) {
      return Failure(e, 'Failed to log medication.');
    } catch (e) {
      return Failure(Exception(e), 'An unexpected error occurred.');
    }
  }

  @override
  Future<Result<List<MedicationLogEntity>>> getLogsForDate(String userId, DateTime date) async {
    try {
      final models = await medicationLogService.getLogsForDate(userId, date);

      final entities = models.map((model) => MedicationLogEntity(
        id: model.id,
        medicationId: model.medicationId,
        takenAt: model.takenAt,
        status: model.status,
      )).toList();

      return Success(entities);
    } on ServiceException catch (e) {
      return Failure(e, 'Failed to fetch medication logs.');
    } catch (e) {
      return Failure(Exception(e), 'An unexpected error occurred.');
    }
  }

  @override
  Future<Result<void>> deleteMedicationLog({
    required String medicationId,
    required DateTime date,
  }) async {
    try {
      await medicationLogService.deleteMedicationLog(
        medicationId: medicationId,
        date: date,
      );
      return const Success(null);
    } on ServiceException catch (e) {
      return Failure(e, 'Failed to delete medication log.');
    } catch (e) {
      return Failure(Exception(e), 'An unexpected error occurred.');
    }
  }
}
