/// Datos de sesion devueltos por `/api/auth/login`.
///
/// Es un DTO de la capa data: representa el contrato HTTP del backend antes de
/// convertirse en entidades de dominio.
class AuthRemoteSession {
  /// Crea el DTO de sesion remota.
  const AuthRemoteSession({
    required this.accessToken,
    required this.userJson,
  });

  /// JWT que el backend espera en `Authorization: Bearer <token>`.
  final String accessToken;

  /// Perfil de usuario tal como llega desde el backend.
  final Map<String, dynamic> userJson;
}
