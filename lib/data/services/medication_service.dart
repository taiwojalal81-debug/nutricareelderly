// lib/data/services/medication_service.dart

import 'service_exception.dart';
import 'supabase_service.dart';

/// Model for medication data
class MedicationModel {
  final String id;
  final String userId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final DateTime? prescribedDate;
  final String? reason;
  final bool active;
  final List<String> reminderTimes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicationModel({
    required this.id,
    required this.userId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    this.prescribedDate,
    this.reason,
    required this.active,
    this.reminderTimes = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      medicationName: json['medication_name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      prescribedDate: json['prescribed_date'] != null
          ? DateTime.parse(json['prescribed_date'])
          : null,
      reason: json['reason'],
      active: json['active'] ?? true,
      reminderTimes: json['reminder_times'] != null 
          ? List<String>.from(json['reminder_times']) 
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

/// Medication service - manages user medications
class MedicationService {
  final SupabaseService _supabaseService;

  MedicationService(this._supabaseService);

  /// Add medication for user
  Future<MedicationModel> addMedication({
    required String userId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required List<String> reminderTimes,
    String? reason,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('medications')
          .insert({
            'user_id': userId,
            'medication_name': medicationName,
            'dosage': dosage,
            'frequency': frequency,
            'reason': reason,
            'active': true,
            'reminder_times': reminderTimes,
          })
          .select()
          .single();

      return MedicationModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to add medication: $e',
        code: 'ADD_MEDICATION_ERROR',
        originalException: e,
      );
    }
  }

  /// Get user's active medications
  Future<List<MedicationModel>> getUserMedications(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('medications')
          .select()
          .eq('user_id', userId)
          .eq('active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => MedicationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServiceException(
        'Failed to get medications: $e',
        code: 'GET_MEDICATIONS_ERROR',
        originalException: e,
      );
    }
  }

  /// Update medication
  Future<MedicationModel> updateMedication({
    required String medicationId,
    String? medicationName,
    String? dosage,
    String? frequency,
    String? reason,
    List<String>? reminderTimes,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (medicationName != null) updateData['medication_name'] = medicationName;
      if (dosage != null) updateData['dosage'] = dosage;
      if (frequency != null) updateData['frequency'] = frequency;
      if (reason != null) updateData['reason'] = reason;
      if (reminderTimes != null) updateData['reminder_times'] = reminderTimes;

      final response = await _supabaseService.client
          .from('medications')
          .update(updateData)
          .eq('id', medicationId)
          .select()
          .single();

      return MedicationModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to update medication: $e',
        code: 'UPDATE_MEDICATION_ERROR',
        originalException: e,
      );
    }
  }

  /// Remove medication (soft delete - sets active to false)
  Future<void> removeMedication(String medicationId) async {
    try {
      await _supabaseService.client
          .from('medications')
          .update({'active': false})
          .eq('id', medicationId);
    } catch (e) {
      throw ServiceException(
        'Failed to remove medication: $e',
        code: 'REMOVE_MEDICATION_ERROR',
        originalException: e,
      );
    }
  }

  /// Get medication by ID
  Future<MedicationModel?> getMedicationById(String medicationId) async {
    try {
      final response = await _supabaseService.client
          .from('medications')
          .select()
          .eq('id', medicationId)
          .maybeSingle();

      if (response == null) return null;

      return MedicationModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to get medication: $e',
        code: 'GET_MEDICATION_ERROR',
        originalException: e,
      );
    }
  }
}
