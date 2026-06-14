// lib/data/services/weight_service.dart

import 'service_exception.dart';
import 'supabase_service.dart';

/// Model for weight record data
class WeightRecordModel {
  final String id;
  final String userId;
  final double weightKg;
  final DateTime recordedDate;
  final double? bmi;
  final String? notes;

  WeightRecordModel({
    required this.id,
    required this.userId,
    required this.weightKg,
    required this.recordedDate,
    this.bmi,
    this.notes,
  });

  factory WeightRecordModel.fromJson(Map<String, dynamic> json) {
    return WeightRecordModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      recordedDate: DateTime.parse(json['recorded_date'] ?? ''),
      bmi: (json['bmi'] as num?)?.toDouble(),
      notes: json['notes'],
    );
  }
}

/// Weight service - manages weight tracking and history
class WeightService {
  final SupabaseService _supabaseService;

  WeightService(this._supabaseService);

  /// Log weight entry
  Future<WeightRecordModel> logWeight({
    required String userId,
    required double weightKg,
    String? notes,
  }) async {
    try {
      final today = DateTime.now();
      final recordedDate =
          DateTime(today.year, today.month, today.day).toIso8601String();

      final response = await _supabaseService.client
          .from('weight_records')
          .insert({
            'user_id': userId,
            'weight_kg': weightKg,
            'recorded_date': recordedDate,
            'notes': notes,
          })
          .select()
          .single();

      return WeightRecordModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to log weight: $e',
        code: 'LOG_WEIGHT_ERROR',
        originalException: e,
      );
    }
  }

  /// Get latest weight record
  Future<WeightRecordModel?> getLatestWeight(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('weight_records')
          .select()
          .eq('user_id', userId)
          .order('recorded_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return WeightRecordModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to get latest weight: $e',
        code: 'GET_LATEST_WEIGHT_ERROR',
        originalException: e,
      );
    }
  }

  /// Get weight history for a date range
  Future<List<WeightRecordModel>> getWeightHistory({
    required String userId,
    int daysBack = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
      final cutoffDateStr = DateTime(
        cutoffDate.year,
        cutoffDate.month,
        cutoffDate.day,
      ).toIso8601String();

      final response = await _supabaseService.client
          .from('weight_records')
          .select()
          .eq('user_id', userId)
          .gte('recorded_date', cutoffDateStr)
          .order('recorded_date', ascending: false);

      return (response as List)
          .map((item) =>
              WeightRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServiceException(
        'Failed to get weight history: $e',
        code: 'GET_WEIGHT_HISTORY_ERROR',
        originalException: e,
      );
    }
  }

  /// Delete weight record
  Future<void> deleteWeightRecord(String recordId) async {
    try {
      await _supabaseService.client
          .from('weight_records')
          .delete()
          .eq('id', recordId);
    } catch (e) {
      throw ServiceException(
        'Failed to delete weight record: $e',
        code: 'DELETE_WEIGHT_ERROR',
        originalException: e,
      );
    }
  }

  /// Update weight record notes
  Future<WeightRecordModel> updateWeightNotes({
    required String recordId,
    required String notes,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('weight_records')
          .update({'notes': notes})
          .eq('id', recordId)
          .select()
          .single();

      return WeightRecordModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to update weight notes: $e',
        code: 'UPDATE_WEIGHT_NOTES_ERROR',
        originalException: e,
      );
    }
  }
}
