// lib/data/datasources/supabase_meal_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutricare_elderly/data/models/nigerian_food_model.dart';

abstract class SupabaseMealDataSource {
  Future<List<NigerianFoodModel>> getNigerianFoods({
    String? mealCategory,
    List<String>? conditionFilters,
  });

  Future<NigerianFoodModel> getFoodById(String foodId);

  Future<Map<String, dynamic>> checkFoodDrugInteraction({
    required String medicationName,
    required String foodName,
  });
}

class SupabaseMealDataSourceImpl implements SupabaseMealDataSource {
  final SupabaseClient supabaseClient;

  SupabaseMealDataSourceImpl(this.supabaseClient);

  @override
  Future<List<NigerianFoodModel>> getNigerianFoods({
    String? mealCategory,
    List<String>? conditionFilters,
  }) async {
    try {
      var query = supabaseClient.from('nigerian_foods').select();

      if (mealCategory != null) {
        query = query.eq('meal_category', mealCategory);
      }

      final response = await query;

      return (response as List).map((f) {
        final conditions = (f['suitable_for_conditions'] as String?)
                ?.split(',')
                .map((c) => c.trim())
                .toList() ??
            [];

        return NigerianFoodModel(
          id: f['id'],
          foodName: f['food_name'],
          description: f['description'],
          portionSizeGrams: f['portion_size_grams'],
          caloriesPerPortion:
              double.parse(f['calories_per_portion'].toString()),
          proteinG: double.parse(f['protein_g'].toString()),
          carbsG: double.parse(f['carbs_g'].toString()),
          fatG: double.parse(f['fat_g'].toString()),
          fiberG: double.parse(f['fiber_g'].toString()),
          potassiumMg: f['potassium_mg'],
          sodiumMg: f['sodium_mg'],
          suitableForConditions: conditions,
          mealCategory: f['meal_category'],
          imageUrl: f['image_url'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Get foods error: $e');
    }
  }

  @override
  Future<NigerianFoodModel> getFoodById(String foodId) async {
    try {
      final response = await supabaseClient
          .from('nigerian_foods')
          .select()
          .eq('id', foodId)
          .single();

      final conditions = (response['suitable_for_conditions'] as String?)
              ?.split(',')
              .map((c) => c.trim())
              .toList() ??
          [];

      return NigerianFoodModel(
        id: response['id'],
        foodName: response['food_name'],
        description: response['description'],
        portionSizeGrams: response['portion_size_grams'],
        caloriesPerPortion:
            double.parse(response['calories_per_portion'].toString()),
        proteinG: double.parse(response['protein_g'].toString()),
        carbsG: double.parse(response['carbs_g'].toString()),
        fatG: double.parse(response['fat_g'].toString()),
        fiberG: double.parse(response['fiber_g'].toString()),
        potassiumMg: response['potassium_mg'],
        sodiumMg: response['sodium_mg'],
        suitableForConditions: conditions,
        mealCategory: response['meal_category'],
        imageUrl: response['image_url'],
      );
    } catch (e) {
      throw Exception('Get food error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> checkFoodDrugInteraction({
    required String medicationName,
    required String foodName,
  }) async {
    try {
      final response = await supabaseClient
          .from('food_drug_interactions')
          .select()
          .eq('medication_name', medicationName)
          .eq('food_name', foodName);

      if ((response as List).isNotEmpty) {
        return response.first;
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
