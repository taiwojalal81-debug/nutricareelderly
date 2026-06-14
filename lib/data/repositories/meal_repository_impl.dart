// lib/data/repositories/meal_repository_impl.dart

import 'dart:math';
import 'package:nutricare_elderly/core/constants/app_constants.dart';
import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/core/utils/food_details_enricher.dart';
import 'package:nutricare_elderly/data/services/health_service.dart';
import 'package:nutricare_elderly/data/services/meal_service.dart';
import 'package:nutricare_elderly/data/services/medication_service.dart';
import 'package:nutricare_elderly/data/services/service_exception.dart';
import 'package:nutricare_elderly/domain/entities/meal_recommendation_entity.dart';
import 'package:nutricare_elderly/domain/entities/nigerian_food_entity.dart';
import 'package:nutricare_elderly/domain/repositories/meal_repository.dart';
import 'package:nutricare_elderly/core/services/local_storage_service.dart';

class MealRepositoryImpl implements MealRepository {
  final MealService mealService;
  final HealthService healthService;
  final MedicationService medicationService;

  MealRepositoryImpl({
    required this.mealService,
    required this.healthService,
    required this.medicationService,
  });

  @override
  Future<Result<DailyMealPlanEntity>> generateDailyMeals({
    required String userId,
    String? ethnicity,
  }) async {
    // DEMO DATA
    if (userId == 'demo-user-123') {
      final mockFood = NigerianFoodEntity(
        id: 'food-1',
        foodName: 'Oatmeal with Bananas',
        description: 'Healthy breakfast',
        caloriesPerPortion: 350,
        portionSizeGrams: 200,
        proteinG: 12,
        carbsG: 50,
        fatG: 8,
        fiberG: 10,
        potassiumMg: 400,
        sodiumMg: 50,
        suitableForConditions: ['Hypertension'],
        mealCategory: 'breakfast',
      );

      final meal = MealEntity(
        mealType: 'breakfast',
        food: mockFood,
        calories: 350,
        protein: 12,
        carbs: 50,
        fat: 8,
      );

      return Success(DailyMealPlanEntity(
        date: DateTime.now(),
        breakfast: meal,
        lunch: meal,
        dinner: meal,
        totalNutrition: NutritionEntity(
          calories: 1050,
          protein: 36,
          carbs: 150,
          fat: 24,
          fiber: 30,
          sodium: 150,
        ),
        warnings: [],
        dailyAdvice: 'Follow a low sodium diet for your hypertension.',
        bmiAdvice: 'Your BMI is healthy.',
        calorieTarget: 2000,
      ));
    }

    try {
      // Get user health profile
      final healthProfile = await healthService.getHealthProfile(userId);
      final userConditions = await healthService.getUserConditions(userId);
      final medications = await medicationService.getUserMedications(userId);

      // Get condition names
      final conditionNames = userConditions
          .where((c) => c.condition != null)
          .map((c) => c.condition!.conditionName)
          .toList();

      // Calculate calorie target
      final calorieTarget = _calculateCalorieTarget(
        conditionNames,
        healthProfile?.bmi ?? 24.0,
      );

      // Seed 150 foods if box is empty or has fewer than 150 items
      await _seedFoodsIfNeeded();

      // Get eligible foods
      List<NigerianFoodEntity> foods = [];
      try {
        final foodModels = await mealService.getNigerianFoods();
        final remoteFoods = foodModels.map((m) => _modelToEntity(m)).toList();
        for (var food in remoteFoods) {
          await LocalStorageService.foodDatabaseBox.put(food.id, food);
        }
        foods = LocalStorageService.foodDatabaseBox.values.toList();
      } catch (e) {
        foods = LocalStorageService.foodDatabaseBox.values.toList();
      }

      // Filter by ethnicity if provided
      if (ethnicity != null && ethnicity != 'All') {
        foods = foods.where((f) => f.ethnicity == ethnicity).toList();
      }
      
      // If no foods match the ethnicity after filtering, fallback to all foods to avoid error
      if (foods.isEmpty) {
        foods = LocalStorageService.foodDatabaseBox.values.toList();
      }

      // Select meals
      final breakfast = await _selectMeal(
        mealType: AppConstants.mealBreakfast,
        eligibleFoods: foods,
        calorieLimit: calorieTarget * 0.25,
        conditionNames: conditionNames,
        mealService: mealService,
      );

      final lunch = await _selectMeal(
        mealType: AppConstants.mealLunch,
        eligibleFoods: foods,
        calorieLimit: calorieTarget * 0.40,
        conditionNames: conditionNames,
        mealService: mealService,
      );

      final dinner = await _selectMeal(
        mealType: AppConstants.mealDinner,
        eligibleFoods: foods,
        calorieLimit: calorieTarget * 0.25,
        conditionNames: conditionNames,
        mealService: mealService,
      );

      // Check interactions
      final warnings = await _checkDrugFoodInteractions(
        medications: medications,
        meals: [breakfast, lunch, dinner],
        mealService: mealService,
      );

      // Calculate total nutrition
      final totalNutrition = _calculateTotalNutrition([breakfast, lunch, dinner]);

      // Generate advice
      final dailyAdvice = _generateDailyAdvice(conditionNames);
      final bmiAdvice = _generateBMIAdvice(healthProfile?.bmi ?? 24.0);

      return Success(DailyMealPlanEntity(
        date: DateTime.now(),
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        totalNutrition: totalNutrition,
        warnings: warnings,
        dailyAdvice: dailyAdvice,
        bmiAdvice: bmiAdvice,
        calorieTarget: calorieTarget,
      ));
    } on ServiceException catch (e) {
      return Failure(e, e.message);
    } on Exception catch (e) {
      return Failure(e, 'Failed to generate meals.');
    }
  }

