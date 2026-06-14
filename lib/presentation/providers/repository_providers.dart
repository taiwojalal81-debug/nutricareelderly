// lib/presentation/providers/repository_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/data/services/auth_service.dart';
import 'package:nutricare_elderly/data/services/health_service.dart';
import 'package:nutricare_elderly/data/services/meal_service.dart';
import 'package:nutricare_elderly/data/services/medication_service.dart';
import 'package:nutricare_elderly/data/services/supabase_service.dart';
import 'package:nutricare_elderly/data/services/weight_service.dart';
import 'package:nutricare_elderly/data/services/hydration_service.dart';
import 'package:nutricare_elderly/data/services/medication_log_service.dart';
import 'package:nutricare_elderly/data/repositories/auth_repository_impl.dart';
import 'package:nutricare_elderly/data/repositories/health_repository_impl.dart';
import 'package:nutricare_elderly/data/repositories/meal_repository_impl.dart';
import 'package:nutricare_elderly/data/repositories/medication_repository_impl.dart';
import 'package:nutricare_elderly/data/repositories/weight_repository_impl.dart';
import 'package:nutricare_elderly/data/repositories/hydration_repository_impl.dart';
import 'package:nutricare_elderly/data/repositories/medication_log_repository_impl.dart';
import 'package:nutricare_elderly/domain/repositories/auth_repository.dart';
import 'package:nutricare_elderly/domain/repositories/health_repository.dart';
import 'package:nutricare_elderly/domain/repositories/meal_repository.dart';
import 'package:nutricare_elderly/domain/repositories/medication_repository.dart';
import 'package:nutricare_elderly/domain/repositories/weight_repository.dart';
import 'package:nutricare_elderly/domain/repositories/hydration_repository.dart';
import 'package:nutricare_elderly/domain/repositories/medication_log_repository.dart';
import 'package:nutricare_elderly/presentation/providers/supabase_provider.dart';

// ==================== Services ====================

/// Core Supabase Service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final supabaseService = SupabaseService();
  supabaseService.setClient(supabaseClient);
  return supabaseService;
});

/// Authentication Service
final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthService(supabaseService);
});

/// Health Service
final healthServiceProvider = Provider<HealthService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return HealthService(supabaseService);
});

/// Medication Service
final medicationServiceProvider = Provider<MedicationService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return MedicationService(supabaseService);
});

/// Meal Service
final mealServiceProvider = Provider<MealService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return MealService(supabaseService);
});

/// Weight Service
final weightServiceProvider = Provider<WeightService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return WeightService(supabaseService);
});

/// Hydration Service
final hydrationServiceProvider = Provider<HydrationService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return HydrationService(supabaseService);
});

/// Medication Log Service
final medicationLogServiceProvider = Provider<MedicationLogService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return MedicationLogService(supabaseService);
});

// ==================== Repositories ====================

/// Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final healthService = ref.watch(healthServiceProvider);
  return AuthRepositoryImpl(authService, healthService);
});

/// Health Repository
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  return HealthRepositoryImpl(healthService);
});

/// Medication Repository
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final medicationService = ref.watch(medicationServiceProvider);
  return MedicationRepositoryImpl(medicationService);
});

/// Meal Repository
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final mealService = ref.watch(mealServiceProvider);
  final healthService = ref.watch(healthServiceProvider);
  final medicationService = ref.watch(medicationServiceProvider);
  return MealRepositoryImpl(
    mealService: mealService,
    healthService: healthService,
    medicationService: medicationService,
  );
});

/// Weight Repository
final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  final weightService = ref.watch(weightServiceProvider);
  return WeightRepositoryImpl(weightService);
});

/// Hydration Repository
final hydrationRepositoryProvider = Provider<HydrationRepository>((ref) {
  final hydrationService = ref.watch(hydrationServiceProvider);
  return HydrationRepositoryImpl(hydrationService);
});

/// Medication Log Repository
final medicationLogRepositoryProvider = Provider<MedicationLogRepository>((ref) {
  final medicationLogService = ref.watch(medicationLogServiceProvider);
  return MedicationLogRepositoryImpl(medicationLogService);
});
