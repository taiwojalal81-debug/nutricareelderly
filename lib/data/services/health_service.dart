// lib/data/services/health_service.dart

import 'service_exception.dart';
import 'supabase_service.dart';

/// Model for health profile data
class HealthProfileModel {
  final String id;
  final String userId;
  final double weightKg;
  final double heightCm;
  final double? bmi;
  final String? bmiCategory;
  final String? bloodType;
  final String? allergies;

  HealthProfileModel({
    required this.id,
    required this.userId,
    required this.weightKg,
    required this.heightCm,
    this.bmi,
    this.bmiCategory,
    this.bloodType,
    this.allergies,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) {
    return HealthProfileModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      weightKg: _parseDouble(json['weight_kg']),
      heightCm: _parseDouble(json['height_cm']),
      bmi: _parseNullableDouble(json['bmi']),
      bmiCategory: json['bmi_category'],
      bloodType: json['blood_type'],
      allergies: json['allergies'],
    );
  }
}

/// Model for condition data
class ConditionModel {
  final String id;
  final String conditionName;
  final String? description;
  final String? dietaryRestrictions;
  final String? nutritionFocus;

  ConditionModel({
    required this.id,
    required this.conditionName,
    this.description,
    this.dietaryRestrictions,
    this.nutritionFocus,
  });

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    return ConditionModel(
      id: json['id'] ?? '',
      conditionName: json['condition_name'] ?? '',
      description: json['description'],
      dietaryRestrictions: json['dietary_restrictions'],
      nutritionFocus: json['nutrition_focus'],
    );
  }
}

/// Model for user conditions (user has these conditions)
class UserConditionModel {
  final String id;
  final String userId;
  final String conditionId;
  final DateTime? diagnosedDate;
  final int? severity;
  final ConditionModel? condition;

  UserConditionModel({
    required this.id,
    required this.userId,
    required this.conditionId,
    this.diagnosedDate,
    this.severity,
    this.condition,
  });

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory UserConditionModel.fromJson(Map<String, dynamic> json) {
    return UserConditionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      conditionId: json['condition_id'] ?? '',
      diagnosedDate: json['diagnosed_date'] != null
          ? DateTime.parse(json['diagnosed_date'])
          : null,
      severity: _parseInt(json['severity']),
      condition: json['conditions'] != null
          ? ConditionModel.fromJson(json['conditions'])
          : null,
    );
  }
}

/// Health service - manages health profiles and conditions
class HealthService {
  final SupabaseService _supabaseService;

  HealthService(this._supabaseService);

  /// Get user's health profile
  Future<HealthProfileModel?> getHealthProfile(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('health_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return HealthProfileModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to get health profile: $e',
        code: 'GET_HEALTH_PROFILE_ERROR',
        originalException: e,
      );
    }
  }

  /// Create health profile
  Future<HealthProfileModel> createHealthProfile({
    required String userId,
    required double weightKg,
    required double heightCm,
    String? bloodType,
    String? allergies,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('health_profiles')
          .upsert({
            'user_id': userId,
            'weight_kg': weightKg,
            'height_cm': heightCm.toInt(),
            'blood_type': bloodType,
            'allergies': allergies,
          }, onConflict: 'user_id')
          .select()
          .single();

      return HealthProfileModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to create health profile: $e',
        code: 'CREATE_HEALTH_PROFILE_ERROR',
        originalException: e,
      );
    }
  }

  /// Update health profile
  Future<HealthProfileModel> updateHealthProfile({
    required String userId,
    required double weightKg,
    required double heightCm,
    String? bloodType,
    String? allergies,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('health_profiles')
          .upsert({
            'user_id': userId,
            'weight_kg': weightKg,
            'height_cm': heightCm.toInt(),
            'blood_type': bloodType,
            'allergies': allergies,
          }, onConflict: 'user_id')
          .select()
          .single();

      return HealthProfileModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to update health profile: $e',
        code: 'UPDATE_HEALTH_PROFILE_ERROR',
        originalException: e,
      );
    }
  }

  /// Get all available conditions
  Future<List<ConditionModel>> getAllConditions() async {
    try {
      final response = await _supabaseService.client
          .from('conditions')
          .select()
          .order('condition_name');

      return (response as List)
          .map((item) => ConditionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServiceException(
        'Failed to get conditions: $e',
        code: 'GET_CONDITIONS_ERROR',
        originalException: e,
      );
    }
  }

  /// Add condition to user
  Future<UserConditionModel> addUserCondition({
    required String userId,
    required String conditionId,
    int? severity,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('user_conditions')
          .insert({
            'user_id': userId,
            'condition_id': conditionId,
            'severity': severity ?? 1,
          })
          .select()
          .single();

      return UserConditionModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to add user condition: $e',
        code: 'ADD_USER_CONDITION_ERROR',
        originalException: e,
      );
    }
  }

  /// Get user's conditions with condition details
  Future<List<UserConditionModel>> getUserConditions(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('user_conditions')
          .select('*, conditions(*)')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => UserConditionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServiceException(
        'Failed to get user conditions: $e',
        code: 'GET_USER_CONDITIONS_ERROR',
        originalException: e,
      );
    }
  }

  /// Remove condition from user
  Future<void> removeUserCondition(String userConditionId) async {
    try {
      await _supabaseService.client
          .from('user_conditions')
          .delete()
          .eq('id', userConditionId);
    } catch (e) {
      throw ServiceException(
        'Failed to remove user condition: $e',
        code: 'REMOVE_USER_CONDITION_ERROR',
        originalException: e,
      );
    }
  }
}
