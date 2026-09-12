import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para registrar un usuario nuevo.
class RegisterUserUseCase {
  /// Crea el caso de uso con el repositorio de autenticacion.
  const RegisterUserUseCase(this._repository);

  final AuthRepository _repository;

  /// Ejecuta el registro con los datos validados por el formulario.
  Future<Result<AuthSession>> call({
    required RegistrationRequest request,
  }) {
    return _repository.register(request: request);
  }
}
