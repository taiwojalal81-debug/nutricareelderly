import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/health_profile_entity.dart';
import '../../domain/entities/weight_record_entity.dart';
import '../../domain/entities/nigerian_food_entity.dart';
import '../../domain/entities/condition_entity.dart';

class LocalStorageService {
  static const String healthProfileBoxName = 'health_profile_box';
  static const String weightHistoryBoxName = 'weight_history_box';
  static const String foodDatabaseBoxName = 'food_database_box';
  static const String conditionsBoxName = 'conditions_box';
  static const String medicationsBoxName = 'medications_box';

  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register Adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HealthProfileEntityAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(WeightRecordEntityAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(NigerianFoodEntityAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ConditionEntityAdapter());
      }

      // Open Boxes
      await Future.wait([
        Hive.openBox<HealthProfileEntity>(healthProfileBoxName),
        Hive.openBox<WeightRecordEntity>(weightHistoryBoxName),
        Hive.openBox<NigerianFoodEntity>(foodDatabaseBoxName),
        Hive.openBox<ConditionEntity>(conditionsBoxName),
        Hive.openBox(medicationsBoxName),
      ]);
      
      debugPrint('LocalStorageService: Hive initialized and boxes opened successfully.');
    } catch (e) {
      debugPrint('LocalStorageService Error: Failed to initialize Hive: $e');
    }
  }

  // Helper getters for boxes
  static Box<HealthProfileEntity> get healthProfileBox => Hive.box<HealthProfileEntity>(healthProfileBoxName);
  static Box<WeightRecordEntity> get weightHistoryBox => Hive.box<WeightRecordEntity>(weightHistoryBoxName);
  static Box<NigerianFoodEntity> get foodDatabaseBox => Hive.box<NigerianFoodEntity>(foodDatabaseBoxName);
  static Box<ConditionEntity> get conditionsBox => Hive.box<ConditionEntity>(conditionsBoxName);
  static Box get medicationsBox => Hive.box(medicationsBoxName);
}
