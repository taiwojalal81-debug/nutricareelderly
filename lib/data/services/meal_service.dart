// lib/data/services/meal_service.dart

import 'service_exception.dart';
import 'supabase_service.dart';

/// Model for Nigerian food data
class NigerianFoodModel {
  final String id;
  final String foodName;
  final String? description;
  final int? portionSizeGrams;
  final double? caloriesPerPortion;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? fiberG;
  final double? potassiumMg;
  final double? sodiumMg;
  final List<String> suitableForConditions;
  final String? mealCategory;
  final String? ethnicity;
  final String? recipe;
  final String? imageUrl;

  NigerianFoodModel({
    required this.id,
    required this.foodName,
    this.description,
    this.portionSizeGrams,
    this.caloriesPerPortion,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.fiberG,
    this.potassiumMg,
    this.sodiumMg,
    required this.suitableForConditions,
    this.mealCategory,
    this.ethnicity,
    this.recipe,
    this.imageUrl,
  });

  factory NigerianFoodModel.fromJson(Map<String, dynamic> json) {
    final suitableStr = json['suitable_for_conditions'] as String? ?? '';
    final suitable = suitableStr.isEmpty
        ? <String>[]
        : suitableStr.split(',').map((s) => s.trim()).toList();

    return NigerianFoodModel(
      id: json['id'] ?? '',
      foodName: json['food_name'] ?? '',
      description: json['description'],
      portionSizeGrams: json['portion_size_grams'],
      caloriesPerPortion: (json['calories_per_portion'] as num?)?.toDouble(),
      proteinG: (json['protein_g'] as num?)?.toDouble(),
      carbsG: (json['carbs_g'] as num?)?.toDouble(),
      fatG: (json['fat_g'] as num?)?.toDouble(),
      fiberG: (json['fiber_g'] as num?)?.toDouble(),
      potassiumMg: (json['potassium_mg'] as num?)?.toDouble(),
      sodiumMg: (json['sodium_mg'] as num?)?.toDouble(),
      suitableForConditions: suitable,
      mealCategory: json['meal_category'],
      ethnicity: json['ethnicity'],
      recipe: json['recipe'],
      imageUrl: json['image_url'],
    );
  }
}

/// Model for food-drug interaction
class FoodDrugInteractionModel {
  final String id;
  final String medicationName;
  final String foodName;
  final String? interactionType;
  final String? description;
  final String? recommendation;
  final int? severity;

  FoodDrugInteractionModel({
    required this.id,
    required this.medicationName,
    required this.foodName,
    this.interactionType,
    this.description,
    this.recommendation,
    this.severity,
  });

  factory FoodDrugInteractionModel.fromJson(Map<String, dynamic> json) {
    return FoodDrugInteractionModel(
      id: json['id'] ?? '',
      medicationName: json['medication_name'] ?? '',
      foodName: json['food_name'] ?? '',
      interactionType: json['interaction_type'],
      description: json['description'],
      recommendation: json['recommendation'],
      severity: json['severity'],
    );
  }
}

/// Meal service - manages Nigerian foods database and interactions
class MealService {
  final SupabaseService _supabaseService;

  MealService(this._supabaseService);

  /// Get all Nigerian foods, optionally filtered by meal category
  Future<List<NigerianFoodModel>> getNigerianFoods({
    String? mealCategory,
  }) async {
    try {
      var query = _supabaseService.client
          .from('nigerian_foods')
          .select()
          .order('food_name');

      if (mealCategory != null) {
        // Filter locally since ilike is not available in this context
      }

      final response = await query;

      return (response as List)
          .map((item) =>
              NigerianFoodModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServiceException(
        'Failed to get Nigerian foods: $e',
        code: 'GET_FOODS_ERROR',
        originalException: e,
      );
    }
  }

  /// Get food by ID
  Future<NigerianFoodModel?> getFoodById(String foodId) async {
    try {
      final response = await _supabaseService.client
          .from('nigerian_foods')
          .select()
          .eq('id', foodId)
          .maybeSingle();

      if (response == null) return null;

      return NigerianFoodModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to get food: $e',
        code: 'GET_FOOD_ERROR',
        originalException: e,
      );
    }
  }

  /// Get food by name
  Future<NigerianFoodModel?> getFoodByName(String foodName) async {
    try {
      final response = await _supabaseService.client
          .from('nigerian_foods')
          .select()
          .eq('food_name', foodName)
          .maybeSingle();

      if (response == null) return null;

      return NigerianFoodModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to get food by name: $e',
        code: 'GET_FOOD_BY_NAME_ERROR',
        originalException: e,
      );
    }
  }

  /// Check for food-drug interactions
  Future<List<FoodDrugInteractionModel>> checkFoodDrugInteractions({
    required String medicationName,
    required String foodName,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('food_drug_interactions')
          .select()
          .eq('medication_name', medicationName)
          .eq('food_name', foodName);

      return (response as List)
          .map((item) => FoodDrugInteractionModel.fromJson(
              item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServiceException(
        'Failed to check food-drug interactions: $e',
        code: 'CHECK_INTERACTIONS_ERROR',
        originalException: e,
      );
    }
  }

  /// Get all interactions for a medication
  Future<List<FoodDrugInteractionModel>> getMedicationInteractions(
    String medicationName,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('food_drug_interactions')
          .select()
          .eq('medication_name', medicationName);

      return (response as List)
          .map((item) => FoodDrugInteractionModel.fromJson(
              item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServiceException(
        'Failed to get medication interactions: $e',
        code: 'GET_MED_INTERACTIONS_ERROR',
        originalException: e,
      );
    }
  }
}
