import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso que recupera la sesion local al abrir la app.
///
/// No valida contra backend porque debe funcionar sin internet: si existe una
/// sesion persistida, la app puede entrar y seguir operando con SQLite/Brick.
class RestoreSessionUseCase {
  /// Crea el caso de uso con el repositorio de auth.
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  /// Intenta restaurar la sesion guardada en el dispositivo.
  Future<Result<AuthSession>> call() {
    return _repository.restoreSession();
  }
}
