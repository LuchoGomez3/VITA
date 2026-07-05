import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para obtener el usuario de la sesion vigente.
class GetCurrentUserUseCase {
  /// Crea el caso de uso con el repositorio de auth.
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  /// Lee el usuario autenticado actual.
  Future<Result<AppUser>> call() {
    return _repository.getCurrentUser();
  }
}
