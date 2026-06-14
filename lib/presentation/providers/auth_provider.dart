// lib/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/user_entity.dart';
import 'package:nutricare_elderly/domain/usecases/login_user_usecase.dart';
import 'package:nutricare_elderly/domain/usecases/register_user_usecase.dart';
import 'package:nutricare_elderly/presentation/providers/repository_providers.dart';
import 'package:nutricare_elderly/presentation/providers/supabase_provider.dart';

final loginUserUseCaseProvider = Provider<LoginUserUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUserUseCase(authRepository);
});

final registerUserUseCaseProvider = Provider<RegisterUserUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUserUseCase(authRepository);
});

/// Auth State Notifier to handle Demo and Real users
class AuthStateNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref _ref;

  AuthStateNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final supabase = _ref.read(supabaseClientProvider);
    
    // Listen to real Supabase auth changes
    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session == null) {
        // Only set to null if we aren't currently in "Demo Mode"
        if (state.value?.id != 'demo-user-123') {
          state = const AsyncValue.data(null);
        }
      } else {
        await refreshUser();
      }
    });

    // Initial check
    refreshUser();
  }

  Future<void> refreshUser() async {
    final supabase = _ref.read(supabaseClientProvider);
    final authUser = supabase.auth.currentUser;
    
    if (authUser == null) {
      state = const AsyncValue.data(null);
      return;
    }

    final authRepository = _ref.read(authRepositoryProvider);
    final result = await authRepository.getCurrentUser();
    
    result.when(
      success: (success) {
        if (success.data != null) {
          state = AsyncValue.data(success.data);
        } else {
          // Profile missing but user exists (Social login or interrupted signup)
          state = AsyncValue.data(UserEntity(
            id: authUser.id,
            email: authUser.email ?? '',
            firstName: 'User',
            lastName: '',
            age: 60,
            createdAt: DateTime.now(),
          ));
        }
      },
      failure: (failure) {
        // Fail-safe: Stay logged in as long as the auth session is valid
        state = AsyncValue.data(UserEntity(
          id: authUser.id,
          email: authUser.email ?? '',
          firstName: 'User',
          lastName: '',
          age: 60,
          createdAt: DateTime.now(),
        ));
      },
    );
  }

  void setDemoUser() {
    state = AsyncValue.data(UserEntity(
      id: 'demo-user-123',
      email: 'demo@nutricare.com',
      firstName: 'Demo',
      lastName: 'User',
      age: 70,
      createdAt: DateTime.now(),
    ));
  }

  void logout() {
    _ref.read(authRepositoryProvider).logoutUser();
    state = const AsyncValue.data(null);
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthStateNotifier(ref);
});

/// A FutureProvider that other providers can use to wait for the user to be loaded
final userProvider = FutureProvider<UserEntity?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});

// Login
final loginProvider = FutureProvider.autoDispose
    .family<Result<UserEntity>, (String, String)>((ref, params) async {
  final loginUseCase = ref.watch(loginUserUseCaseProvider);
  final result = await loginUseCase.call(email: params.$1, password: params.$2);
  
  if (result is Success<UserEntity>) {
    if (params.$1 == 'demo@nutricare.com') {
      ref.read(authStateProvider.notifier).setDemoUser();
    } else {
      await ref.read(authStateProvider.notifier).refreshUser();
    }
  }
  return result;
});

// Register
final registerProvider = FutureProvider.autoDispose
    .family<Result<UserEntity>, RegisterParams>((ref, params) async {
  final registerUseCase = ref.watch(registerUserUseCaseProvider);
  final result = await registerUseCase.call(
    email: params.email,
    password: params.password,
    firstName: params.firstName,
    lastName: params.lastName,
    age: params.age,
  );
  if (result is Success<UserEntity>) {
    await ref.read(authStateProvider.notifier).refreshUser();
  }
  return result;
});

// Google Sign In
final googleSignInProvider = FutureProvider.autoDispose<Result<void>>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  final result = await authRepository.signInWithGoogle();
  return result;
});

// Apple Sign In
final appleSignInProvider = FutureProvider.autoDispose<Result<void>>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  final result = await authRepository.signInWithApple();
  return result;
});

class RegisterParams {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final int age;

  RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.age,
  });
}
