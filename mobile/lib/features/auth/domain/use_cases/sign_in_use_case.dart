import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para iniciar sesion en el backend.
class SignInUseCase {
  /// Crea el caso de uso con el repositorio de auth.
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  /// Ejecuta el login con credenciales de usuario.
  Future<Result<AuthSession>> call({
    required String username,
    required String password,
  }) {
    return _repository.signIn(
      username: username,
      password: password,
    );
  }
}
