// lib/data/repositories/health_repository_impl.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/data/services/health_service.dart';
import 'package:nutricare_elderly/data/services/service_exception.dart';
import 'package:nutricare_elderly/domain/entities/condition_entity.dart';
import 'package:nutricare_elderly/domain/entities/health_profile_entity.dart';
import 'package:nutricare_elderly/domain/repositories/health_repository.dart';
import 'package:nutricare_elderly/core/services/local_storage_service.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthService healthService;

  HealthRepositoryImpl(this.healthService);

  @override
  Future<Result<HealthProfileEntity>> createHealthProfile({
    required String userId,
    required double weightKg,
    required int heightCm,
    String? bloodType,
    String? allergies,
  }) async {
    try {
      HealthProfileModel model;
      try {
        model = await healthService.createHealthProfile(
          userId: userId,
          weightKg: weightKg,
          heightCm: heightCm.toDouble(),
          bloodType: bloodType,
          allergies: allergies,
        );
      } catch (e) {
        // Fallback: If create fails, try to update in case it already exists
        model = await healthService.updateHealthProfile(
          userId: userId,
          weightKg: weightKg,
          heightCm: heightCm.toDouble(),
          bloodType: bloodType,
          allergies: allergies,
        );
      }

      final entity = HealthProfileEntity(
        id: model.id,
        userId: model.userId,
        weightKg: model.weightKg,
        heightCm: model.heightCm.toInt(),
        bmi: model.bmi ?? 0.0,
        bmiCategory: model.bmiCategory ?? 'Normal',
        bloodType: model.bloodType,
        allergies: model.allergies,
      );

      await LocalStorageService.healthProfileBox.put(userId, entity);
      return Success(entity);
    } on ServiceException catch (e) {
      return Failure(e, 'Failed to create health profile: ${e.message}');
    } catch (e) {
      return Failure(Exception(e), 'Failed to create health profile: $e');
    }
  }

  @override
  Future<Result<HealthProfileEntity>> getHealthProfile(String userId) async {
    // DEMO DATA
    if (userId == 'demo-user-123') {
      return const Success(HealthProfileEntity(
        id: 'demo-hp-123',
        userId: 'demo-user-123',
        weightKg: 75.0,
        heightCm: 170,
        bmi: 25.9,
        bmiCategory: 'Overweight',
        bloodType: 'O+',
        allergies: 'None',
      ));
    }

    try {
      final model = await healthService.getHealthProfile(userId);

      if (model == null) {
        // Return a blank entity instead of a failure to avoid UI crashes
        return Success(HealthProfileEntity(
          id: '',
          userId: userId,
          weightKg: 0,
          heightCm: 0,
          bmi: 0,
          bmiCategory: 'Unknown',
        ));
      }

      final entity = HealthProfileEntity(
        id: model.id,
        userId: model.userId,
        weightKg: model.weightKg,
        heightCm: model.heightCm.toInt(),
        bmi: model.bmi ?? 0.0,
        bmiCategory: model.bmiCategory ?? 'Normal',
        bloodType: model.bloodType,
        allergies: model.allergies,
      );

      await LocalStorageService.healthProfileBox.put(userId, entity);
      return Success(entity);
    } catch (e) {
      final cached = LocalStorageService.healthProfileBox.get(userId);
      if (cached != null) {
        return Success(cached); // Return cached data if offline
      }
      return Failure(Exception(e), 'Failed to fetch health profile. Please check your connection.');
    }
  }

  @override
  Future<Result<HealthProfileEntity>> updateHealthProfile({
    required String userId,
    required double weightKg,
    required int heightCm,
    String? bloodType,
    String? allergies,
  }) async {
    try {
      HealthProfileModel model;
      try {
        model = await healthService.updateHealthProfile(
          userId: userId,
          weightKg: weightKg,
          heightCm: heightCm.toDouble(),
          bloodType: bloodType,
          allergies: allergies,
        );
      } catch (e) {
        // Fallback: If update fails, try to create in case it does not exist yet
        model = await healthService.createHealthProfile(
          userId: userId,
          weightKg: weightKg,
          heightCm: heightCm.toDouble(),
          bloodType: bloodType,
          allergies: allergies,
        );
      }

      final entity = HealthProfileEntity(
        id: model.id,
        userId: model.userId,
        weightKg: model.weightKg,
        heightCm: model.heightCm.toInt(),
        bmi: model.bmi ?? 0.0,
        bmiCategory: model.bmiCategory ?? 'Normal',
        bloodType: model.bloodType,
        allergies: model.allergies,
      );

      await LocalStorageService.healthProfileBox.put(userId, entity);
      return Success(entity);
    } on ServiceException catch (e) {
      return Failure(e, 'Failed to update health profile: ${e.message}');
    } catch (e) {
      return Failure(Exception(e), 'Failed to update health profile: $e');
    }
  }

  @override
  Future<Result<List<ConditionEntity>>> getAllConditions() async {
    try {
      final models = await healthService.getAllConditions();

      final entities = models
          .map((model) => ConditionEntity(
                id: model.id,
                conditionName: model.conditionName,
                description: model.description ?? '',
                dietaryRestrictions: model.dietaryRestrictions ?? '',
                nutritionFocus: model.nutritionFocus ?? '',
              ))
          .toList();

      for (var condition in entities) {
        await LocalStorageService.conditionsBox.put(condition.id, condition);
      }

      return Success(entities);
    } catch (e) {
      final cached = LocalStorageService.conditionsBox.values.toList();
      if (cached.isNotEmpty) {
        return Success(cached);
      }
      return Failure(Exception(e), 'Failed to fetch conditions.');
    }
  }

  @override
  Future<Result<void>> addUserCondition({
    required String userId,
    required String conditionId,
    String? severity,
  }) async {
    try {
      final severityInt = severity != null ? int.tryParse(severity) : null;

      await healthService.addUserCondition(
        userId: userId,
        conditionId: conditionId,
        severity: severityInt,
      );

      return const Success(null);
    } on ServiceException catch (e) {
      return Failure(e, 'Failed to add condition.');
    } catch (e) {
      return Failure(Exception(e), 'Failed to add condition.');
    }
  }

  @override
  Future<Result<List<ConditionEntity>>> getUserConditions(String userId) async {
    // DEMO DATA
    if (userId == 'demo-user-123') {
      return const Success([
        ConditionEntity(
          id: 'demo-cond-1',
          conditionName: 'Hypertension',
          description: 'High blood pressure',
          dietaryRestrictions: 'Low sodium',
          nutritionFocus: 'Potassium, Magnesium',
        ),
      ]);
    }

    try {
      final models = await healthService.getUserConditions(userId);

      final entities = models.map((model) {
        final condition = model.condition;
        return ConditionEntity(
          id: model.conditionId,
          conditionName: condition?.conditionName ?? 'Unknown',
          description: condition?.description ?? '',
          dietaryRestrictions: condition?.dietaryRestrictions ?? '',
          nutritionFocus: condition?.nutritionFocus ?? '',
        );
      }).toList();

      return Success(entities);
    } catch (e) {
      // User specific conditions cache is harder to store cleanly right now, we can fallback to empty array or try to fetch full conditions.
      return Failure(Exception(e), 'Failed to fetch user conditions.');
    }
  }

  @override
  Future<Result<void>> removeUserCondition({
    required String userId,
    required String conditionId,
  }) async {
    try {
      // Get user conditions to find the right ID
      final userConditions = await healthService.getUserConditions(userId);
      UserConditionModel? userConditionToRemove;
      for (final uc in userConditions) {
        if (uc.conditionId == conditionId) {
          userConditionToRemove = uc;
          break;
        }
      }

      if (userConditionToRemove == null) {
        return Failure(
          Exception('Condition not found'),
          'User condition not found.',
        );
      }

      await healthService.removeUserCondition(userConditionToRemove.id);
    
      return const Success(null);
    } on ServiceException catch (e) {
      return Failure(e, 'Failed to remove condition.');
    } catch (e) {
      return Failure(Exception(e), 'Failed to remove condition.');
    }
  }
}
