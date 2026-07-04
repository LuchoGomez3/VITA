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

/// Implementacion temporal que lee el JWT desde `--dart-define`.
///
/// Sirve para desarrollo mientras la app no tenga pantallas/sesion real de
/// login. En VS Code se carga desde `.vscode/launch.json` con:
/// `--dart-define=VITA_BACKEND_ACCESS_TOKEN=<jwt>`.
///
/// Pendiente: reemplazar por un provider conectado a Supabase Auth cuando
/// exista refresco de sesion en mobile.
class DartDefineBackendAccessTokenProvider implements BackendAccessTokenProvider {
  /// Crea un provider basado en `VITA_BACKEND_ACCESS_TOKEN`.
  const DartDefineBackendAccessTokenProvider();

  /// Valor inyectado en tiempo de build/run.
  ///
  /// `String.fromEnvironment` solo lee valores pasados como `--dart-define`;
  /// no lee automaticamente archivos `.env`.
  static const _token = String.fromEnvironment('VITA_BACKEND_ACCESS_TOKEN');

  @override
  Future<String?> getAccessToken() async {
    if (_token.trim().isEmpty) {
      return null;
    }

    return _token;
  }
}

/// Provider de token compartido por el flujo de login y Brick.
///
/// Mantiene el JWT solo en memoria del proceso. Cuando la app incorpore
/// almacenamiento seguro, esta clase puede hidratarse desde esa fuente sin que
/// Brick ni las features cambien su contrato.
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
