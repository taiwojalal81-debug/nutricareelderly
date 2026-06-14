# Quick Reference: Riverpod + Real Data

## How to Use Each Screen

### 1️⃣ HomeScreen - Dashboard
**What you see**:
- Real logged-in user greeting
- Real health status cards (BMI, Blood Pressure, Blood Sugar, Age)
- Quick action buttons

**How it works**:
```dart
// Watch providers
final userAsync = ref.watch(authStateProvider);
final healthAsync = ref.watch(userHealthProfileProvider);

// Display with .when()
userAsync.when(
  loading: () => LoadingWidget(),
  error: (e, st) => ErrorWidget(),
  data: (user) => Text('Hello ${user.firstName}')
)
```

**Real data sources**:
- User name from `authStateProvider` (Supabase auth)
- Health profile from `userHealthProfileProvider` (health_profiles table)

---

### 2️⃣ WeightScreen - Track Weight
**What you see**:
- Current weight (from latest record)
- Form to log new weight
- Weight history (last 30 days)

**How it works**:
```dart
// Watch providers
final latestWeightAsync = ref.watch(latestWeightProvider);
final historyAsync = ref.watch(weightHistoryProvider);

// Log weight
await ref.read(logWeightUseCaseProvider).call(
  userId: user.id,
  weightKg: 75.5,
  notes: "Morning weight"
);

// Refresh after logging
ref.invalidate(latestWeightProvider);
ref.invalidate(weightHistoryProvider);
```

**Real data sources**:
- Latest weight from `latestWeightProvider` (weight_records table)
- History from `weightHistoryProvider` (weight_records table, 30 days)
- Saves to `weight_records` table in Supabase

---

### 3️⃣ MealsScreen - Meal Recommendations
**What you see**:
- Daily meal plan with nutrition totals
- Meal type selector (Breakfast, Lunch, Dinner, Snacks)
- List of recommended meals

**How it works**:
```dart
// Watch provider
final mealPlanAsync = ref.watch(dailyMealPlanProvider);

// Display with filter
final filteredMeals = _selectedMealType == 'All'
  ? mealPlan.meals
  : mealPlan.meals.where((m) => m.mealType == _selectedMealType).toList();

// Pull to refresh
ref.invalidate(dailyMealPlanProvider);
```

**Real data sources**:
- Daily meal plan from `dailyMealPlanProvider`
- Pulls from `nigerian_foods` table
- Generates based on user's health profile
- Checks food-drug interactions from `food_drug_interactions` table

---

### 4️⃣ RegisterScreen - Create Account
**What you see**:
- Form with First Name, Last Name, Age, Email, Password, Confirm Password
- Register button

**How it works**:
```dart
// Create params
final params = RegisterParams(
  email: 'user@example.com',
  password: 'password123',
  firstName: 'John',
  lastName: 'Doe',
  age: 65,
);

// Call provider
final result = await ref.read(registerProvider(params).future);

result.when(
  success: (_) => Navigator.pushReplacementNamed('/login'),
  failure: (failure) => showErrorSnackbar(failure.userMessage),
);
```

**Real data sources**:
- Saves to Supabase auth (users)
- Creates profile in `profiles` table
- Can create health profile if provided

---

## Common Patterns

### Pattern 1: Watch & Display Data
```dart
final dataAsync = ref.watch(someProvider);

return dataAsync.when(
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(
    onRetry: () => ref.invalidate(someProvider),
  ),
  data: (data) => {
    if (data == null) return EmptyStateWidget();
    return DisplayData(data);
  },
);
```

### Pattern 2: Call UseCase & Handle Response
```dart
final useCase = ref.read(someUseCaseProvider);
final result = await useCase.call(params);

result.when(
  success: (data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Success!'))
    );
    ref.invalidate(relevantProvider);
  },
  failure: (failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${failure.userMessage}'))
    );
  },
);
```

### Pattern 3: Form with Validation
```dart
final _formKey = GlobalKey<FormState>();
final _controller = TextEditingController();

// In form field
CustomTextField(
  controller: _controller,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Required';
    if (double.tryParse(value!) == null) return 'Invalid number';
    return null;
  },
)

// On submit
void _submit() {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  try {
    // ... do work ...
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### Pattern 4: Refresh Provider
```dart
// Single provider
ref.invalidate(latestWeightProvider);

