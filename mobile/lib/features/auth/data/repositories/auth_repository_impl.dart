import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/session_manager.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Implementación del contrato de auth sobre el [SessionManager].
///
/// El SessionManager es la única fuente de sesión (memoria + disco), así que
/// este repositorio solo traduce sus resultados/errores al [Result] de dominio.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required SessionManager sessionManager})
    : _sessionManager = sessionManager;

  final SessionManager _sessionManager;

  @override
  Future<Result<AppUser>> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final user = await _sessionManager.signIn(
        username: username,
        password: password,
      );
      return Result.success(user);
    } on AuthUnauthorizedException catch (error) {
      return Result.failure(
        DomainException(
          message: error.message,
          code: DomainErrorCode.unauthorized,
        ),
      );
    } on AuthNetworkException catch (error) {
      // El primer login necesita conexión: sin red no hay forma de validar
      // credenciales contra el proveedor de identidad.
      return Result.failure(
        DomainException(message: error.message, code: DomainErrorCode.offline),
      );
    }
  }

  @override
  Future<Result<AppUser>> getCurrentUser() async {
    final user = _sessionManager.user;
    if (user == null) {
      return const Result.failure(
        DomainException(
          message: 'No hay una sesión activa.',
          code: DomainErrorCode.unauthorized,
        ),
      );
    }
    return Result.success(user);
  }

  @override
  Future<void> signOut() => _sessionManager.signOut();
}