  @override
  Future<Result<List<NigerianFoodEntity>>> getNigerianFoods({
    String? mealCategory,
    List<String>? conditionFilters,
  }) async {
    try {
      await _seedFoodsIfNeeded();
      
      final models = await mealService.getNigerianFoods(mealCategory: mealCategory);
      final entities = models.map((m) => _modelToEntity(m)).toList();
      for (var food in entities) {
        await LocalStorageService.foodDatabaseBox.put(food.id, food);
      }
      
      var resultList = LocalStorageService.foodDatabaseBox.values.toList();
      if (mealCategory != null && mealCategory != 'All') {
        resultList = resultList.where((f) => f.mealCategory.toLowerCase() == mealCategory.toLowerCase()).toList();
      }
      return Success(resultList);
    } catch (e) {
      await _seedFoodsIfNeeded();
      final cached = LocalStorageService.foodDatabaseBox.values.toList();
      if (mealCategory != null && mealCategory != 'All') {
          cached.retainWhere((f) => f.mealCategory.toLowerCase() == mealCategory.toLowerCase());
      }
      if (cached.isNotEmpty) {
        return Success(cached);
      }
      return Failure(Exception(e), 'Failed to fetch foods.');
    }
  }

  Future<void> _seedFoodsIfNeeded() async {
    final values = LocalStorageService.foodDatabaseBox.values.toList();
    final hasUnsplash = values.any((v) => v.imageUrl != null && v.imageUrl!.contains('unsplash.com'));
    
    if (LocalStorageService.foodDatabaseBox.length < 150 || hasUnsplash) {
      await LocalStorageService.foodDatabaseBox.clear();
      final seededFoods = FoodDetailsEnricher.getSeededFoods();
      for (var food in seededFoods) {
        await LocalStorageService.foodDatabaseBox.put(food.id, food);
      }
    }
  }

  @override
  Future<Result<NigerianFoodEntity>> getFoodById(String foodId) async {
    try {
      final model = await mealService.getFoodById(foodId);
      if (model == null) {
        return Failure(
          Exception('Food not found'),
          'Food not found.',
        );
      }
      return Success(_modelToEntity(model));
    } on ServiceException catch (e) {
      return Failure(e, e.message);
    } on Exception catch (e) {
      return Failure(e, 'Failed to fetch food.');
    }
  }

  @override
  Future<Result<List<DailyMealPlanEntity>>> getMealHistory({
    required String userId,
    required int daysBack,
  }) async {
    // TODO: Implement meal history fetch
    return const Success([]);
  }

  int _calculateCalorieTarget(List<String> conditions, double bmi) {
    if (conditions.contains(AppConstants.conditionObesity) || bmi >= 30) {
      return AppConstants.calorieTargetObesity;
    }
    if (conditions.contains(AppConstants.conditionDiabetes)) {
      return AppConstants.calorieTargetDiabetes;
    }
    return AppConstants.calorieTargetDefault;
  }

  Future<MealEntity> _selectMeal({
    required String mealType,
    required List<NigerianFoodEntity> eligibleFoods,
    required double calorieLimit,
    required List<String> conditionNames,
    required MealService mealService,
  }) async {
    // 1. Try to find foods matching EVERYTHING (Category + Conditions + Calories)
    var filtered = eligibleFoods
        .where((f) => f.mealCategory.toLowerCase() == mealType.toLowerCase())
        .where((f) => _isFoodSuitableForConditions(f, conditionNames))
        .where((f) => f.caloriesPerPortion <= calorieLimit)
        .toList();

    // 2. If none, ignore calorie limit but keep conditions
    if (filtered.isEmpty) {
      filtered = eligibleFoods
          .where((f) => f.mealCategory.toLowerCase() == mealType.toLowerCase())
          .where((f) => _isFoodSuitableForConditions(f, conditionNames))
          .toList();
    }

    // 3. If still none, just match the category (emergency fallback)
    if (filtered.isEmpty) {
      filtered = eligibleFoods
          .where((f) => f.mealCategory.toLowerCase() == mealType.toLowerCase())
          .toList();
    }

    // 4. Final fallback: pick any food if category list is empty
    if (filtered.isEmpty) {
      if (eligibleFoods.isEmpty) throw Exception('The food database is empty. Please run the SQL seed script.');
      filtered = eligibleFoods;
    }

    // Random selection
    final selected = filtered[Random().nextInt(filtered.length)];

    return MealEntity(
      mealType: mealType,
      food: selected,
      calories: selected.caloriesPerPortion,
      protein: selected.proteinG,
      carbs: selected.carbsG,
      fat: selected.fatG,
    );
  }

