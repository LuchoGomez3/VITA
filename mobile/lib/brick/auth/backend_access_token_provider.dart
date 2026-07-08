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

  /// Fuerza una renovacion del token y devuelve el nuevo access token.
  ///
  /// El cliente de sync la invoca cuando el backend responde 401 al drenar la
  /// cola offline (el access cacheado venció mientras no había conexión).
  /// Retorna `null` si no se pudo renovar (sin red o refresh muerto), en cuyo
  /// caso la request debe quedar retenida en la cola para reintentar luego.
  Future<String?> refreshAccessToken();
}

/// Implementacion temporal que lee el JWT desde `--dart-define`.
///
/// Sirve para desarrollo mientras la app no tenga pantallas/sesion real de
/// login. En VS Code se carga desde `.vscode/launch.json` con:
/// `--dart-define=VITA_BACKEND_ACCESS_TOKEN=<jwt>`.
///
/// TODO(agustin): Reemplazar por un provider conectado a Supabase Auth cuando
/// exista el flujo real de autenticacion mobile. Ese provider deberia obtener
/// el token de la sesion actual y refrescarlo cuando expire.
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

  @override
  Future<String?> refreshAccessToken() async {
    // Un token estático de `--dart-define` no se puede renovar.
    return null;
  }
}
