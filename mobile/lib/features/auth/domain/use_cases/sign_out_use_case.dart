import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Signs out the current user.
class SignOutUseCase {
  /// Creates the use case with its auth repository dependency.
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the sign-out request.
  Future<void> call() {
    return _repository.signOut();
  }
}
