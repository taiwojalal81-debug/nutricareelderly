// lib/data/repositories/auth_repository_impl.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/data/services/auth_service.dart';
import 'package:nutricare_elderly/data/services/health_service.dart';
import 'package:nutricare_elderly/data/services/service_exception.dart';
import 'package:nutricare_elderly/domain/entities/user_entity.dart';
import 'package:nutricare_elderly/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final HealthService healthService;

  AuthRepositoryImpl(
    this.authService,
    this.healthService,
  );

  /// DEFAULT TEST ACCOUNT
  static const String demoEmail = 'demo@nutricare.com';
  static const String demoPassword = '123456';
  static const String demoUserId = 'demo-user-123';

  @override
  Future<Result<UserEntity>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    try {
      // Sign up user
      final authResponse = await authService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        age: age,
      );

      // We don't need to call createProfile manually anymore 
      // because the DB trigger handles it using the 'data' we passed above.
      // However, we call it with 'upsert' just in case.
      await authService.createProfile(
        userId: authResponse.userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        age: age,
      );

      // Return user entity
      final user = UserEntity(
        id: authResponse.userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        age: age,
        createdAt: DateTime.now(),
      );

      return Success(user);
    } on ServiceException catch (e) {
      print('Registration failed: ${e.message} (${e.code})');
      return Failure(e, 'Registration failed: ${e.message}');
    } catch (e) {
      print('Unexpected registration error: $e');
      return Failure(
        Exception(e),
        'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<Result<UserEntity>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Check for Demo Account
      if (email == demoEmail && password == demoPassword) {
        final now = DateTime.now();
        return Success(UserEntity(
          id: demoUserId,
          email: demoEmail,
          firstName: 'Demo',
          lastName: 'User',
          age: 70,
          createdAt: now,
        ));
      }

      // 2. Real Login
      final authResponse = await authService.signIn(
        email: email,
        password: password,
      );

      // Fetch user profile
      final profile = await authService.getCurrentUser();

      if (profile == null) {
        return Failure(
          Exception('User profile not found'),
          'Login failed. User profile not found.',
        );
      }

      // Return user entity
      final user = UserEntity(
        id: authResponse.userId,
        email: email,
        firstName: profile.firstName ?? '',
        lastName: profile.lastName ?? '',
        age: profile.age ?? 0,
        phone: profile.phone,
        gender: profile.gender,
        emergencyContact: profile.emergencyContact,
        createdAt: profile.createdAt ?? DateTime.now(),
      );

      return Success(user);
    } on ServiceException catch (e) {
      return Failure(e, 'Login failed: ${e.message}');
    } catch (e) {
      return Failure(
        Exception(e),
        'An unexpected error occurred during login.',
      );
    }
  }

  @override
  Future<Result<void>> logoutUser() async {
    try {
      await authService.signOut();
      return const Success(null);
    } on ServiceException catch (e) {
      return Failure(e, 'Logout failed.');
    } catch (e) {
      return Failure(Exception(e), 'Logout failed.');
    }
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      await authService.signInWithGoogle();
      return const Success(null);
    } on ServiceException catch (e) {
      return Failure(e, 'Google login failed: ${e.message}');
    } catch (e) {
      return Failure(Exception(e), 'Google login failed.');
    }
  }

  @override
  Future<Result<void>> signInWithApple() async {
    try {
      await authService.signInWithApple();
      return const Success(null);
    } on ServiceException catch (e) {
      return Failure(e, 'Apple login failed: ${e.message}');
    } catch (e) {
      return Failure(Exception(e), 'Apple login failed.');
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final profile = await authService.getCurrentUser();

      if (profile == null) {
        return const Success(null);
      }

      return Success(UserEntity(
        id: profile.userId,
        email: profile.email,
        firstName: profile.firstName ?? '',
        lastName: profile.lastName ?? '',
        age: profile.age ?? 0,
        phone: profile.phone,
        gender: profile.gender,
        emergencyContact: profile.emergencyContact,
        avatarUrl: profile.avatarUrl,
        createdAt: profile.createdAt ?? DateTime.now(),
      ));
    } catch (e) {
      return Failure(Exception(e), 'Failed to fetch user.');
    }
  }

  @override
  Future<Result<UserEntity>> updateUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required int age,
    String? phone,
    String? gender,
    String? emergencyContact,
    String? avatarUrl,
  }) async {
    try {
      final profile = await authService.updateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        age: age,
        phone: phone,
        gender: gender,
        emergencyContact: emergencyContact,
        avatarUrl: avatarUrl,
      );

      return Success(UserEntity(
        id: profile.userId,
        email: profile.email,
        firstName: profile.firstName ?? '',
        lastName: profile.lastName ?? '',
        age: profile.age ?? 0,
        phone: profile.phone,
        gender: profile.gender,
        emergencyContact: profile.emergencyContact,
        avatarUrl: profile.avatarUrl,
        createdAt: profile.createdAt ?? DateTime.now(),
      ));
    } catch (e) {
      return Failure(Exception(e), 'Failed to update profile.');
    }
  }

  @override
  Future<Result<UserEntity>> uploadAvatar({
    required String userId,
    required String imagePath,
  }) async {
    try {
      String publicUrl = '';

      if (userId == 'demo-user-123') {
        // Fallback for demo user
        publicUrl = imagePath;
      } else {
        // 1. Read file bytes
        final file = File(imagePath);
        final fileBytes = await file.readAsBytes();
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.png';

        // 2. Upload to Supabase Storage
        final supabaseClient = supabase_flutter.Supabase.instance.client;
        
        await supabaseClient.storage.from('avatars').uploadBinary(
          fileName,
          fileBytes,
          fileOptions: const supabase_flutter.FileOptions(
            upsert: true,
            contentType: 'image/png',
          ),
        );

        // 3. Get Public URL
        publicUrl = supabaseClient.storage.from('avatars').getPublicUrl(fileName);
      }

      // 4. Update avatar URL in profiles
      final profile = await authService.updateAvatarUrl(
        userId: userId,
        avatarUrl: publicUrl,
      );

      return Success(UserEntity(
        id: profile.userId,
        email: profile.email,
        firstName: profile.firstName ?? '',
        lastName: profile.lastName ?? '',
        age: profile.age ?? 0,
        phone: profile.phone,
        gender: profile.gender,
        emergencyContact: profile.emergencyContact,
        avatarUrl: profile.avatarUrl,
        createdAt: profile.createdAt ?? DateTime.now(),
      ));
    } catch (e) {
      return Failure(Exception(e), 'Failed to upload avatar image: $e');
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      return const Success(null);
    } catch (e) {
      return Failure(Exception(e), 'Password reset failed.');
    }
  }
}
