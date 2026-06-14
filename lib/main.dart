// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutricare_elderly/core/constants/app_constants.dart';
import 'package:nutricare_elderly/presentation/screens/home_screen.dart';
import 'package:nutricare_elderly/presentation/screens/login_screen.dart';
import 'package:nutricare_elderly/presentation/screens/register_screen.dart';
import 'package:nutricare_elderly/presentation/screens/splash_screen.dart';
import 'package:nutricare_elderly/presentation/screens/weight_screen.dart';
import 'package:nutricare_elderly/presentation/screens/meals_screen.dart';
import 'package:nutricare_elderly/presentation/screens/medications_screen.dart';
import 'package:nutricare_elderly/theme/app_theme.dart';
import 'package:nutricare_elderly/core/services/notification_service.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('Initializing app...');

  // Initialize Local Storage First
  debugPrint('Initializing Local Storage (Hive)...');
  await LocalStorageService.init();

  try {
    // Initialize Notifications
    debugPrint('Initializing Notifications...');
    await NotificationService().init();
    debugPrint('Notifications initialized.');
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }

  debugPrint('Initializing Supabase...');

  await Supabase.initialize(
    url: AppConstants.supabaseUrl.trim(),
    anonKey: AppConstants.supabaseAnonKey.trim(),
  );

  // Connection Test (Non-blocking, runs in the background)
  try {
    debugPrint('Supabase initialized. Testing connection in background...');
    Supabase.instance.client
        .from('conditions')
        .select()
        .limit(1)
        .then((response) {
      debugPrint('Supabase Connection Test: SUCCESS. Data received: $response');
    }).catchError((e) {
      debugPrint('Supabase Connection Test: FAILED. Error: $e');
      debugPrint('Check if you have run the SQL script to create the "conditions" table.');
    });
  } catch (e) {
    debugPrint('Supabase Connection Test Setup Failed: $e');
  }
  runApp(
    const ProviderScope(
      child: NutriCareApp(),
    ),
  );
}

class NutriCareApp extends StatelessWidget {
  const NutriCareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriCare Elderly',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/weight': (context) => const WeightScreen(),
        '/meals': (context) => const MealsScreen(),
        '/medications': (context) => const MedicationsScreen(),
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.map(
      data: (data) {
        final user = data.value;
        if (user != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
      loading: (_) => const SplashScreen(),
      error: (error) {
        debugPrint('Auth Error: ${error.error}');
        return const LoginScreen();
      },
    );
  }
}
