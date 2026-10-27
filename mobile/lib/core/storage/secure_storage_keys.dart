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

  /// Borrador cifrado y aislado para una venta, usuario y establecimiento.
  static String livestockSaleDraft(String userId, String establishmentId) =>
      'livestock_sale_draft_v1_${userId}_$establishmentId';
}
