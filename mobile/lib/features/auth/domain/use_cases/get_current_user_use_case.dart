import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Retrieves the current authenticated user.
class GetCurrentUserUseCase {
  /// Creates the use case with its auth repository dependency.
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the current-user lookup.
  Future<Result<AppUser>> call() {
    return _repository.getCurrentUser();
  }
}
