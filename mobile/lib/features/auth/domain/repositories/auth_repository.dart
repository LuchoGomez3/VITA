import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';

/// Contrato de autenticacion consumido por los casos de uso.
abstract class AuthRepository {
  /// Registra un usuario nuevo y persiste la sesion devuelta por el backend.
  Future<Result<AuthSession>> register({
    required RegistrationRequest request,
  });

  /// Inicia sesion contra el backend y devuelve la sesion mobile.
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  });

  /// Restaura una sesion guardada localmente sin consultar al backend.
  Future<Result<AuthSession>> restoreSession();

  /// Renueva la sesion local usando el refresh token persistido.
  Future<Result<AuthSession>> refreshSession();

  /// Devuelve la sesion actual disponible localmente.
  Future<Result<AuthSession>> getCurrentSession();

  /// Devuelve el usuario de la sesion actual disponible localmente.
  Future<Result<AppUser>> getCurrentUser();

  /// Intenta revocar la sesion remota y siempre elimina la copia local.
  Future<void> signOut();
}
