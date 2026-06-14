# PHASE 4 - Data Access & Service Layer Refactoring

**Status:** Build errors fixed ✅ | App compiles cleanly ✅ | Ready for Phase 4 refactoring

---

## Overview

Currently, the app has all the infrastructure in place but **needs architectural refinement** to achieve true separation of concerns. This phase focuses on:

1. **Separating external communication** (Supabase) from business logic
2. **Creating clean data flow** between layers
3. **Organizing services, repositories, and logic** properly
4. **Ensuring UI never directly calls Supabase**

---

## Current Architecture (What Exists)

```
┌─── Presentation Layer ────────────────────────┐
│  Screens + Widgets + Riverpod Providers      │
│  (UI knows about Entities & Providers only)  │
└──────────────┬─────────────────────────────────┘
               │
               ↓ (via Riverpod providers)
┌─── Domain Layer ─────────────────────────────┐
│  Entities + Use Cases (Business Logic)       │
└──────────────┬────────────────────────────────┘
               │
               ↓ (via interfaces)
┌─── Data Layer ───────────────────────────────┐
│  Repositories + Datasources (Supabase)       │
│  (Currently: datasources call Supabase       │
│   directly without abstraction)              │
└──────────────┬────────────────────────────────┘
               │
               ↓
┌─── External Layer ───────────────────────────┐
│  Supabase API Calls                          │
└──────────────────────────────────────────────┘
```

---

## Target Architecture (After Phase 4)

```
┌─── Presentation Layer ────────────────────────┐
│  Screens + Widgets (Riverpod)                │
└──────────────┬────────────────────────────────┘
               │
               ↓
┌─── Domain Layer ─────────────────────────────┐
│  Entities + Use Cases                        │
└──────────────┬────────────────────────────────┘
               │
               ↓
┌─── Data Layer ───────────────────────────────┐
│  Repositories (Business Data Handling)       │
│  - Orchestrate services                      │
│  - Convert models ↔ entities                 │
│  - Handle data transformation                │
└──────────────┬────────────────────────────────┘
               │
    ┌──────────┴──────────┬────────────┐
    ↓                      ↓            ↓
┌─Service Layer─┐  ┌─Logic Layer─┐  ┌─Local─┐
│  SupabaseService   │ Recommendation│ Storage
│  AuthService       │ Engine        │
│  HealthService     │              │
└─────────────┘  └─────────────┘  └──────┘
    │
    ↓
┌─External Layer────────────────────────────┐
│  Supabase API (Hidden behind Services)    │
└────────────────────────────────────────────┘
```

---

## Layer Responsibilities

### 1. **Service Layer** (NEW)
**Purpose:** Handle external communication (Supabase API calls)

```
lib/data/services/
├── supabase_service.dart       ← Supabase initialization & raw queries
├── auth_service.dart           ← Auth operations (signup, signin, logout)
├── health_service.dart         ← Health profile CRUD
├── medication_service.dart     ← Medication CRUD
├── meal_service.dart           ← Food database queries
└── weight_service.dart         ← Weight logging
```

**Responsibility:**
- Initialize Supabase client
- Execute queries (SELECT, INSERT, UPDATE, DELETE)
- Throw exceptions on Supabase errors
- Return raw data (JSON-like DTOs, not entities)

**Example:**
```dart
// supabase_service.dart
class SupabaseService {
  late SupabaseClient _client;
  
  Future<void> initialize(String url, String key) async {
    _client = SupabaseClient(url, key);
  }
  
  SupabaseClient get client => _client;
}

// auth_service.dart
class AuthService {
  final SupabaseService _supabaseService;
  
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      return {'user_id': response.user!.id};
    } on AuthException catch (e) {
      throw ServiceException('Signup failed: ${e.message}');
    }
  }
}
```

---

### 2. **Repository Layer** (REFACTORED)
**Purpose:** Handle data transformation and business logic orchestration

```
lib/data/repositories/
├── auth_repository_impl.dart
├── health_repository_impl.dart
├── medication_repository_impl.dart
├── meal_repository_impl.dart
└── weight_repository_impl.dart
```

**Responsibility:**
- Use services to fetch raw data
- Convert raw data → domain entities
- Handle data validation & transformation
- Wrap errors in Result<T>
- Orchestrate multiple services if needed

**Example:**
```dart
// auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final HealthService _healthService;
  
  @override
  Future<Result<UserEntity>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    try {
      // 1. Call service to signup user
      final signupData = await _authService.signUp(
        email: email,
        password: password,
      );
      
      // 2. Create user profile
      final profileData = await _healthService.createProfile(
        userId: signupData['user_id'],
        firstName: firstName,
        lastName: lastName,
        age: age,
      );
      
      // 3. Convert to entity
      final user = UserEntity(
        id: signupData['user_id'],
        email: email,
        firstName: firstName,
        lastName: lastName,
        age: age,
        createdAt: DateTime.now(),
      );
      
      return Success(user);
    } on ServiceException catch (e) {
      return Failure(
        e,
        'Registration failed. Please try again.',
      );
    } catch (e) {
      return Failure(
        Exception(e),
        'Unexpected error occurred.',
      );
    }
  }
}
```

