// lib/domain/usecases/log_weight_usecase.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/weight_record_entity.dart';
import 'package:nutricare_elderly/domain/repositories/weight_repository.dart';

class LogWeightUseCase {
  final WeightRepository weightRepository;

  LogWeightUseCase(this.weightRepository);

  Future<Result<WeightRecordEntity>> call({
    required String userId,
    required double weightKg,
    String? notes,
  }) async {
    return await weightRepository.logWeight(
      userId: userId,
      weightKg: weightKg,
      notes: notes,
    );
  }
}
