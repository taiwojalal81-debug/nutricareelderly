# Step-by-Step Guide: Riverpod Integration & Real Data

## Overview
The architecture is already in place:
- ✅ **Providers** defined in `lib/presentation/providers/`
- ✅ **Repositories** connected to services in `lib/data/repositories/`
- ✅ **Services** connected to Supabase in `lib/data/services/`

You just need to **connect UI screens to providers**.

---

## Step 1: Understand the Provider Flow

### Available Providers

**Authentication**
```dart
authStateProvider          → Get current logged-in user
loginProvider              → Login with email/password
registerProvider           → Register new user
```

**Weight Tracking**
```dart
latestWeightProvider       → Get latest weight record
weightHistoryProvider      → Get weight history (30 days)
```

**Meals**
```dart
dailyMealPlanProvider      → Get daily meal recommendations
```

**Health**
```dart
userHealthProfileProvider  → Get user's health profile
userConditionsProvider     → Get user's medical conditions
allConditionsProvider      → Get all available conditions
```

---

## Step 2: Convert Screens to ConsumerWidget

### Change from StatelessWidget → ConsumerWidget

**BEFORE**:
```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

**AFTER**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // Now you can access providers via ref.watch()
    // ...
  }
}
```

---

## Step 3: Use Providers in Screens