---

### 3. **Logic Layer** (REFACTORED)
**Purpose:** Pure business logic, no external calls

```
lib/domain/logic/
├── recommendation_engine.dart  ← Meal recommendation algorithm
├── validation_engine.dart      ← Input validation rules
└── calculation_engine.dart     ← BMI, calorie calculations
```

**Responsibility:**
- Accept structured input data
- Perform calculations/algorithms
- Return structured output
- No Supabase calls
- No repository calls
- Deterministic (same input = same output)

**Example:**
```dart
// recommendation_engine.dart
class RecommendationEngine {
  // Pure logic - no external calls
  DailyMealPlanEntity generateMealPlan({
    required HealthProfileEntity health,
    required List<ConditionEntity> conditions,
    required List<MedicationEntity> medications,
    required List<NigerianFoodEntity> foods,
  }) {
    // 1. Calculate calorie target (pure logic)
    final calorieTarget = _calculateCalorieTarget(health, conditions);
    
    // 2. Select meals (pure logic with random selection)
    final breakfast = _selectMeal(
      foods: foods,
      mealType: 'breakfast',
      conditions: conditions,
      medications: medications,
      calorieLimit: calorieTarget * 0.25,
    );
    
    // 3. Validate combinations (pure logic)
    final warnings = _validateFoodDrugInteractions(
      foods: [breakfast.food],
      medications: medications,
    );
    
    // 4. Generate advice (pure logic)
    final advice = _generateAdvice(conditions, health);
    
    return DailyMealPlanEntity(
      meals: [breakfast, lunch, dinner],
      warnings: warnings,
      advice: advice,
    );
  }
  
  // Pure calculations
  int _calculateCalorieTarget(
    HealthProfileEntity health,
    List<ConditionEntity> conditions,
  ) {
    if (conditions.any((c) => c.name == 'Obesity') || health.bmi >= 30) {
      return 1500; // Caloric deficit
    }
    if (conditions.any((c) => c.name == 'Diabetes')) {
      return 1800;
    }
    return 2000; // Default
  }
}
```

---

## Implementation Steps

### Step 1: Create Service Layer

Create `lib/data/services/` directory with:

```dart
// lib/data/services/supabase_service.dart
class SupabaseService {
  late SupabaseClient _client;
  
  Future<void> initialize(String url, String key) async {
    _client = SupabaseClient(url, key);
  }
  
  SupabaseClient get client => _client;
}

// Exception wrapper
class ServiceException implements Exception {
  final String message;
  ServiceException(this.message);
  
  @override
  String toString() => message;
}
```

```dart
// lib/data/services/auth_service.dart
class AuthService {
  final SupabaseService _supabaseService;
  AuthService(this._supabaseService);
  
  Future<AuthResponseModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      
      return AuthResponseModel(
        userId: response.user!.id,
        email: response.user!.email ?? '',
      );
    } catch (e) {
      throw ServiceException('Auth error: $e');
    }
  }
}
```

### Step 2: Refactor Repositories

Repositories now become **orchestrators** instead of datasources:

```dart
// OLD (Current) - Datasources call Supabase
// lib/data/datasources/supabase_auth_datasource.dart
class SupabaseAuthDataSource {
  final SupabaseClient _client;
  Future<UserModel> registerUser(...) async {
    final response = await _client.auth.signUp(...);
    // Direct Supabase call
  }
}

// NEW (After refactoring) - Repositories use Services
// lib/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final HealthService _healthService;
  
  Future<Result<UserEntity>> registerUser(...) async {
    final authData = await _authService.signUp(...);
    final profileData = await _healthService.createProfile(...);
    final user = _convertToEntity(authData, profileData);
    return Success(user);
  }
}
```

### Step 3: Keep Logic Layer Pure

No changes needed - it's already independent!

```dart
// lib/domain/logic/recommendation_engine.dart
// Already free of external calls
```

### Step 4: Update Providers (Minimal Changes)

```dart
// lib/presentation/providers/repository_providers.dart
// Services are injected into repositories

final supabaseServiceProvider = Provider((ref) {
  return SupabaseService();
});

final authServiceProvider = Provider((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthService(supabaseService);
});

final authRepositoryProvider = Provider((ref) {
  final authService = ref.watch(authServiceProvider);
  final healthService = ref.watch(healthServiceProvider);
  return AuthRepositoryImpl(authService, healthService);
});
```

---

## Data Flow Example: User Registration

