// lib/data/datasources/supabase_auth_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutricare_elderly/data/models/user_model.dart';

abstract class SupabaseAuthDataSource {
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
  });

  Future<UserModel> loginUser({
    required String email,
    required String password,
  });

  Future<void> logoutUser();

  Future<UserModel?> getCurrentUser();

  Future<void> resetPassword(String email);

  Future<UserModel> signInWithGoogle();

  Future<UserModel> signInWithApple();
}

class SupabaseAuthDataSourceImpl implements SupabaseAuthDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Registration failed');
      }

      // Insert profile
      await supabaseClient.from('profiles').insert({
        'user_id': response.user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'age': age,
      });

      return UserModel(
        id: response.user!.id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        age: age,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  @override
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      // Fetch profile
      final profile = await supabaseClient
          .from('profiles')
          .select()
          .eq('user_id', response.user!.id)
          .single();

      return UserModel(
        id: response.user!.id,
        email: email,
        firstName: profile['first_name'],
        lastName: profile['last_name'],
        age: profile['age'],
        phone: profile['phone'],
        gender: profile['gender'],
        createdAt: DateTime.parse(profile['created_at']),
      );
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  @override
  Future<void> logoutUser() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      final profile = await supabaseClient
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .single();

      return UserModel(
        id: user.id,
        email: user.email ?? '',
        firstName: profile['first_name'],
        lastName: profile['last_name'],
        age: profile['age'],
        phone: profile['phone'],
        gender: profile['gender'],
        createdAt: DateTime.parse(profile['created_at']),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Reset password error: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    throw UnimplementedError('Use AuthService for social sign in');
  }

  @override
  Future<UserModel> signInWithApple() async {
    throw UnimplementedError('Use AuthService for social sign in');
  }
}
