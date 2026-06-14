// lib/data/repositories/hydration_repository_impl.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/data/services/hydration_service.dart';
import 'package:nutricare_elderly/data/services/service_exception.dart';
import 'package:nutricare_elderly/domain/entities/hydration_entity.dart';
import 'package:nutricare_elderly/domain/repositories/hydration_repository.dart';

class HydrationRepositoryImpl implements HydrationRepository {
  final HydrationService hydrationService;

  HydrationRepositoryImpl(this.hydrationService);

  @override
  Future<Result<HydrationEntity?>> getDailyHydration(String userId, DateTime date) async {
    try {
      final model = await hydrationService.getDailyHydration(userId, date);
      
      if (model == null) return const Success(null);

      return Success(HydrationEntity(
        id: model.id,
        userId: model.userId,
        recordedDate: model.recordedDate,
        glassesCount: model.glassesCount,
      ));
    } on ServiceException catch (e) {
      return Failure(e, 'Failed to fetch hydration.');
    } catch (e) {
      return Failure(Exception(e), 'An unexpected error occurred.');
    }
  }

  @override
  Future<Result<HydrationEntity>> updateHydration({
    required String userId,
    required DateTime date,
    required int glassesCount,
  }) async {
    try {
      final model = await hydrationService.updateHydration(
        userId: userId,
        date: date,
        glassesCount: glassesCount,
      );

      return Success(HydrationEntity(
        id: model.id,
        userId: model.userId,
        recordedDate: model.recordedDate,
        glassesCount: model.glassesCount,
      ));
    } on ServiceException catch (e) {
      return Failure(e, 'Failed to update hydration.');
    } catch (e) {
      return Failure(Exception(e), 'An unexpected error occurred.');
    }
  }
}
