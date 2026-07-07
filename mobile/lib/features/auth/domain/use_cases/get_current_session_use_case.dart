import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para leer la sesion local vigente.
class GetCurrentSessionUseCase {
  /// Crea el caso de uso con el repositorio de auth.
  const GetCurrentSessionUseCase(this._repository);

  final AuthRepository _repository;

  /// Devuelve la sesion restaurada o iniciada en este dispositivo.
  Future<Result<AuthSession>> call() {
    return _repository.getCurrentSession();
  }
}
