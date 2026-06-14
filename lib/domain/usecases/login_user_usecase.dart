// lib/domain/usecases/login_user_usecase.dart

import 'package:nutricare_elderly/core/utils/result.dart';
import 'package:nutricare_elderly/domain/entities/user_entity.dart';
import 'package:nutricare_elderly/domain/repositories/auth_repository.dart';

class LoginUserUseCase {
  final AuthRepository authRepository;

  LoginUserUseCase(this.authRepository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await authRepository.loginUser(
      email: email,
      password: password,
    );
  }
}
