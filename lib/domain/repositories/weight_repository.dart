// lib/domain/repositories/weight_repository.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/weight_record_entity.dart';

abstract class WeightRepository {
  Future<Result<WeightRecordEntity>> logWeight({
    required String userId,
    required double weightKg,
    String? notes,
  });

  Future<Result<List<WeightRecordEntity>>> getWeightHistory({
    required String userId,
    required int daysBack,
  });

  Future<Result<WeightRecordEntity>> getLatestWeight(String userId);

  Future<Result<void>> deleteWeightRecord(String recordId);
}
