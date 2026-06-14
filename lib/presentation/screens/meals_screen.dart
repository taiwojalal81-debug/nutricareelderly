// lib/presentation/screens/meals_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/domain/entities/meal_recommendation_entity.dart';
import 'package:nutricare_elderly/presentation/providers/meal_provider.dart';
import 'package:nutricare_elderly/presentation/screens/recipe_detail_screen.dart';
import 'package:nutricare_elderly/theme/app_colors.dart';
import 'package:nutricare_elderly/presentation/widgets/app_button.dart';
import 'package:nutricare_elderly/core/utils/food_details_enricher.dart';
import 'package:nutricare_elderly/domain/entities/nigerian_food_entity.dart';
import 'package:nutricare_elderly/presentation/providers/repository_providers.dart';
import 'package:nutricare_elderly/core/utils/result.dart';

class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> {
  String _selectedMealType = 'All';
  final _mealTypes = ['All', 'Breakfast', 'Lunch', 'Dinner'];
  final _ethnicities = ['All', 'Yoruba', 'Igbo', 'Hausa', 'South-South', 'Foreign'];

  @override
  Widget build(BuildContext context) {
    final dailyMealPlanAsync = ref.watch(dailyMealPlanProvider);
    final selectedEthnicity = ref.watch(selectedEthnicityProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Nutrition & Meals',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyMealPlanProvider);
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ETHNICITY SELECTOR
              _buildSectionTitle(context, '🌍 Culinary Preference'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _ethnicities.map((eth) {
                    final isSelected = selectedEthnicity == eth;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(eth),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(selectedEthnicityProvider.notifier).state = eth;
                          }
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        backgroundColor: AppColors.white,
                        selectedColor: AppColors.primaryContainer,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // MEAL TYPE SELECTOR
              _buildSectionTitle(context, '🍱 Time of Day'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _mealTypes.map((type) {
                    final isSelected = _selectedMealType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedMealType = type);
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        backgroundColor: AppColors.white,
                        selectedColor: AppColors.secondaryContainer,
                        side: BorderSide(
                          color: isSelected ? AppColors.secondary : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // DAILY NUTRITION SUMMARY & MEALS
              dailyMealPlanAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorCard(context, error),
                data: (mealPlan) {
                  if (mealPlan == null) {
                    return _buildEmptyState(context);
                  }

                  final List<MealEntity> allMeals = [mealPlan.breakfast, mealPlan.lunch, mealPlan.dinner];
                  final filteredMeals = _selectedMealType == 'All'
                      ? allMeals
                      : allMeals.where((m) => m.mealType == _selectedMealType).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NUTRITION SUMMARY
                      _buildNutritionSummary(context, mealPlan),
                      const SizedBox(height: 32),

                      // INTERACTION WARNINGS
                      if (mealPlan.warnings.isNotEmpty) ...[
                        _buildSectionTitle(context, '⚠️ Important Safety Advice'),
                        const SizedBox(height: 12),
                        ...mealPlan.warnings.map((w) => _buildWarningCard(context, w)).toList(),
                        const SizedBox(height: 32),
                      ],

                      // ADVICE SECTION
                      _buildSectionTitle(context, '💡 Doctor\'s Notes'),
                      const SizedBox(height: 12),
                      _buildAdviceCard(context, mealPlan.dailyAdvice, mealPlan.bmiAdvice),
                      const SizedBox(height: 32),

                      // MEAL RECOMMENDATIONS
                      _buildSectionTitle(context, '🥘 Recommended Meals'),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredMeals.length,
                        itemBuilder: (context, index) {
                          final meal = filteredMeals[index];
                          return _buildMealCard(context, meal);
                        },
                      ),
                      const SizedBox(height: 32),

                      // EXPLORE ALL ETHNIC RECIPES
                      _buildSectionTitle(context, '📖 Explore All $selectedEthnicity Recipes'),
                      const SizedBox(height: 16),
                      FutureBuilder<Result<List<NigerianFoodEntity>>>(
                        future: ref.read(mealRepositoryProvider).getNigerianFoods(
                          mealCategory: _selectedMealType == 'All' ? null : _selectedMealType,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final result = snapshot.data;
                          if (result == null || result.isFailure) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text('Failed to load alternative meals.'),
                              ),
                            );
                          }
                          
                          var list = result.getOrNull() ?? [];
                          
                          // Filter by selected ethnicity
                          if (selectedEthnicity != 'All') {
                            list = list.where((f) => f.ethnicity == selectedEthnicity).toList();
                          }
                          
                          if (list.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  'No alternative recipes found for this selection.',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final food = list[index];
                              return _buildExploreFoodCard(context, food);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
    );
  }

  Widget _buildNutritionSummary(BuildContext context, DailyMealPlanEntity plan) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calorie Goal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics_rounded, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${plan.totalNutrition.calories.toInt()}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${plan.calorieTarget} kcal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Thick Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              value: plan.totalNutrition.calories / plan.calorieTarget,
              backgroundColor: AppColors.veryLightGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 16, // Massive thickness
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionStat(context, 'Protein', '${plan.totalNutrition.protein.toInt()}g'),
              Container(height: 40, width: 2, color: AppColors.divider),
              _buildNutritionStat(context, 'Carbs', '${plan.totalNutrition.carbs.toInt()}g'),
              Container(height: 40, width: 2, color: AppColors.divider),
              _buildNutritionStat(context, 'Fat', '${plan.totalNutrition.fat.toInt()}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildWarningCard(BuildContext context, DrugFoodInteractionWarningEntity warning) {
    final isCritical = warning.severity >= 3;
    final bgColor = isCritical ? AppColors.error.withOpacity(0.1) : AppColors.warning.withOpacity(0.1);
    final iconColor = isCritical ? AppColors.error : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: iconColor.withOpacity(0.5), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_rounded, color: iconColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning.severityLabel.toUpperCase(),
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                    children: [
                      const TextSpan(text: 'Do not eat '),
                      TextSpan(
                        text: warning.food,
                        style: const TextStyle(fontWeight: FontWeight.w900, decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: ' if you take '),
                      TextSpan(
                        text: warning.medication,
                        style: const TextStyle(fontWeight: FontWeight.w900, decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    warning.recommendation,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(BuildContext context, String daily, String bmi) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdviceRow(context, Icons.medical_services_rounded, daily),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          _buildAdviceRow(context, Icons.monitor_weight_rounded, bmi),
        ],
      ),
    );
  }

  Widget _buildAdviceRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, MealEntity meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Large Visual Header - Gorgeous Food Image!
          Stack(
            children: [
              Hero(
                tag: 'food-img-${meal.food.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: FoodDetailsEnricher.buildFoodImageWithFallback(
                    meal.food.imageUrl,
                    meal.food.foodName,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: meal.mealType == 'Breakfast' ? Colors.orange.shade50 :
                             meal.mealType == 'Lunch' ? Colors.blue.shade50 : Colors.indigo.shade50,
                      child: Center(
                        child: Icon(
                          meal.mealType == 'Breakfast' ? Icons.wb_sunny_rounded :
                          meal.mealType == 'Lunch' ? Icons.light_mode_rounded : Icons.nights_stay_rounded,
                          size: 48,
                          color: meal.mealType == 'Breakfast' ? Colors.orange.shade300 :
                                 meal.mealType == 'Lunch' ? Colors.blue.shade300 : Colors.indigo.shade300,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        meal.mealType == 'Breakfast' ? Icons.wb_sunny_rounded :
                        meal.mealType == 'Lunch' ? Icons.light_mode_rounded : Icons.nights_stay_rounded,
                        size: 20,
                        color: meal.mealType == 'Breakfast' ? Colors.orange.shade600 :
                               meal.mealType == 'Lunch' ? Colors.blue.shade600 : Colors.indigo.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        meal.mealType.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.0,
                          color: meal.mealType == 'Breakfast' ? Colors.orange.shade800 :
                                 meal.mealType == 'Lunch' ? Colors.blue.shade800 : Colors.indigo.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        meal.food.foodName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${meal.calories.toInt()} kcal',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  meal.food.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 24),
                
                // Big Macro Chips
                Row(
                  children: [
                    Expanded(child: _buildMacroChip(context, 'Protein', '${meal.protein.toInt()}g')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMacroChip(context, 'Carbs', '${meal.carbs.toInt()}g')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMacroChip(context, 'Fat', '${meal.fat.toInt()}g')),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Massive Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(food: meal.food),
                            ),
                          );
                        },
                        icon: const Icon(Icons.menu_book_rounded),
                        label: const Text('Recipe'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: const BorderSide(color: AppColors.divider, width: 2),
                          foregroundColor: AppColors.textPrimary,
                          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${meal.food.foodName} added to tracker'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Eat Now'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.veryLightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(color: AppColors.softShadow, blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 64),
          const SizedBox(height: 24),
          const Text(
            'Profile Incomplete',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please complete your health profile to receive personalized meal recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Update Profile',
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          'No meal plan found. Refresh or update your health profile.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildExploreFoodCard(BuildContext context, NigerianFoodEntity food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(food: food),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Visual Food Image Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FoodDetailsEnricher.buildFoodImageWithFallback(
                    food.imageUrl,
                    food.foodName,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      width: 80,
                      color: AppColors.veryLightGrey,
                      child: const Icon(Icons.restaurant_rounded, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.foodName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        food.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Stat chips
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${food.caloriesPerPortion.toInt()} kcal',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${food.proteinG.toInt()}g Pro',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          if (food.ethnicity != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.veryLightGrey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                food.ethnicity!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
