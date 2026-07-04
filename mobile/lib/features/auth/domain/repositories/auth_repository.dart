import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';

/// Contrato de autenticacion consumido por los casos de uso.
abstract class AuthRepository {
  /// Inicia sesion contra el backend y devuelve la sesion mobile.
  Future<Result<AuthSession>> signIn({
    required String username,
    required String password,
  });

  /// Devuelve el usuario de la sesion actual.
  Future<Result<AppUser>> getCurrentUser();

  /// Cierra la sesion local.
  Future<void> signOut();
}
