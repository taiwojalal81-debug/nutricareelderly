// lib/data/repositories/weight_repository_impl.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/data/services/service_exception.dart';
import 'package:nutricare_elderly/data/services/weight_service.dart';
import 'package:nutricare_elderly/domain/entities/weight_record_entity.dart';
import 'package:nutricare_elderly/domain/repositories/weight_repository.dart';
import 'package:nutricare_elderly/core/services/local_storage_service.dart';

class WeightRepositoryImpl implements WeightRepository {
  final WeightService weightService;

  WeightRepositoryImpl(this.weightService);

  @override
  Future<Result<WeightRecordEntity>> logWeight({
    required String userId,
    required double weightKg,
    String? notes,
  }) async {
    try {
      final model = await weightService.logWeight(
        userId: userId,
        weightKg: weightKg,
        notes: notes,
      );
      final entity = WeightRecordEntity(
        id: model.id,
        userId: model.userId,
        weightKg: model.weightKg,
        recordedDate: model.recordedDate,
        bmi: model.bmi,
        notes: model.notes,
      );
      
      await LocalStorageService.weightHistoryBox.put(entity.id, entity);
      return Success(entity);
    } on ServiceException catch (e) {
      return Failure(e, e.message);
    } on Exception catch (e) {
      return Failure(e, 'Failed to log weight.');
    }
  }

  @override
  Future<Result<List<WeightRecordEntity>>> getWeightHistory({
    required String userId,
    required int daysBack,
  }) async {
    // DEMO DATA
    if (userId == 'demo-user-123') {
      return Success([
        WeightRecordEntity(
          id: 'demo-w-123',
          userId: 'demo-user-123',
          weightKg: 75.0,
          recordedDate: DateTime.now(),
          bmi: 25.9,
        ),
      ]);
    }

    try {
      final models = await weightService.getWeightHistory(
        userId: userId,
        daysBack: daysBack,
      );
      final entities = models
          .map((m) => WeightRecordEntity(
            id: m.id,
            userId: m.userId,
            weightKg: m.weightKg,
            recordedDate: m.recordedDate,
            bmi: m.bmi,
            notes: m.notes,
          ))
          .toList();
          
      // Cache all results
      for (var record in entities) {
        await LocalStorageService.weightHistoryBox.put(record.id, record);
      }
      return Success(entities);
    } catch (e) {
      // Fallback to cache if network fails
      final cached = LocalStorageService.weightHistoryBox.values
          .where((r) => r.userId == userId)
          .toList();
      cached.sort((a, b) => b.recordedDate.compareTo(a.recordedDate)); // latest first
      if (cached.isNotEmpty) {
        return Success(cached);
      }
      return Failure(Exception(e), 'Failed to fetch weight history.');
    }
  }

  @override
  Future<Result<WeightRecordEntity>> getLatestWeight(String userId) async {
    // DEMO DATA
    if (userId == 'demo-user-123') {
      return Success(WeightRecordEntity(
        id: 'demo-w-123',
        userId: 'demo-user-123',
        weightKg: 75.0,
        recordedDate: DateTime.now(),
        bmi: 25.9,
      ));
    }

    try {
      final model = await weightService.getLatestWeight(userId);
      
      if (model == null) {
        return Failure(
          Exception('No weight records found'),
          'No weight records found. Start by logging your weight.',
        );
      }
      
      final entity = WeightRecordEntity(
        id: model.id,
        userId: model.userId,
        weightKg: model.weightKg,
        recordedDate: model.recordedDate,
        bmi: model.bmi,
        notes: model.notes,
      );
      
      await LocalStorageService.weightHistoryBox.put(entity.id, entity);
      return Success(entity);
    } catch (e) {
      final cached = LocalStorageService.weightHistoryBox.values
          .where((r) => r.userId == userId)
          .toList();
      cached.sort((a, b) => b.recordedDate.compareTo(a.recordedDate));
      
      if (cached.isNotEmpty) {
        return Success(cached.first);
      }
      
      return Failure(Exception(e), 'Failed to fetch latest weight.');
    }
  }

  @override
  Future<Result<void>> deleteWeightRecord(String recordId) async {
    try {
      await weightService.deleteWeightRecord(recordId);
      await LocalStorageService.weightHistoryBox.delete(recordId);
      return const Success(null);
    } on ServiceException catch (e) {
      return Failure(e, e.message);
    } on Exception catch (e) {
      return Failure(e, 'Failed to delete weight record.');
    }
  }
}
