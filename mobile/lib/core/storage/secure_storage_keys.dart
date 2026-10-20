/// Claves usadas para guardar datos sensibles fuera de SQLite/Brick.
///
/// Mantener las claves centralizadas evita duplicados y facilita versionar el
/// formato persistido. Si cambia la estructura de la sesion guardada, se puede
/// crear una clave nueva (`authSessionV2`) y migrar sin pisar datos viejos.
class SecureStorageKeys {
  const SecureStorageKeys._();

  /// Sesion autenticada persistida para restaurar la app al abrir offline.
  static const authSession = 'auth_session_v1';

  /// Datos completos de los establecimientos disponibles para la sesión.
  static const establishmentCatalog = 'establishment_catalog_v1';

  /// Color de la cabecera de Perfil y estado de la foto del usuario, con lo
  /// que falta subir cuando vuelva la conexión.
  static const profileAppearance = 'profile_appearance_v1';

  /// Último equipo traído del servidor, por establecimiento, para verlo sin
  /// conexión. Trae emails de otras personas: se borra al cerrar sesión.
  static const teamSnapshot = 'team_snapshot_v1';
}
