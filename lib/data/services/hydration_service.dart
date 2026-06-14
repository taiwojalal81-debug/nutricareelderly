// lib/data/services/hydration_service.dart

import 'service_exception.dart';
import 'supabase_service.dart';

class HydrationModel {
  final String id;
  final String userId;
  final DateTime recordedDate;
  final int glassesCount;

  HydrationModel({
    required this.id,
    required this.userId,
    required this.recordedDate,
    required this.glassesCount,
  });

  factory HydrationModel.fromJson(Map<String, dynamic> json) {
    return HydrationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      recordedDate: DateTime.parse(json['recorded_date']),
      glassesCount: json['glasses_count'] ?? 0,
    );
  }
}

class HydrationService {
  final SupabaseService _supabaseService;

  HydrationService(this._supabaseService);

  Future<HydrationModel?> getDailyHydration(String userId, DateTime date) async {
    try {
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      final response = await _supabaseService.client
          .from('hydration_records')
          .select()
          .eq('user_id', userId)
          .eq('recorded_date', dateStr)
          .maybeSingle();

      if (response == null) return null;

      return HydrationModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to get hydration record: $e',
        code: 'GET_HYDRATION_ERROR',
        originalException: e,
      );
    }
  }

  Future<HydrationModel> updateHydration({
    required String userId,
    required DateTime date,
    required int glassesCount,
  }) async {
    try {
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      final response = await _supabaseService.client
          .from('hydration_records')
          .upsert({
            'user_id': userId,
            'recorded_date': dateStr,
            'glasses_count': glassesCount,
          }, onConflict: 'user_id,recorded_date')
          .select()
          .single();

      return HydrationModel.fromJson(response);
    } catch (e) {
      throw ServiceException(
        'Failed to update hydration: $e',
        code: 'UPDATE_HYDRATION_ERROR',
        originalException: e,
      );
    }
  }
}
