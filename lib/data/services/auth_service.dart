// lib/data/services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'service_exception.dart';
import 'supabase_service.dart';

/// Models for service layer (DTOs - Data Transfer Objects)
class AuthResponseModel {
  final String userId;
  final String email;

  AuthResponseModel({
    required this.userId,
    required this.email,
  });
}

class UserProfileModel {
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final int? age;
  final String? phone;
  final String? gender;
  final String? emergencyContact;
  final String? avatarUrl;
  final DateTime? createdAt;

  UserProfileModel({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    this.age,
    this.phone,
    this.gender,
    this.emergencyContact,
    this.avatarUrl,
    this.createdAt,
  });
}

/// Authentication service - handles signup, signin, logout, session
class AuthService {
  final SupabaseService _supabaseService;

  AuthService(this._supabaseService);

  /// Sign up new user
  Future<AuthResponseModel> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'age': age,
        },
      );

      if (response.user == null) {
        throw ServiceException('Signup returned no user');
      }

      return AuthResponseModel(
        userId: response.user!.id,
        email: response.user!.email ?? email,
      );
    } on supabase_flutter.AuthException catch (e) {
      throw ServiceException(
        e.message,
        code: 'AUTH_SIGNUP_ERROR',
        originalException: e,
      );
    } catch (e) {
      throw ServiceException(
        'Signup failed: $e',
        code: 'SIGNUP_ERROR',
        originalException: e,
      );
    }
  }

  /// Sign in user
  Future<AuthResponseModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.client.auth
          .signInWithPassword(email: email, password: password);

      if (response.user == null) {
        throw ServiceException('Login returned no user');
      }

      return AuthResponseModel(
        userId: response.user!.id,
        email: response.user!.email ?? email,
      );
    } on supabase_flutter.AuthException catch (e) {
      throw ServiceException(
        e.message,
        code: 'AUTH_SIGNIN_ERROR',
        originalException: e,
      );
    } catch (e) {
      throw ServiceException(
        'Signin failed: $e',
        code: 'SIGNIN_ERROR',
        originalException: e,
      );
    }
  }

  /// Get current authenticated user
  Future<UserProfileModel?> getCurrentUser() async {
    try {
      final authUser = _supabaseService.client.auth.currentUser;
      if (authUser == null) return null;

      // Fetch full profile from database
      final response = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('user_id', authUser.id)
          .maybeSingle();

      if (response == null) return null;

      return UserProfileModel(
        userId: authUser.id,
        email: authUser.email ?? '',
        firstName: response['first_name'] as String?,
        lastName: response['last_name'] as String?,
        age: response['age'] as int?,
        phone: response['phone'] as String?,
        gender: response['gender'] as String?,
        emergencyContact: response['emergency_contact'] as String?,
        avatarUrl: response['avatar_url'] as String?,
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'] as String)
            : null,
      );
    } catch (e) {
      throw ServiceException(
        'Failed to get current user: $e',
        code: 'GET_USER_ERROR',
        originalException: e,
      );
    }
  }

  /// Create user profile after signup
  Future<UserProfileModel> createProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required int age,
    String? phone,
    String? gender,
    String? emergencyContact,
  }) async {
    try {
      final session = _supabaseService.client.auth.currentSession;
      if (session == null) {
        debugPrint('Warning: No active session during profile creation. This may fail if RLS is on.');
      }

      // Use upsert to prevent failure if a trigger already created the profile
      final response = await _supabaseService.client
          .from('profiles')
          .upsert({
            'user_id': userId,
            'first_name': firstName,
            'last_name': lastName,
            'age': age,
            'phone': phone,
            'gender': gender,
            'emergency_contact': emergencyContact,
          }, onConflict: 'user_id')
          .select()
          .single();

      return UserProfileModel(
        userId: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        age: age,
        phone: phone,
        gender: gender,
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'] as String)
            : null,
      );
    } catch (e) {
      throw ServiceException(
        'Failed to create profile: $e',
        code: 'CREATE_PROFILE_ERROR',
        originalException: e,
      );
    }
  }

  /// Update user profile
  Future<UserProfileModel> updateProfile({
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
      final response = await _supabaseService.client
          .from('profiles')
          .upsert({
            'user_id': userId,
            'first_name': firstName,
            'last_name': lastName,
            'age': age,
            'phone': phone,
            'gender': gender,
            'emergency_contact': emergencyContact,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          }, onConflict: 'user_id')
          .select()
          .single();

      final authUser = _supabaseService.client.auth.currentUser;

      return UserProfileModel(
        userId: userId,
        email: authUser?.email ?? '',
        firstName: firstName,
        lastName: lastName,
        age: age,
        phone: phone,
        gender: gender,
        avatarUrl: response['avatar_url'] as String?,
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'] as String)
            : null,
      );
    } catch (e) {
      throw ServiceException(
        'Failed to update profile: $e',
        code: 'UPDATE_PROFILE_ERROR',
        originalException: e,
      );
    }
  }

  /// Update user avatar URL
  Future<UserProfileModel> updateAvatarUrl({
    required String userId,
    required String avatarUrl,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('profiles')
          .update({
            'avatar_url': avatarUrl,
          })
          .eq('user_id', userId)
          .select()
          .single();

      final authUser = _supabaseService.client.auth.currentUser;

      return UserProfileModel(
        userId: userId,
        email: authUser?.email ?? '',
        firstName: response['first_name'] as String?,
        lastName: response['last_name'] as String?,
        age: response['age'] as int?,
        phone: response['phone'] as String?,
        gender: response['gender'] as String?,
        emergencyContact: response['emergency_contact'] as String?,
        avatarUrl: response['avatar_url'] as String?,
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'] as String)
            : null,
      );
    } catch (e) {
      throw ServiceException(
        'Failed to update avatar URL: $e',
        code: 'UPDATE_AVATAR_ERROR',
        originalException: e,
      );
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _supabaseService.client.auth.signOut();
    } catch (e) {
      throw ServiceException(
        'Failed to sign out: $e',
        code: 'SIGNOUT_ERROR',
        originalException: e,
      );
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      // For simple web-based OAuth (works on mobile too)
      await _supabaseService.client.auth.signInWithOAuth(
        supabase_flutter.Provider.google,
        redirectTo: 'io.supabase.nutricare://login-callback',
      );
    } catch (e) {
      throw ServiceException(
        'Google login failed: $e',
        code: 'GOOGLE_LOGIN_ERROR',
        originalException: e,
      );
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      await _supabaseService.client.auth.signInWithOAuth(
        supabase_flutter.Provider.apple,
        redirectTo: 'io.supabase.nutricare://login-callback',
      );
    } catch (e) {
      throw ServiceException(
        'Apple login failed: $e',
        code: 'APPLE_LOGIN_ERROR',
        originalException: e,
      );
    }
  }
}
