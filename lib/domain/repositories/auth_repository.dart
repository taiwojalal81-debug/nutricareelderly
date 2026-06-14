// lib/domain/repositories/auth_repository.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
  });

  Future<Result<UserEntity>> loginUser({
    required String email,
    required String password,
  });

  Future<Result<void>> signInWithGoogle();

  Future<Result<void>> signInWithApple();

  Future<Result<void>> logoutUser();

  Future<Result<UserEntity?>> getCurrentUser();

  Future<Result<UserEntity>> updateUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required int age,
    String? phone,
    String? gender,
    String? emergencyContact,
    String? avatarUrl,
  });

  Future<Result<UserEntity>> uploadAvatar({
    required String userId,
    required String imagePath,
  });

  Future<Result<void>> resetPassword(String email);
}
