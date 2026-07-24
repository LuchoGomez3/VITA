import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para iniciar sesion en el backend.
class SignInUseCase {
  /// Crea el caso de uso con el repositorio de auth.
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  /// Ejecuta el login con email y contrasena.
  Future<Result<AuthSession>> call({
    required String email,
    required String password,
  }) {
    return _repository.signIn(
      email: email,
      password: password,
    );
  }
}
