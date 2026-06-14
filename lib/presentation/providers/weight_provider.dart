// lib/presentation/providers/weight_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/domain/entities/weight_record_entity.dart';
import 'package:nutricare_elderly/domain/usecases/log_weight_usecase.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/presentation/providers/repository_providers.dart';

final logWeightUseCaseProvider = Provider<LogWeightUseCase>((ref) {
  final weightRepository = ref.watch(weightRepositoryProvider);
  return LogWeightUseCase(weightRepository);
});

// Get latest weight
final latestWeightProvider =
    FutureProvider<WeightRecordEntity?>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user == null) return null;

  final weightRepository = ref.watch(weightRepositoryProvider);
  final result = await weightRepository.getLatestWeight(user.id);

  return result.when(
    success: (success) => success.data,
    failure: (failure) => null,
  );
});

// Get weight history
final weightHistoryProvider =
    FutureProvider<List<WeightRecordEntity>>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user == null) return [];

  final weightRepository = ref.watch(weightRepositoryProvider);
  final result = await weightRepository.getWeightHistory(
    userId: user.id,
    daysBack: 30,
  );

  return result.when(
    success: (success) => success.data,
    failure: (failure) => [],
  );
});
