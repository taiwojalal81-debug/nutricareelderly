# NutriCare Elderly - Mobile Dietary Recommendation System

## Overview
Mobile app for elderly users (60+) to receive personalized dietary recommendations based on their health conditions, medications, and BMI.

**Tech Stack:**
- Flutter (Clean Architecture)
- Supabase (PostgreSQL, Auth, RLS)
- Riverpod (State Management)

---

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants
│   └── utils/              # Result type, validators
├── domain/
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business logic use cases
├── data/
│   ├── datasources/        # Supabase datasources
│   ├── models/             # Data models (with JSON serialization)
│   └── repositories/       # Repository implementations
├── presentation/
│   ├── screens/            # UI screens
│   ├── widgets/            # Reusable widgets (elderly-friendly)
│   └── providers/          # Riverpod providers
├── theme/                  # App styling (large text, high contrast)
└── main.dart               # App entry point
```

---

## Features Implemented

### ✅ Authentication
- User registration with age validation
- Email/password login
- Session management

### ✅ Health Management
- Health profile creation (weight, height, BMI)
- Condition selection (Diabetes, Hypertension, Osteoarthritis, Obesity, Hyperlipidemia)
- Medication tracking

### ✅ Meal Recommendations
- Rule-based meal generation
- 3 daily meals (breakfast, lunch, dinner) from Nigerian foods
- Drug-food interaction warnings
- Nutrition breakdowns

### ✅ Weight Tracking
- Log daily weight
- View weight history (30-day)
- BMI trending

### ✅ UI/UX (Elderly-Friendly)
- **Large text** (min 16px body, 24px headlines)
- **High contrast** colors (dark green/blue on white)
- **Simple navigation** (minimal screens)
- **Minimal interactions** (large buttons, clear flows)

---

## Setup Instructions

### 1. Supabase Configuration
**IMPORTANT:** Update these in `lib/core/constants/app_constants.dart`:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Get from: Supabase Dashboard → Settings → API

### 2. Database Setup
1. Copy the entire SQL from `nutricare_schema.sql`
2. Paste into Supabase SQL Editor
3. Execute all statements

### 3. Flutter Setup
```bash
# Get dependencies
flutter pub get

# Generate JSON serialization files
flutter pub run build_runner build

# Run app
flutter run
```

---

## Key Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Dependencies & project config |
| `nutricare_schema.sql` | Complete Supabase database schema |
| `lib/theme/app_theme.dart` | Elderly-friendly styling |
| `lib/presentation/widgets/` | Reusable UI components |
| `lib/domain/usecases/` | Business logic |
| `lib/data/datasources/` | Supabase API integration |

---

## Screens

1. **Splash Screen** - Loading & auth check
2. **Login Screen** - Email/password login
3. **Register Screen** - New user signup
4. **Home Screen** - Daily meals & health summary
5. **Weight Screen** - Log weight & view history
6. Additional screens can be added for medications, conditions setup

---

## Navigation Flow

```
Splash
  ├─ (Authenticated) → Home
  └─ (Not Authenticated) → Login → Register → Home

Home
  ├─ Weight Tracking
  ├─ Medications
  └─ Logout
```

---

## API Integration Points

All data comes from Supabase through:
- `SupabaseAuthDataSource` - Authentication
- `SupabaseHealthDataSource` - Health profiles & conditions
- `SupabaseMedicationDataSource` - Medications
- `SupabaseMealDataSource` - Foods & meals
- `SupabaseWeightDataSource` - Weight records

Riverpod providers handle caching and reactive updates.

---

## Next Steps

- [ ] Create remaining setup screens (health input, conditions, medications)
- [ ] Add medication input flow
- [ ] Implement health profile setup wizard
- [ ] Add offline-first caching with Hive
- [ ] Implement dark mode (optional)
- [ ] Add push notifications for meal reminders
- [ ] Localization (Hausa, Yoruba, etc. for Nigeria)
- [ ] Unit tests
- [ ] Integration tests

---

## Important Notes

1. **Elderly-Friendly Design**: All text sizes ≥16px, buttons ≥60px height
2. **RLS Enabled**: All user data is protected with Row-Level Security
3. **Error Handling**: All operations wrapped in `Result<T>` for safe error messages
4. **State Management**: Riverpod manages all data fetching and caching
5. **Clean Architecture**: Clear separation between layers for maintainability

---

## Support

For issues or questions, refer to:
- Flutter docs: https://flutter.dev
- Supabase docs: https://supabase.com/docs
- Riverpod docs: https://riverpod.dev
