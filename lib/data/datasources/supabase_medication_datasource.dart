// lib/data/datasources/supabase_medication_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutricare_elderly/data/models/medication_model.dart';

abstract class SupabaseMedicationDataSource {
  Future<MedicationModel> addMedication({
    required String userId,
    required String medicationName,
    String? dosage,
    String? frequency,
    String? reason,
  });

  Future<List<MedicationModel>> getUserMedications(String userId);

  Future<void> updateMedication({
    required String medicationId,
    String? dosage,
    String? frequency,
    bool? active,
  });

  Future<void> removeMedication(String medicationId);
}

class SupabaseMedicationDataSourceImpl implements SupabaseMedicationDataSource {
  final SupabaseClient supabaseClient;

  SupabaseMedicationDataSourceImpl(this.supabaseClient);

  @override
  Future<MedicationModel> addMedication({
    required String userId,
    required String medicationName,
    String? dosage,
    String? frequency,
    String? reason,
  }) async {
    try {
      final response = await supabaseClient.from('medications').insert({
        'user_id': userId,
        'medication_name': medicationName,
        'dosage': dosage,
        'frequency': frequency,
        'reason': reason,
        'active': true,
      }).select().single();

      return MedicationModel(
        id: response['id'],
        userId: userId,
        medicationName: medicationName,
        dosage: dosage,
        frequency: frequency,
        reason: reason,
        active: true,
      );
    } catch (e) {
      throw Exception('Add medication error: $e');
    }
  }

  @override
  Future<List<MedicationModel>> getUserMedications(String userId) async {
    try {
      final response = await supabaseClient
          .from('medications')
          .select()
          .eq('user_id', userId)
          .eq('active', true);

      return (response as List).map((m) => MedicationModel(
        id: m['id'],
        userId: userId,
        medicationName: m['medication_name'],
        dosage: m['dosage'],
        frequency: m['frequency'],
        prescribedDate: m['prescribed_date'] != null
            ? DateTime.parse(m['prescribed_date'])
            : null,
        reason: m['reason'],
        active: m['active'] ?? true,
      )).toList();
    } catch (e) {
      throw Exception('Get medications error: $e');
    }
  }

  @override
  Future<void> updateMedication({
    required String medicationId,
    String? dosage,
    String? frequency,
    bool? active,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (dosage != null) updateData['dosage'] = dosage;
      if (frequency != null) updateData['frequency'] = frequency;
      if (active != null) updateData['active'] = active;

      await supabaseClient
          .from('medications')
          .update(updateData)
          .eq('id', medicationId);
    } catch (e) {
      throw Exception('Update medication error: $e');
    }
  }

  @override
  Future<void> removeMedication(String medicationId) async {
    try {
      await supabaseClient
          .from('medications')
          .update({'active': false})
          .eq('id', medicationId);
    } catch (e) {
      throw Exception('Remove medication error: $e');
    }
  }
}