// Multiple providers
ref.invalidate(authStateProvider);
ref.invalidate(userHealthProfileProvider);
ref.invalidate(latestWeightProvider);
```

---

## Available Providers Reference

### Auth Providers
```dart
authStateProvider              // FutureProvider<UserEntity?>
loginProvider                  // FutureProvider.family<Result<UserEntity>, (String, String)>
registerProvider               // FutureProvider.family<Result<UserEntity>, RegisterParams>
```

### Health Providers
```dart
userHealthProfileProvider      // FutureProvider<HealthProfileEntity?>
userConditionsProvider         // FutureProvider<List<ConditionEntity>>
allConditionsProvider          // FutureProvider<List<ConditionEntity>>
```

### Weight Providers
```dart
latestWeightProvider           // FutureProvider<WeightRecordEntity?>
weightHistoryProvider          // FutureProvider<List<WeightRecordEntity>>
```

### Meal Providers
```dart
dailyMealPlanProvider          // FutureProvider<DailyMealPlanEntity?>
```

### Use Case Providers
```dart
loginUserUseCaseProvider       // Provider<LoginUserUseCase>
registerUserUseCaseProvider    // Provider<RegisterUserUseCase>
logWeightUseCaseProvider       // Provider<LogWeightUseCase>
generateDailyMealsUseCaseProvider // Provider<GenerateDailyMealsUseCase>
```

---

## Required Imports

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/presentation/providers/health_provider.dart';
import 'package:nutricare_elderly/presentation/providers/weight_provider.dart';
import 'package:nutricare_elderly/presentation/providers/meal_provider.dart';
```

---

## Tips for Adding New Features

### 1. Create New Provider
```dart
// In lib/presentation/providers/my_provider.dart
final myDataProvider = FutureProvider<MyEntity>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;
  
  final repository = ref.watch(myRepositoryProvider);
  final result = await repository.getData(user.id);
  
  return result.when(
    success: (success) => success.data,
    failure: (failure) => null,
  );
});
```

### 2. Use in Screen
```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(myDataProvider);
    
    return dataAsync.when(
      loading: () => LoadingWidget(),
      error: (e, st) => ErrorWidget(),
      data: (data) => DisplayData(data),
    );
  }
}
```

### 3. Handle Errors in UI
```dart
// Always use .when() to handle all states
asyncProvider.when(
  loading: () => ...,        // Show spinner
  error: (error, stack) => ...,  // Show error message + retry button
  data: (data) {             // Show actual data
    if (data == null) return EmptyStateWidget();
    if (data.isEmpty) return EmptyStateWidget();
    return DataWidget(data);
  }
)
```

---

## Common Mistakes to Avoid

❌ **Don't**: Access data without `.when()`
```dart
final data = ref.watch(provider); // This is AsyncValue<Data>
Text(data.name);  // ❌ CRASH - AsyncValue doesn't have .name
```

✅ **Do**: Use `.when()` to handle all states
```dart
final dataAsync = ref.watch(provider);
return dataAsync.when(
  loading: () => LoadingWidget(),
  error: (e, st) => ErrorWidget(),
  data: (data) => Text(data.name), // ✅ Now it's safe
);
```

❌ **Don't**: Forget to invalidate after mutations
```dart
await logWeight(75.5);
// UI won't update because provider still has old data
```

✅ **Do**: Invalidate after mutations
```dart
await logWeight(75.5);
ref.invalidate(weightHistoryProvider);
ref.invalidate(latestWeightProvider);
// UI automatically updates ✅
```

❌ **Don't**: Use `.future` unless you know why
```dart
final user = ref.watch(authStateProvider.future); // Only for ONE-TIME fetch
```

✅ **Do**: Use `.watch()` for reactive updates
```dart
final userAsync = ref.watch(authStateProvider); // Updates whenever data changes
userAsync.when(
  data: (user) => ...,
  ...
)
```

---

## Debugging Tips

### 1. Check if Provider is Being Called
Add a breakpoint or print statement in the provider:
```dart
final myProvider = FutureProvider<MyData>((ref) async {
  print('🔵 myProvider called'); // You'll see this in console when provider runs
  final result = await repository.getData();
  print('✅ myProvider returned: $result');
  return result;
});
```

### 2. Check AsyncValue State
```dart
final dataAsync = ref.watch(provider);
print('State: ${dataAsync.value}'); // null, data, or error
print('Error: ${dataAsync.error}'); // Only if error state
```

### 3. Use DevTools
Flutter has built-in Riverpod DevTools:
```bash
# In VS Code, open command palette
> Flutter: Open Devtools Riverpod Inspector
```

### 4. Verify Supabase Calls
Check Supabase dashboard to see if data is actually being written:
1. Open Supabase dashboard
2. Navigate to the table (e.g., `weight_records`)
3. Verify your new records are there ✅

---

## Performance Tips

1. **Use `.autoDispose`** for providers that fetch rarely-needed data:
```dart
final heavyDataProvider = FutureProvider.autoDispose<MyData>((ref) async {
  // This provider will be disposed when no longer watched
  // Saves memory
});
```

2. **Use `.family`** when you need parameterized providers:
```dart
final userDataProvider = FutureProvider.family<UserData, String>((ref, userId) async {
  // Can be called with different userIds
});
```

3. **Invalidate only what changed**:
```dart
ref.invalidate(latestWeightProvider); // Only if weight changed
// Don't invalidate everything unnecessarily
```

---

That's everything you need to know! Happy building! 🚀