### Current Flow (Mixed concerns):
```
RegisterScreen
   ↓ (calls provider)
registerProvider
   ↓ (uses usecase)
RegisterUserUseCase
   ↓ (calls repository)
AuthRepositoryImpl
   ↓ (calls datasource)
SupabaseAuthDataSource
   ↓ (calls Supabase directly)
await _client.auth.signUp()
```

### After Phase 4 (Clean separation):
```
RegisterScreen
   ↓ (calls provider)
registerProvider
   ↓ (uses usecase)
RegisterUserUseCase
   ↓ (calls repository)
AuthRepositoryImpl
   ├─ calls AuthService (External communication)
   ├─ calls HealthService (External communication)
   ├─ calls RecommendationEngine (Pure logic)
   └─ converts to UserEntity (Data transformation)
      ↓
      Returns Success<UserEntity> with Result wrapper
         ↓
         UI displays result
```

**Benefits:**
- ✅ Services isolated: Can swap Supabase for Firebase/REST easily
- ✅ Repositories orchestrate: Can combine multiple services
- ✅ Logic pure: Can test algorithms without external dependencies
- ✅ UI clean: Only knows about entities and providers
- ✅ Error handling: Centralized in repositories

---

## File Structure (Target)

```
lib/
├── core/
│   ├── constants/
│   └── utils/
│       └── result.dart          ← Error handling
├── domain/
│   ├── entities/                ← Business models
│   ├── logic/                   ← NEW: Pure business logic
│   │   ├── recommendation_engine.dart
│   │   └── calculation_engine.dart
│   ├── repositories/            ← Interfaces only
│   └── usecases/                ← Business operations
├── data/
│   ├── models/                  ← DTOs (Data Transfer Objects)
│   ├── services/                ← NEW: External communication
│   │   ├── supabase_service.dart
│   │   ├── auth_service.dart
│   │   ├── health_service.dart
│   │   ├── medication_service.dart
│   │   ├── meal_service.dart
│   │   └── weight_service.dart
│   ├── datasources/             ← DEPRECATED (to be removed)
│   └── repositories/            ← Implementations (orchestrators)
│       ├── auth_repository_impl.dart
│       ├── health_repository_impl.dart
│       ├── medication_repository_impl.dart
│       ├── meal_repository_impl.dart
│       └── weight_repository_impl.dart
└── presentation/
    ├── screens/
    ├── widgets/
    └── providers/
```

---

## Key Principles

### 1. **Dependency Direction** (Always downward)
```
UI → Providers → Use Cases → Repositories → Services → Supabase
       ↑                          ↑                ↑
     Never upward            Never upward   Never cross-layer
```

### 2. **Data Conversion**
```
Supabase (raw JSON)
   ↓ (Service receives)
Service (JSON) → Model (DTO)
   ↓ (Repository receives)
Repository (Model) → Entity (Domain model)
   ↓ (Use Case receives)
Use Case (Entity)
   ↓ (Provider/UI receives)
UI (Entity only)
```

### 3. **Error Handling**
```
Service:     Throw ServiceException
Repository: Catch ServiceException → Wrap in Result<T>
Use Case:    Return Result<T> unchanged
Provider:    Use result.when() in UI
UI:          Display userMessage
```

### 4. **Testing**
```
Services:      Mock Supabase responses (white-box testing)
Repositories:  Mock Services + verify orchestration
Use Cases:     Mock Repositories + verify business logic
Logic:         Pure input/output testing (no mocks)
Providers:     Mock Use Cases + verify state updates
UI:            Widget tests with mocked providers
```

---

## Why This Matters

### Without Clean Architecture:
❌ UI knows about Supabase  
❌ Business logic mixed with API calls  
❌ Hard to test (everything depends on real Supabase)  
❌ Hard to swap backends (tied to Supabase)  
❌ Error handling scattered everywhere  

### With Clean Architecture:
✅ UI only knows about entities  
✅ Business logic separate from communication  
✅ Easy to unit test (mock services)  
✅ Can swap backends easily (new service layer)  
✅ Centralized error handling  
✅ Each layer has single responsibility  

---

## Next: Hands-On Implementation

When ready, we will:

1. Create `lib/data/services/` with 6 service files
2. Create `lib/domain/logic/` with recommendation engine
3. Refactor all repositories to use services (not datasources)
4. Update providers to inject services
5. Verify all tests pass
6. Update datasources to deprecated status (keep for reference)

**This ensures the app is production-ready, testable, and maintainable.**

---

## Summary

**Phase 4 transforms the app from:**
- "A working prototype" → "A professional, maintainable codebase"

**By implementing:**
- Clean separation of concerns
- Proper dependency injection
- Centralized error handling
- Pure business logic
- Testable architecture

**Result:**
- App is production-ready
- Easy to onboard new developers
- Easy to add features
- Easy to test
- Easy to maintain

---

Let's start implementation when you're ready! 🚀
