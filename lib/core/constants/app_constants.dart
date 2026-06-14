// lib/core/constants/app_constants.dart

class AppConstants {
  // Condition names
  static const String conditionDiabetes = 'Diabetes Type 2';
  static const String conditionHypertension = 'Hypertension';
  static const String conditionOsteoarthritis = 'Osteoarthritis';
  static const String conditionObesity = 'Obesity';
  static const String conditionHyperlipidemia = 'Hyperlipidemia';

  // BMI Categories
  static const String bmiUnderweight = 'Underweight';
  static const String bmiNormal = 'Normal';
  static const String bmiOverweight = 'Overweight';
  static const String bmiObese = 'Obese';

  // Meal types
  static const String mealBreakfast = 'breakfast';
  static const String mealLunch = 'lunch';
  static const String mealDinner = 'dinner';

  // Interaction severity
  static const int severityMinor = 1;
  static const int severityModerate = 2;
  static const int severitySevere = 3;

  // Calorie targets
  static const int calorieTargetDefault = 2000;
  static const int calorieTargetObesity = 1500;
  static const int calorieTargetDiabetes = 1800;

  // Min/Max nutrients
  static const int minFiberDaily = 25;
  static const int maxSodiumDefault = 2300;
  static const int maxSodiumHypertension = 1500;

  // Age validation
  static const int minAge = 18;
  static const int maxAge = 120;

  // Supabase
  static const String supabaseUrl = 'https://rhqeocinbcsnkqhzgetw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJocWVvY2luYmNzbmtxaHpnZXR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5MzIyNzAsImV4cCI6MjA5MjUwODI3MH0.N3u8vtAIrMPtYqYXKljk9aDjGasbSX54_R8q4V-TAhg';
}
