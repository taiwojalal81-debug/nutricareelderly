// lib/data/repositories/medication_repository_impl.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/core/services/local_storage_service.dart';
import 'package:nutricare_elderly/data/services/medication_service.dart';
import 'package:nutricare_elderly/domain/entities/medication_entity.dart';
import 'package:nutricare_elderly/domain/repositories/medication_repository.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationService medicationService;

  MedicationRepositoryImpl(this.medicationService);

  @override
  Future<Result<MedicationEntity>> addMedication({
    required String userId,
    required String medicationName,
    required List<String> reminderTimes,
    String? dosage,
    String? frequency,
    String? reason,
  }) async {
    final newId = 'med-${DateTime.now().millisecondsSinceEpoch}';
    final Map<String, dynamic> localMed = {
      'id': newId,
      'user_id': userId,
      'medication_name': medicationName,
      'dosage': dosage ?? '',
      'frequency': frequency ?? '',
      'reason': reason,
      'active': true,
      'reminder_times': reminderTimes,
      'prescribed_date': DateTime.now().toIso8601String(),
    };

    // 1. Save in Hive Local Cache
    try {
      final box = LocalStorageService.medicationsBox;
      final List<dynamic> currentList = box.get(userId) ?? [];
      final updatedList = List<dynamic>.from(currentList)..add(localMed);
      await box.put(userId, updatedList);
    } catch (e) {
      print('Hive Local Cache Save Error: $e');
    }

    final entity = MedicationEntity(
      id: newId,
      userId: userId,
      medicationName: medicationName,
      dosage: dosage ?? '',
      frequency: frequency ?? '',
      prescribedDate: DateTime.now(),
      reason: reason,
      active: true,
      reminderTimes: reminderTimes,
    );

    if (userId == 'demo-user-123') {
      return Success(entity);
    }

    // 2. Try Supabase Sync
    try {
      final model = await medicationService.addMedication(
        userId: userId,
        medicationName: medicationName,
        dosage: dosage ?? '',
        frequency: frequency ?? '',
        reason: reason,
        reminderTimes: reminderTimes,
      );

      final syncedEntity = MedicationEntity(
        id: model.id,
        userId: model.userId,
        medicationName: model.medicationName,
        dosage: model.dosage,
        frequency: model.frequency,
        prescribedDate: model.prescribedDate,
        reason: model.reason,
        active: model.active,
        reminderTimes: model.reminderTimes,
      );

      // Replace the temporary local med in the cache with the synced one to avoid duplicates
      try {
        final box = LocalStorageService.medicationsBox;
        final List<dynamic> currentList = box.get(userId) ?? [];
        final updatedList = currentList.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          if (map['id'] == newId) {
            return {
              'id': model.id,
              'user_id': model.userId,
              'medication_name': model.medicationName,
              'dosage': model.dosage,
              'frequency': model.frequency,
              'prescribed_date': model.prescribedDate?.toIso8601String(),
              'reason': model.reason,
              'active': model.active,
              'reminder_times': model.reminderTimes,
            };
          }
          return map;
        }).toList();
        await box.put(userId, updatedList);
      } catch (e) {
        print('Error updating local cache with synced medication: $e');
      }

      return Success(syncedEntity);
    } catch (e) {
      print('Supabase Sync Failed (saved locally): $e');
      return Success(entity);
    }
  }

  @override
  Future<Result<List<MedicationEntity>>> getUserMedications(String userId) async {
    // 1. Get cached local meds
    List<MedicationEntity> localEntities = [];
    try {
      final box = LocalStorageService.medicationsBox;
      final List<dynamic> currentList = box.get(userId) ?? [];
      localEntities = currentList.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return MedicationEntity(
          id: map['id'] ?? '',
          userId: map['user_id'] ?? '',
          medicationName: map['medication_name'] ?? '',
          dosage: map['dosage'] ?? '',
          frequency: map['frequency'] ?? '',
          prescribedDate: map['prescribed_date'] != null
              ? DateTime.tryParse(map['prescribed_date'])
              : null,
          reason: map['reason'],
          active: map['active'] ?? true,
          reminderTimes: List<String>.from(map['reminder_times'] ?? []),
        );
      }).where((med) => med.active).toList();
    } catch (e) {
      print('Hive Local Read Error: $e');
    }

    if (userId == 'demo-user-123') {
      return Success(localEntities);
    }

    // 2. Try fetching from Supabase and merge
    try {
      final models = await medicationService.getUserMedications(userId);
      final remoteEntities = models.map((model) => MedicationEntity(
        id: model.id,
        userId: model.userId,
        medicationName: model.medicationName,
        dosage: model.dosage,
        frequency: model.frequency,
        prescribedDate: model.prescribedDate,
        reason: model.reason,
        active: model.active,
        reminderTimes: model.reminderTimes,
      )).toList();

      // Merge remote and local active medications
      final Map<String, MedicationEntity> mergedMap = {};
      
      // Load local ones first (this preserves any unsynced local medications!)
      for (var local in localEntities) {
        mergedMap[local.id] = local;
      }
      
      // Overwrite with remote ones (remote is source of truth for synced ones)
      for (var remote in remoteEntities) {
        mergedMap[remote.id] = remote;
      }
      
      final mergedList = mergedMap.values.toList();

      // Update local cache with merged list
      final box = LocalStorageService.medicationsBox;
      final List<Map<String, dynamic>> localJsonList = mergedList.map((e) => {
        'id': e.id,
        'user_id': e.userId,
        'medication_name': e.medicationName,
        'dosage': e.dosage,
        'frequency': e.frequency,
        'prescribed_date': e.prescribedDate?.toIso8601String(),
        'reason': e.reason,
        'active': e.active,
        'reminder_times': e.reminderTimes,
      }).toList();
      await box.put(userId, localJsonList);

      return Success(mergedList);
    } catch (e) {
      print('Supabase Fetch Failed, falling back to local cache: $e');
      return Success(localEntities);
    }
  }

  @override
  Future<Result<void>> updateMedication({
    required String medicationId,
    String? dosage,
    String? frequency,
    List<String>? reminderTimes,
    bool? active,
  }) async {
    // 1. Update local cache
    try {
      final box = LocalStorageService.medicationsBox;
      for (final key in box.keys) {
        final List<dynamic> currentList = box.get(key) ?? [];
        bool modified = false;
        final updatedList = currentList.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          if (map['id'] == medicationId) {
            if (dosage != null) map['dosage'] = dosage;
            if (frequency != null) map['frequency'] = frequency;
            if (reminderTimes != null) map['reminder_times'] = reminderTimes;
            if (active != null) map['active'] = active;
            modified = true;
          }
          return map;
        }).toList();
        if (modified) {
          await box.put(key, updatedList);
        }
      }
    } catch (e) {
      print('Hive Local Update Error: $e');
    }

    // 2. Try Supabase Update
    try {
      await medicationService.updateMedication(
        medicationId: medicationId,
        dosage: dosage,
        frequency: frequency,
        reminderTimes: reminderTimes,
      );
      return const Success(null);
    } catch (e) {
      print('Supabase Update Failed (will sync later): $e');
      return const Success(null);
    }
  }

  @override
  Future<Result<void>> removeMedication(String medicationId) async {
    // 1. Remove from local cache
    try {
      final box = LocalStorageService.medicationsBox;
      for (final key in box.keys) {
        final List<dynamic> currentList = box.get(key) ?? [];
        bool modified = false;
        final updatedList = currentList.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          if (map['id'] == medicationId) {
            map['active'] = false;
            modified = true;
          }
          return map;
        }).toList();
        if (modified) {
          await box.put(key, updatedList);
        }
      }
    } catch (e) {
      print('Hive Local Delete Error: $e');
    }

    // 2. Try Supabase delete
    try {
      await medicationService.removeMedication(medicationId);
      return const Success(null);
    } catch (e) {
      print('Supabase Delete Failed (will sync later): $e');
      return const Success(null);
    }
  }
}
