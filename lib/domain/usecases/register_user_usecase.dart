// lib/domain/usecases/register_user_usecase.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/user_entity.dart';
import 'package:nutricare_elderly/domain/repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository authRepository;

  RegisterUserUseCase(this.authRepository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    return await authRepository.registerUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      age: age,
    );
  }
}
