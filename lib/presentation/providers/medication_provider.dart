// lib/presentation/providers/medication_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/core/services/notification_service.dart';
import 'package:nutricare_elderly/domain/entities/medication_entity.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/presentation/providers/repository_providers.dart';
import 'package:nutricare_elderly/domain/entities/medication_log_entity.dart';

final userMedicationsProvider = FutureProvider<List<MedicationEntity>>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user == null) return [];

  final repository = ref.watch(medicationRepositoryProvider);
  final result = await repository.getUserMedications(user.id);

  return result.when(
    success: (s) {
      final medications = s.data;
      // Sync notifications
      _syncNotifications(medications);
      return medications;
    },
    failure: (f) => [],
  );
});

void _syncNotifications(List<MedicationEntity> medications) async {
  final notificationService = NotificationService();
  await notificationService.cancelAllNotifications();

  for (final med in medications) {
    if (!med.active) continue;

    for (int i = 0; i < med.reminderTimes.length; i++) {
      final time = med.reminderTimes[i];
      // Generate a unique ID for each reminder
      final notificationId = med.id.hashCode + i;
      
      await notificationService.scheduleMedicationReminder(
        id: notificationId,
        title: 'Time for your medication: ${med.medicationName}',
        body: 'Dosage: ${med.dosage}',
        time: time,
      );
    }
  }
}

final medicationLogsProvider = FutureProvider.family<List<MedicationLogEntity>, DateTime>((ref, date) async {
  final user = await ref.watch(userProvider.future);
  if (user == null) return [];

  final repository = ref.watch(medicationLogRepositoryProvider);
  final result = await repository.getLogsForDate(user.id, date);

  return result.when(
    success: (s) => s.data,
    failure: (f) => [],
  );
});
