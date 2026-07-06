import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';

part 'auth_session.freezed.dart';

/// Sesion autenticada usada por la app y por la infraestructura Brick.
@freezed
sealed class AuthSession with _$AuthSession {
  /// Crea una sesion con el usuario y el JWT vigente.
  const factory AuthSession({
    required AppUser user,
    required String accessToken,
  }) = _AuthSession;
}
