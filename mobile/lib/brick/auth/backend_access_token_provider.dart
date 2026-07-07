/// Fuente del JWT que Brick usa para sincronizar contra el backend.
///
/// Brick ejecuta requests REST por fuera del flujo normal de pantallas, por eso
/// necesita una forma simple de pedir el token actual sin conocer la feature de
/// autenticacion. Este contrato permite cambiar de implementacion cuando exista
/// login real en mobile.
abstract class BackendAccessTokenProvider {
  /// Devuelve el access token vigente.
  ///
  /// Retorna `null` cuando todavia no hay sesion disponible. En ese caso el
  /// cliente autenticado no puede enviar la request y Brick la deja como fallo
  /// de sync/reintento segun corresponda.
  Future<String?> getAccessToken();
}

/// Provider de token compartido por el flujo de login y Brick.
///
/// Mantiene el JWT solo en memoria del proceso. Auth lo hidrata despues de un
/// login exitoso o al restaurar una sesion desde secure storage. Brick no conoce
/// esa persistencia: solo pide el token vigente mediante este contrato.
class SessionBackendAccessTokenProvider implements BackendAccessTokenProvider {
  SessionBackendAccessTokenProvider._();

  /// Instancia compartida durante el ciclo de vida de la app.
  static final instance = SessionBackendAccessTokenProvider._();

  String? _accessToken;

  /// Token actual en memoria.
  String? get accessToken => _accessToken;

  /// Token vigente de la sesion.
  set accessToken(String accessToken) {
    _accessToken = accessToken;
  }

  /// Elimina el token de la sesion local.
  void clearAccessToken() {
    _accessToken = null;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;
}
