// lib/data/datasources/supabase_health_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutricare_elderly/data/models/health_profile_model.dart';
import 'package:nutricare_elderly/data/models/condition_model.dart';

abstract class SupabaseHealthDataSource {
  Future<HealthProfileModel> createHealthProfile({
    required String userId,
    required double weightKg,
    required int heightCm,
    String? bloodType,
    String? allergies,
  });

  Future<HealthProfileModel> getHealthProfile(String userId);

  Future<HealthProfileModel> updateHealthProfile({
    required String userId,
    required double weightKg,
    required int heightCm,
    String? bloodType,
    String? allergies,
  });

  Future<List<ConditionModel>> getAllConditions();

  Future<void> addUserCondition({
    required String userId,
    required String conditionId,
    String? severity,
  });

  Future<List<ConditionModel>> getUserConditions(String userId);

  Future<void> removeUserCondition({
    required String userId,
    required String conditionId,
  });
}

class SupabaseHealthDataSourceImpl implements SupabaseHealthDataSource {
  final SupabaseClient supabaseClient;

  SupabaseHealthDataSourceImpl(this.supabaseClient);

  @override
  Future<HealthProfileModel> createHealthProfile({
    required String userId,
    required double weightKg,
    required int heightCm,
    String? bloodType,
    String? allergies,
  }) async {
    try {
      final bmi = weightKg / ((heightCm / 100.0) * (heightCm / 100.0));
      final bmiCategory = _calculateBmiCategory(bmi);

      final response = await supabaseClient.from('health_profiles').insert({
        'user_id': userId,
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'blood_type': bloodType,
        'allergies': allergies,
      }).select().single();

      return HealthProfileModel(
        id: response['id'],
        userId: userId,
        weightKg: weightKg,
        heightCm: heightCm,
        bmi: bmi,
        bmiCategory: bmiCategory,
        bloodType: bloodType,
        allergies: allergies,
      );
    } catch (e) {
      throw Exception('Create health profile error: $e');
    }
  }

  @override
  Future<HealthProfileModel> getHealthProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('health_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      return HealthProfileModel(
        id: response['id'],
        userId: userId,
        weightKg: double.parse(response['weight_kg'].toString()),
        heightCm: response['height_cm'],
        bmi: double.parse(response['bmi'].toString()),
        bmiCategory: response['bmi_category'],
        bloodType: response['blood_type'],
        allergies: response['allergies'],
      );
    } catch (e) {
      throw Exception('Get health profile error: $e');
    }
  }

  @override
  Future<HealthProfileModel> updateHealthProfile({
    required String userId,
    required double weightKg,
    required int heightCm,
    String? bloodType,
    String? allergies,
  }) async {
    try {
      final bmi = weightKg / ((heightCm / 100.0) * (heightCm / 100.0));
      final bmiCategory = _calculateBmiCategory(bmi);

      final response = await supabaseClient
          .from('health_profiles')
          .update({
            'weight_kg': weightKg,
            'height_cm': heightCm,
            'blood_type': bloodType,
            'allergies': allergies,
          })
          .eq('user_id', userId)
          .select()
          .single();

      return HealthProfileModel(
        id: response['id'],
        userId: userId,
        weightKg: weightKg,
        heightCm: heightCm,
        bmi: bmi,
        bmiCategory: bmiCategory,
        bloodType: bloodType,
        allergies: allergies,
      );
    } catch (e) {
      throw Exception('Update health profile error: $e');
    }
  }

  @override
  Future<List<ConditionModel>> getAllConditions() async {
    try {
      final response = await supabaseClient.from('conditions').select();
      return (response as List).map((c) => ConditionModel(
        id: c['id'],
        conditionName: c['condition_name'],
        description: c['description'],
        dietaryRestrictions: c['dietary_restrictions'],
        nutritionFocus: c['nutrition_focus'],
      )).toList();
    } catch (e) {
      throw Exception('Get conditions error: $e');
    }
  }

  @override
  Future<void> addUserCondition({
    required String userId,
    required String conditionId,
    String? severity,
  }) async {
    try {
      await supabaseClient.from('user_conditions').insert({
        'user_id': userId,
        'condition_id': conditionId,
        'severity': severity ?? 'moderate',
      });
    } catch (e) {
      throw Exception('Add condition error: $e');
    }
  }

  @override
  Future<List<ConditionModel>> getUserConditions(String userId) async {
    try {
      final response = await supabaseClient
          .from('user_conditions')
          .select('conditions(*)')
          .eq('user_id', userId);

      return (response as List).map((item) {
        final c = item['conditions'];
        return ConditionModel(
          id: c['id'],
          conditionName: c['condition_name'],
          description: c['description'],
          dietaryRestrictions: c['dietary_restrictions'],
          nutritionFocus: c['nutrition_focus'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Get user conditions error: $e');
    }
  }

  @override
  Future<void> removeUserCondition({
    required String userId,
    required String conditionId,
  }) async {
    try {
      await supabaseClient
          .from('user_conditions')
          .delete()
          .eq('user_id', userId)
          .eq('condition_id', conditionId);
    } catch (e) {
      throw Exception('Remove condition error: $e');
    }
  }

  String _calculateBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
