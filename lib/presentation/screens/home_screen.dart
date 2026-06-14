// lib/presentation/screens/home_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nutricare_elderly/domain/entities/hydration_entity.dart';
import 'package:nutricare_elderly/presentation/providers/repository_providers.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/presentation/providers/health_provider.dart';
import 'package:nutricare_elderly/presentation/providers/weight_provider.dart';
import 'package:nutricare_elderly/presentation/providers/hydration_provider.dart';
import 'package:nutricare_elderly/presentation/providers/meal_provider.dart';
import 'package:nutricare_elderly/presentation/providers/medication_provider.dart';
import 'package:nutricare_elderly/domain/entities/meal_recommendation_entity.dart';
import 'package:nutricare_elderly/domain/entities/medication_entity.dart';
import 'package:nutricare_elderly/domain/entities/medication_log_entity.dart';
import 'package:nutricare_elderly/core/utils/food_details_enricher.dart';
import 'package:nutricare_elderly/presentation/screens/recipe_detail_screen.dart';
import 'package:nutricare_elderly/presentation/screens/profile_screen.dart';
import 'package:nutricare_elderly/presentation/screens/meals_screen.dart';
import 'package:nutricare_elderly/presentation/screens/weight_screen.dart';
import 'package:nutricare_elderly/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The True Navigation Shell
    final screens = [
      _DashboardView(onNavigate: _onTabTapped),
      const MealsScreen(),
      const WeightScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow,
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.primaryContainer,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_outlined),
              selectedIcon: Icon(Icons.restaurant_rounded, color: AppColors.primary),
              label: 'Meals',
            ),
            NavigationDestination(
              icon: Icon(Icons.scale_outlined),
              selectedIcon: Icon(Icons.scale_rounded, color: AppColors.primary),
              label: 'Weight',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends ConsumerWidget {
  final Function(int) onNavigate;

  const _DashboardView({required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final healthAsync = ref.watch(userHealthProfileProvider);
    final latestWeightAsync = ref.watch(latestWeightProvider);
    final hydrationAsync = ref.watch(dailyHydrationProvider);
    final mealsAsync = ref.watch(dailyMealPlanProvider);
    final medicationsAsync = ref.watch(userMedicationsProvider);
    final medicationLogsAsync = ref.watch(medicationLogsProvider(DateTime.now()));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.medication_rounded, color: AppColors.primary, size: 28),
            tooltip: 'Medication Tracker (Pillbox)',
            onPressed: () => Navigator.of(context).pushNamed('/medications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(authStateProvider);
          ref.invalidate(userHealthProfileProvider);
          ref.invalidate(latestWeightProvider);
          ref.invalidate(dailyHydrationProvider);
          ref.invalidate(dailyMealPlanProvider);
          ref.invalidate(userMedicationsProvider);
          ref.invalidate(medicationLogsProvider(DateTime.now()));
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // GREETING CARD (Soft UI)
              userAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
                data: (user) => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning,',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user?.firstName ?? 'User'}! 👋',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                            ? (user.avatarUrl!.startsWith('http')
                                ? NetworkImage(user.avatarUrl!) as ImageProvider
                                : FileImage(File(user.avatarUrl!)) as ImageProvider)
                            : NetworkImage(
                                user?.gender == 'Female'
                                    ? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop'
                                    : 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&auto=format&fit=crop',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // REAL-TIME ACTIVE REMINDERS & SCHEDULE CARD
              _buildRealTimeRemindersCard(
                context,
                ref,
                mealsAsync,
                medicationsAsync,
                medicationLogsAsync,
              ),
              const SizedBox(height: 32),

              // HEALTH STATUS CARDS
              Text(
                'Health Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),
              
              healthAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading health data'),
                data: (health) {
                  if (health == null) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: AppColors.softShadow, blurRadius: 20, offset: Offset(0, 4)),
                        ],
                      ),
                      child: const Text('Please update your profile to see health data.'),
                    );
                  }

                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // BMI Card
                      latestWeightAsync.when(
                        data: (weight) {
                          double? bmi;
                          if (weight != null && health.heightCm > 0) {
                            final heightM = health.heightCm / 100;
                            bmi = weight.weightKg / (heightM * heightM);
                          }
                          return _buildSoftMetricCard(
                            context,
                            title: 'BMI',
                            value: bmi?.toStringAsFixed(1) ?? '--',
                            unit: 'kg/m²',
                            icon: Icons.monitor_weight_rounded,
                            color: AppColors.primary,
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox(),
                      ),

                      // Blood Type
                      _buildSoftMetricCard(
                        context,
                        title: 'Blood Type',
                        value: health.bloodType ?? '--',
                        unit: '',
                        icon: Icons.bloodtype_rounded,
                        color: AppColors.error,
                      ),

                      // Weight
                      latestWeightAsync.when(
                        data: (weight) => _buildSoftMetricCard(
                          context,
                          title: 'Weight',
                          value: weight?.weightKg.toStringAsFixed(1) ?? '--',
                          unit: 'kg',
                          icon: Icons.scale_rounded,
                          color: AppColors.warning,
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox(),
                      ),

                      // Allergies
                      _buildSoftMetricCard(
                        context,
                        title: 'Allergies',
                        value: health.allergies != null && health.allergies!.isNotEmpty ? 'Yes' : 'None',
                        unit: '',
                        icon: Icons.medical_information_rounded,
                        color: AppColors.info,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // HYDRATION CARD
              _buildHydrationCard(context, ref, hydrationAsync),
              const SizedBox(height: 32),

              // QUICK ACTIONS
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      'Meals',
                      Icons.restaurant_rounded,
                      () => onNavigate(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      'Weight',
                      Icons.scale_rounded,
                      () => onNavigate(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      'Pillbox',
                      Icons.medication_rounded,
                      () => Navigator.pushNamed(context, '/medications'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: userAsync.when(
        data: (user) => user?.emergencyContact != null
            ? FloatingActionButton.extended(
                onPressed: () async {
                  final url = Uri.parse('tel:${user!.emergencyContact}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch phone dialer')),
                      );
                    }
                  }
                },
                backgroundColor: AppColors.error,
                elevation: 4,
                icon: const Icon(Icons.sos_rounded, color: AppColors.white, size: 28),
                label: const Text(
                  'EMERGENCY',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildRealTimeRemindersCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DailyMealPlanEntity?> mealsAsync,
    AsyncValue<List<MedicationEntity>> medicationsAsync,
    AsyncValue<List<MedicationLogEntity>> logsAsync,
  ) {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Determine active slot based on time
    String timeSlotTitle = '';
    String mealType = ''; // 'Breakfast', 'Lunch', 'Dinner'
    
    if (hour >= 6 && hour < 12) {
      timeSlotTitle = 'Morning Routine 🌅';
      mealType = 'Breakfast';
    } else if (hour >= 12 && hour < 18) {
      timeSlotTitle = 'Afternoon Routine ☀️';
      mealType = 'Lunch';
    } else {
      timeSlotTitle = 'Evening & Night Routine 🌙';
      mealType = 'Dinner';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: AppColors.softShadow, blurRadius: 24, offset: Offset(0, 8)),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeSlotTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Active Now',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 1. MEAL PORTION
          const Text(
            '🍴 Current Meal Suggestion',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          mealsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())),
            error: (e, _) => const Text('Set up your health profile to view recommendations.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
            data: (mealPlan) {
              if (mealPlan == null) {
                return const Text('Set up your health profile to view recommendations.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary));
              }
              
              final MealEntity activeMeal;
              if (mealType == 'Breakfast') {
                activeMeal = mealPlan.breakfast;
              } else if (mealType == 'Lunch') {
                activeMeal = mealPlan.lunch;
              } else {
                activeMeal = mealPlan.dinner;
              }

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(food: activeMeal.food),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: FoodDetailsEnricher.buildFoodImageWithFallback(
                              activeMeal.food.imageUrl,
                              activeMeal.food.foodName,
                              height: 64,
                              width: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 64,
                                width: 64,
                                color: AppColors.primary.withOpacity(0.1),
                                child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mealType.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeMeal.food.foodName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.bolt_rounded, color: AppColors.warning, size: 14),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${activeMeal.calories.round()} kcal • ${activeMeal.food.portionSizeGrams}g',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: AppColors.softShadow),
          const SizedBox(height: 16),

          // 2. MEDICATIONS PORTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '💊 Scheduled Medications',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/medications'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Open Pillbox'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          medicationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading medications: $e'),
            data: (medications) {
              return logsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (logs) {
                  // Filter medications matching this slot time
                  final slotMeds = <MedicationEntity>[];
                  for (final med in medications) {
                    if (!med.active) continue;
                    
                    if (med.reminderTimes.isEmpty) {
                      if (mealType == 'Dinner') slotMeds.add(med);
                    } else {
                      for (final time in med.reminderTimes) {
                        final parts = time.split(':');
                        final hr = int.tryParse(parts[0]) ?? 0;
                        
                        if (mealType == 'Breakfast' && hr >= 6 && hr < 12) {
                          slotMeds.add(med);
                          break;
                        } else if (mealType == 'Lunch' && hr >= 12 && hr < 18) {
                          slotMeds.add(med);
                          break;
                        } else if (mealType == 'Dinner' && (hr >= 18 || hr < 6)) {
                          slotMeds.add(med);
                          break;
                        }
                      }
                    }
                  }

                  if (slotMeds.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: AppColors.textSecondary.withOpacity(0.6), size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'No medications scheduled for this time slot.',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: slotMeds.map<Widget>((med) {
                      final MedicationEntity currentMed = med;
                      final isTaken = logs.any((l) => l.medicationId == currentMed.id);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isTaken ? AppColors.success.withOpacity(0.3) : AppColors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isTaken ? AppColors.success.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.medication_rounded,
                                  color: isTaken ? AppColors.success : AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentMed.medicationName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        decoration: isTaken ? TextDecoration.lineThrough : null,
                                        color: isTaken ? AppColors.textSecondary : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      currentMed.dosage ?? 'No dosage info',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final repository = ref.read(medicationLogRepositoryProvider);
                                  if (isTaken) {
                                    final result = await repository.deleteMedicationLog(
                                      medicationId: currentMed.id,
                                      date: DateTime.now(),
                                    );
                                    result.when(
                                      success: (_) {
                                        ref.invalidate(medicationLogsProvider(DateTime.now()));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Removed taken log for ${currentMed.medicationName} 🛑'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: AppColors.textSecondary,
                                          ),
                                        );
                                      },
                                      failure: (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to remove log: ${e.userMessage}'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    final result = await repository.logMedication(
                                      medicationId: currentMed.id,
                                      status: 'taken',
                                      takenAt: DateTime.now(),
                                    );
                                    result.when(
                                      success: (_) {
                                        ref.invalidate(medicationLogsProvider(DateTime.now()));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Logged ${currentMed.medicationName} as taken! 💊'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      },
                                      failure: (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to log: ${e.userMessage}'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isTaken ? AppColors.success : AppColors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isTaken ? AppColors.success : AppColors.textSecondary.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    isTaken ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                                    color: isTaken ? AppColors.white : AppColors.textSecondary,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoftMetricCard(BuildContext context, {required String title, required String value, required String unit, required IconData icon, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.softShadow, blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationCard(BuildContext context, WidgetRef ref, AsyncValue<HydrationEntity?> hydrationAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(color: AppColors.softShadow, blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.water_drop_rounded, color: Colors.blue.shade400, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydration',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      'Daily Goal: 8 glasses',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          hydrationAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text('Error loading hydration'),
            data: (hydration) {
              final count = hydration?.glassesCount ?? 0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$count',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ 8',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildHydrationButton(
                        icon: Icons.remove_rounded,
                        onPressed: count > 0 ? () => _updateHydration(ref, count - 1) : null,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 16),
                      _buildHydrationButton(
                        icon: Icons.add_rounded,
                        onPressed: () => _updateHydration(ref, count + 1),
                        color: Colors.blue.shade600,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationButton({required IconData icon, VoidCallback? onPressed, required Color color}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  void _updateHydration(WidgetRef ref, int newCount) async {
    final user = await ref.read(userProvider.future);
    if (user == null) return;

    final repository = ref.read(hydrationRepositoryProvider);
    await repository.updateHydration(
      userId: user.id,
      date: DateTime.now(),
      glassesCount: newCount,
    );
    ref.invalidate(dailyHydrationProvider);
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard(this.title, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: AppColors.softShadow, blurRadius: 20, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