### Example 1: LoginScreen with Real Auth

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the login provider for state changes
    final loginAsyncValue = ref.watch(
      loginProvider((emailController.text, passwordController.text)),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Icon(Icons.health_and_safety, size: 80, color: AppColors.primary),
                SizedBox(height: 16),
                Text('NutriCare', style: Theme.of(context).textTheme.displaySmall),
                SizedBox(height: 8),
                Text('Your Health, Our Priority', 
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
                SizedBox(height: 48),
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                      return 'Enter valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: passwordController,
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock_outline),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password required';
                    if ((value?.length ?? 0) < 6) {
                      return 'Password must be 6+ characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                
                // REAL LOGIN BUTTON WITH STATE
                loginAsyncValue.when(
                  loading: () => SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: AppButton(
                      label: 'Signing in...',
                      onPressed: () {},
                      isLoading: true,
                    ),
                  ),
                  error: (error, stack) => Column(
                    children: [
                      AppButton(
                        label: 'Sign In',
                        onPressed: _handleLogin,
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Login failed: ${error.toString()}',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                  data: (result) {
                    // Check if login was successful
                    if (result is Success) {
                      // Navigate to home after successful login
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      });
                    }
                    
                    return AppButton(
                      label: 'Sign In',
                      onPressed: _handleLogin,
                    );
                  },
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/register'),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    // Manually trigger the login provider
    ref.read(loginProvider((emailController.text, passwordController.text)));
  }
}
```

---

### Example 2: HomeScreen with Real Health Data

```dart
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers for real data
    final userAsync = ref.watch(authStateProvider);
    final healthAsync = ref.watch(userHealthProfileProvider);
    final latestWeightAsync = ref.watch(latestWeightProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('NutriCare'),
        actions: [
          IconButton(icon: Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Logout logic
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all providers
          ref.invalidate(userHealthProfileProvider);
          ref.invalidate(latestWeightProvider);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // GREETING CARD - Using real user data
                userAsync.when(
                  loading: () => Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CircularProgressIndicator(color: AppColors.white),
                  ),
                  error: (_, __) => Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('Welcome', style: TextStyle(color: AppColors.white, fontSize: 20)),
                  ),
                  data: (user) => Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning, ${user?.firstName ?? 'User'}! 👋',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Let\'s take care of your health today',
                          style: TextStyle(color: AppColors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // HEALTH STATUS CARDS - Using real data
                healthAsync.when(
                  loading: () => GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(4, (_) => 
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                  error: (_, __) => SizedBox.shrink(),
                  data: (health) {
                    if (health == null) return SizedBox.shrink();

                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // BMI Card
                        latestWeightAsync.when(
                          data: (weight) => InfoCard(
                            title: 'BMI',
                            value: weight != null 
                              ? ((weight.weightKg / ((health.height ?? 170) / 100) / ((health.height ?? 170) / 100)).toStringAsFixed(1))
                              : 'N/A',
                            unit: 'kg/m²',
                            icon: Icons.scale,
                            backgroundColor: AppColors.primaryContainer,
                            iconColor: AppColors.primary,
                          ),
                          loading: () => InfoCard(
                            title: 'BMI',
                            value: '...',
                            unit: 'kg/m²',
                            icon: Icons.scale,
                            backgroundColor: AppColors.primaryContainer,
                          ),
                          error: (_, __) => InfoCard(
                            title: 'BMI',
                            value: 'N/A',
                            unit: 'kg/m²',
                            icon: Icons.scale,
                            backgroundColor: AppColors.primaryContainer,
                          ),
                        ),
                        
                        // Blood Pressure Card
                        InfoCard(
                          title: 'Blood Pressure',
                          value: health.bloodPressure ?? 'N/A',
                          unit: 'mmHg',
                          icon: Icons.favorite,
                          backgroundColor: AppColors.errorContainer,
                          iconColor: AppColors.error,
                        ),
                        
                        // Blood Sugar Card
                        InfoCard(
                          title: 'Blood Sugar',
                          value: health.bloodSugar ?? 'N/A',
                          unit: 'mg/dL',
                          icon: Icons.water_drop,
                          backgroundColor: AppColors.secondaryContainer,
                          iconColor: AppColors.secondary,
                        ),
                        
                        // Age Card
                        InfoCard(
                          title: 'Age',
                          value: health.age?.toString() ?? 'N/A',
                          unit: 'years',
                          icon: Icons.person,
                          backgroundColor: AppColors.tertiaryContainer,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24),

                // QUICK ACTIONS - You can add more providers here
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _QuickActionCard('Today\'s Meals', Icons.restaurant, () {
                      Navigator.of(context).pushNamed('/meals');
                    }),
                    _QuickActionCard('Weight Tracker', Icons.scale, () {
                      Navigator.of(context).pushNamed('/weight');
                    }),
                    _QuickActionCard('Health Profile', Icons.health_and_safety, () {
                      // Navigate to profile
                    }),
                    _QuickActionCard('Reports', Icons.bar_chart, () {
                      // Navigate to reports
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Meals'),
          BottomNavigationBarItem(icon: Icon(Icons.scale), label: 'Weight'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.of(context).pushNamed('/meals');
              break;
            case 2:
              Navigator.of(context).pushNamed('/weight');
              break;
            case 3:
              // Navigate to profile
              break;
          }
        },
      ),
    );
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
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
```

---

### Example 3: WeightScreen with Real Weight Data

```dart
class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  late TextEditingController weightController;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController();
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    weightController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch real providers
    final latestWeightAsync = ref.watch(latestWeightProvider);
    final weightHistoryAsync = ref.watch(weightHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Weight Tracker')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CURRENT WEIGHT - Real data
              Text('Current Weight', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 12),
              latestWeightAsync.when(
                loading: () => LoadingWidget(),
                error: (_, __) => ErrorWidget(
                  onRetry: () => ref.invalidate(latestWeightProvider),
                ),
                data: (weight) {
                  if (weight == null) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('No weight data yet. Log your first weight!'),
                    );
                  }

                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${weight.weightKg} kg',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'BMI: ${weight.bmi?.toStringAsFixed(1) ?? "N/A"} kg/m²',
                          style: TextStyle(color: AppColors.white70),
                        ),
                        Text(
                          'Last recorded: ${weight.recordedDate.toString().split(' ')[0]}',
                          style: TextStyle(color: AppColors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 24),

              // LOG NEW WEIGHT FORM
              Text('Log New Weight', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 12),
              CustomTextField(
                label: 'Weight (kg)',
                hint: 'Enter weight in kilograms',
                controller: weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Weight required';
                  if (double.tryParse(value!) == null) return 'Enter valid number';
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'Notes (Optional)',
                hint: 'Add any notes...',
                controller: notesController,
                maxLines: 3,
              ),
              SizedBox(height: 16),
              AppButton(
                label: 'Log Weight',
                onPressed: _logWeight,
              ),
              SizedBox(height: 32),

              // WEIGHT HISTORY - Real data
              Text('Weight History', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 12),
              weightHistoryAsync.when(
                loading: () => LoadingWidget(),
                error: (_, __) => ErrorWidget(
                  onRetry: () => ref.invalidate(weightHistoryProvider),
                ),
                data: (history) {
                  if (history.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.scale,
                      title: 'No History',
                      message: 'Start logging your weight to see trends',
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final record = history[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${record.weightKg} kg',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  record.recordedDate.toString().split(' ')[0],
                                  style: TextStyle(color: AppColors.mediumGrey),
                                ),
                              ],
                            ),
                            Text(
                              'BMI: ${record.bmi?.toStringAsFixed(1) ?? "N/A"}',
                              style: TextStyle(color: AppColors.secondary),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logWeight() async {
    if (weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter weight')),
      );
      return;
    }

    final logWeightUseCase = ref.read(logWeightUseCaseProvider);
    final user = await ref.read(authStateProvider.future);
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not logged in')),
      );
      return;
    }

    final result = await logWeightUseCase.call(
      userId: user.id,
      weightKg: double.parse(weightController.text),
      notes: notesController.text.isNotEmpty ? notesController.text : null,
    );

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Weight logged successfully!')),
        );
        weightController.clear();
        notesController.clear();
        
        // Refresh weight providers
        ref.invalidate(latestWeightProvider);
        ref.invalidate(weightHistoryProvider);
      },
      failure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log weight: ${failure.message}')),
        );
      },
    );
  }
}
```

---

### Example 4: MealsScreen with Real Meal Data

```dart
class MealsScreen extends ConsumerWidget {
  const MealsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real meal provider
    final dailyMealPlanAsync = ref.watch(dailyMealPlanProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Today\'s Meals')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NUTRITION SUMMARY
              dailyMealPlanAsync.when(
                loading: () => Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CircularProgressIndicator(color: AppColors.white),
                ),
                error: (_, __) => Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Error loading meal plan',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
                data: (mealPlan) {
                  if (mealPlan == null) {
                    return EmptyStateWidget(
                      icon: Icons.restaurant,
                      title: 'No Meal Plan',
                      message: 'Unable to generate meal plan. Update your health profile.',
                    );
                  }

                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${mealPlan.totalCalories}',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Calories',
                                  style: TextStyle(color: AppColors.white70),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${mealPlan.protein}g',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Protein',
                                  style: TextStyle(color: AppColors.white70),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${mealPlan.carbs}g',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Carbs',
                                  style: TextStyle(color: AppColors.white70),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${mealPlan.fat}g',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Fat',
                                  style: TextStyle(color: AppColors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Recommended Meals',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 12),
                      // MEAL LIST
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: mealPlan.meals.length,
                        itemBuilder: (context, index) {
                          final meal = mealPlan.meals[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            meal.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            meal.description,
                                            style: TextStyle(
                                              color: AppColors.mediumGrey,
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${meal.calories} cal',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: (meal.tags ?? [])
                                    .map((tag) => Chip(
                                      label: Text(tag, style: TextStyle(fontSize: 11)),
                                      backgroundColor: AppColors.primaryContainer,
                                    ))
                                    .toList(),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        // Show meal details
                                      },
                                      icon: Icon(Icons.info_outline),
                                      label: Text('Details'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Add to meal log
                                      },
                                      icon: Icon(Icons.add),
                                      label: Text('Add'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
}
```

---

## Step 4: Invalidate/Refresh Providers

When data changes, refresh providers:

```dart
// After logging weight
ref.invalidate(latestWeightProvider);
ref.invalidate(weightHistoryProvider);

// After updating health profile
ref.invalidate(userHealthProfileProvider);

// Refresh everything
ref.invalidate(authStateProvider);
ref.invalidate(userHealthProfileProvider);
ref.invalidate(latestWeightProvider);
ref.invalidate(weightHistoryProvider);
ref.invalidate(dailyMealPlanProvider);
```

---

## Step 5: Handle Loading States

Always use `.when()` for async providers:

```dart
asyncProvider.when(
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(
    onRetry: () => ref.invalidate(asyncProvider),
  ),
  data: (data) {
    if (data == null || data.isEmpty) {
      return EmptyStateWidget(...);
    }
    // Display data
  },
)
```

---

## Summary: What to Change

| File | Change | Status |
|------|--------|--------|
| `login_screen.dart` | StatefulWidget → ConsumerStatefulWidget | ✅ Guide above |
| `register_screen.dart` | StatefulWidget → ConsumerStatefulWidget | ✅ Guide above |
| `home_screen.dart` | StatelessWidget → ConsumerWidget | ✅ Guide above |
| `weight_screen.dart` | StatefulWidget → ConsumerStatefulWidget | ✅ Guide above |
| `meals_screen.dart` | StatelessWidget → ConsumerWidget | ✅ Guide above |

---

## Key Imports (Add to All Screen Files)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/presentation/providers/health_provider.dart';
import 'package:nutricare_elderly/presentation/providers/weight_provider.dart';
import 'package:nutricare_elderly/presentation/providers/meal_provider.dart';
```

---

**That's it!** The infrastructure is ready. Just convert screens and use providers to display real data! 🚀
