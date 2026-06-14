// lib/data/services/medication_log_service.dart

import 'service_exception.dart';
import 'supabase_service.dart';

class MedicationLogModel {
  final String id;
  final String medicationId;
  final DateTime takenAt;
  final String status;

  MedicationLogModel({
    required this.id,
    required this.medicationId,
    required this.takenAt,
    required this.status,
  });

  factory MedicationLogModel.fromJson(Map<String, dynamic> json) {
    return MedicationLogModel(
      id: json['id'] ?? '',
      medicationId: json['medication_id'] ?? '',
      takenAt: DateTime.parse(json['taken_at']),
      status: json['status'] ?? 'taken',
    );
  }
}

class MedicationLogService {
  final SupabaseService _supabaseService;

  MedicationLogService(this._supabaseService);

  Future<MedicationLogModel> logMedication({
    required String medicationId,
    required String status,
    DateTime? takenAt,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('medication_logs')
          .insert({
            'medication_id': medicationId,
            'status': status,
            'taken_at': (takenAt ?? DateTime.now()).toIso8601String(),
          })
          .select()
          .single();

      return MedicationLogModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to log medication: $e',
        code: 'LOG_MEDICATION_ERROR',
        originalException: e,
      );
    }
  }

  Future<void> deleteMedicationLog({
    required String medicationId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

      await _supabaseService.client
          .from('medication_logs')
          .delete()
          .eq('medication_id', medicationId)
          .gte('taken_at', startOfDay)
          .lte('taken_at', endOfDay);
    } catch (e) {
      throw ServiceException(
        'Failed to delete medication log: $e',
        code: 'DELETE_MEDICATION_LOG_ERROR',
        originalException: e,
      );
    }
  }

  Future<List<MedicationLogModel>> getLogsForDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

      // Need to join with medications to filter by user_id
      final response = await _supabaseService.client
          .from('medication_logs')
          .select('*, medications!inner(*)')
          .eq('medications.user_id', userId)
          .gte('taken_at', startOfDay)
          .lte('taken_at', endOfDay)
          .order('taken_at', ascending: false);

      return (response as List)
          .map((item) => MedicationLogModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServiceException(
        'Failed to get medication logs: $e',
        code: 'GET_MEDICATION_LOGS_ERROR',
        originalException: e,
      );
    }
  }
}
