// lib/presentation/providers/hydration_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/hydration_entity.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/presentation/providers/repository_providers.dart';

final dailyHydrationProvider = FutureProvider<HydrationEntity?>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user == null) return null;

  final repository = ref.watch(hydrationRepositoryProvider);
  final result = await repository.getDailyHydration(user.id, DateTime.now());

  return switch (result) {
    Success(data: final hydration) => hydration,
    Failure() => null,
  };
});

final hydrationUpdateProvider = StateProvider<int>((ref) => 0);
