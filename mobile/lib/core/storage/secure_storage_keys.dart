/// Claves usadas para guardar datos sensibles fuera de SQLite/Brick.
///
/// Mantener las claves centralizadas evita duplicados y facilita versionar el
/// formato persistido. Si cambia la estructura de la sesion guardada, se puede
/// crear una clave nueva (`authSessionV2`) y migrar sin pisar datos viejos.
class SecureStorageKeys {
  const SecureStorageKeys._();

  /// Sesion autenticada persistida para restaurar la app al abrir offline.
  static const authSession = 'auth_session_v1';

  /// Marker local que evita repetir el bootstrap offline por usuario.
  static String initialDataSyncCompleted(String userId) {
    return 'initial_data_sync_completed_v1_$userId';
  }
}
