/// Mensajes de recuperación del cierre de sesión.
class AuthSessionStrings {
  const AuthSessionStrings._();

  /// La limpieza pendiente impide entrar con otra cuenta.
  static const cleanupFailed = 'No pudimos limpiar los datos de tu sesión. Reintentá para continuar.';

  /// Repite únicamente el cierre y la limpieza de la sesión invalidada.
  static const retryCleanup = 'Reintentar';
}