  bool _isFoodSuitableForConditions(
      NigerianFoodEntity food, List<String> conditions) {
    if (food.suitableForConditions.isEmpty) return true;
    return conditions
        .any((c) => food.suitableForConditions.contains(c));
  }

  Future<List<DrugFoodInteractionWarningEntity>>
      _checkDrugFoodInteractions({
    required List<MedicationModel> medications,
    required List<MealEntity> meals,
    required MealService mealService,
  }) async {
    final List<DrugFoodInteractionWarningEntity> warnings = [];

    for (final med in medications) {
      for (final meal in meals) {
        final interactions = await mealService.checkFoodDrugInteractions(
          medicationName: med.medicationName,
          foodName: meal.food.foodName,
        );

        for (final interaction in interactions) {
          warnings.add(DrugFoodInteractionWarningEntity(
            medication: interaction.medicationName,
            food: interaction.foodName,
            interaction: interaction.description ?? 'No description',
            recommendation: interaction.recommendation ?? 'No recommendation',
            severity: interaction.severity ?? 1,
          ));
        }
      }
    }

    return warnings;
  }

  NutritionEntity _calculateTotalNutrition(List<MealEntity> meals) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    int totalSodium = 0;

    for (final meal in meals) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFat += meal.fat;
      totalFiber += meal.food.fiberG;
      totalSodium += meal.food.sodiumMg;
    }

    return NutritionEntity(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      fiber: totalFiber,
      sodium: totalSodium,
    );
  }

  String _generateDailyAdvice(List<String> conditions) {
    if (conditions.isEmpty) {
      return 'Follow a balanced diet with plenty of vegetables and lean proteins.';
    }

    final primaryCondition = conditions.first;
    switch (primaryCondition) {
      case AppConstants.conditionDiabetes:
        return 'Control blood sugar: eat complex carbs, avoid sugary foods. Eat protein with each meal.';
      case AppConstants.conditionHypertension:
        return 'Follow DASH diet: low salt, high potassium. Eat leafy greens daily.';
      case AppConstants.conditionOsteoarthritis:
        return 'Eat anti-inflammatory foods: fish, greens, avoid fried foods.';
      case AppConstants.conditionObesity:
        return 'Eat smaller portions. Fill half your plate with vegetables. Limit fried foods.';
      case AppConstants.conditionHyperlipidemia:
        return 'Choose lean proteins and whole grains. Eat more fiber.';
      default:
        return 'Maintain a balanced diet with variety.';
    }
  }

  String _generateBMIAdvice(double bmi) {
    if (bmi < 18.5) {
      return 'You are underweight. Eat calorie-dense foods with healthy fats.';
    } else if (bmi < 25) {
      return 'Your weight is healthy. Maintain current nutrition.';
    } else if (bmi < 30) {
      return 'You are overweight. Aim for gradual weight loss of 0.5kg/week.';
    } else {
      return 'Weight loss is important for your health. Aim for 1kg/week.';
    }
  }

  /// Helper method to convert NigerianFoodModel to NigerianFoodEntity
  NigerianFoodEntity _modelToEntity(NigerianFoodModel model) {
    return NigerianFoodEntity(
      id: model.id,
      foodName: model.foodName,
      description: model.description ?? '',
      portionSizeGrams: model.portionSizeGrams ?? 100,
      caloriesPerPortion: model.caloriesPerPortion ?? 0.0,
      proteinG: model.proteinG ?? 0.0,
      carbsG: model.carbsG ?? 0.0,
      fatG: model.fatG ?? 0.0,
      fiberG: model.fiberG ?? 0.0,
      potassiumMg: (model.potassiumMg ?? 0.0).toInt(),
      sodiumMg: (model.sodiumMg ?? 0.0).toInt(),
      suitableForConditions: model.suitableForConditions,
      mealCategory: model.mealCategory ?? '',
      ethnicity: model.ethnicity,
      recipe: model.recipe,
      imageUrl: model.imageUrl,
    );
  }
}
