import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Signs in a user with credentials.
class SignInUseCase {
  /// Creates the use case with its auth repository dependency.
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the sign-in request.
  Future<Result<AppUser>> call({
    required String username,
    required String password,
  }) {
    return _repository.signIn(
      username: username,
      password: password,
    );
  }
}
