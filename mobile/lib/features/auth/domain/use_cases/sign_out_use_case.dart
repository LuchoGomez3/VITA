import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para cerrar la sesion mobile.
class SignOutUseCase {
  /// Crea el caso de uso con el repositorio de auth.
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  /// Elimina la sesion local actual.
  Future<void> call() {
    return _repository.signOut();
  }
}
