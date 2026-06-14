// lib/data/datasources/supabase_weight_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutricare_elderly/data/models/weight_record_model.dart';

abstract class SupabaseWeightDataSource {
  Future<WeightRecordModel> logWeight({
    required String userId,
    required double weightKg,
    String? notes,
  });

  Future<List<WeightRecordModel>> getWeightHistory({
    required String userId,
    required int daysBack,
  });

  Future<WeightRecordModel?> getLatestWeight(String userId);

  Future<void> deleteWeightRecord(String recordId);
}

class SupabaseWeightDataSourceImpl implements SupabaseWeightDataSource {
  final SupabaseClient supabaseClient;

  SupabaseWeightDataSourceImpl(this.supabaseClient);

  @override
  Future<WeightRecordModel> logWeight({
    required String userId,
    required double weightKg,
    String? notes,
  }) async {
    try {
      final response = await supabaseClient.from('weight_records').insert({
        'user_id': userId,
        'weight_kg': weightKg,
        'recorded_date': DateTime.now().toIso8601String(),
        'notes': notes,
      }).select().single();

      return WeightRecordModel(
        id: response['id'],
        userId: userId,
        weightKg: double.parse(response['weight_kg'].toString()),
        recordedDate: DateTime.parse(response['recorded_date']),
        bmi: response['bmi'] != null
            ? double.parse(response['bmi'].toString())
            : null,
        notes: notes,
      );
    } catch (e) {
      throw Exception('Log weight error: $e');
    }
  }

  @override
  Future<List<WeightRecordModel>> getWeightHistory({
    required String userId,
    required int daysBack,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: daysBack));

      final response = await supabaseClient
          .from('weight_records')
          .select()
          .eq('user_id', userId)
          .gte('recorded_date', startDate.toIso8601String())
          .order('recorded_date', ascending: false);

      return (response as List).map((w) => WeightRecordModel(
        id: w['id'],
        userId: userId,
        weightKg: double.parse(w['weight_kg'].toString()),
        recordedDate: DateTime.parse(w['recorded_date']),
        bmi: w['bmi'] != null ? double.parse(w['bmi'].toString()) : null,
        notes: w['notes'],
      )).toList();
    } catch (e) {
      throw Exception('Get weight history error: $e');
    }
  }

  @override
  Future<WeightRecordModel?> getLatestWeight(String userId) async {
    try {
      final response = await supabaseClient
          .from('weight_records')
          .select()
          .eq('user_id', userId)
          .order('recorded_date', ascending: false)
          .limit(1);

      if ((response as List).isNotEmpty) {
        final w = response.first;
        return WeightRecordModel(
          id: w['id'],
          userId: userId,
          weightKg: double.parse(w['weight_kg'].toString()),
          recordedDate: DateTime.parse(w['recorded_date']),
          bmi: w['bmi'] != null ? double.parse(w['bmi'].toString()) : null,
          notes: w['notes'],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteWeightRecord(String recordId) async {
    try {
      await supabaseClient
          .from('weight_records')
          .delete()
          .eq('id', recordId);
    } catch (e) {
      throw Exception('Delete weight record error: $e');
    }
  }
}
