import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/features/auth/data/session_manager.dart';

/// Conecta la sesión real de la app con el sync de Brick.
///
/// Reemplaza al `DartDefineBackendAccessTokenProvider` (token estático de dev):
/// lee el token vigente del [SessionManager] y sabe renovarlo, cerrando el
/// ciclo offline-first — cuando la app recupera conexión, Brick drena la cola
/// con un token válido.
class SessionBackendAccessTokenProvider implements BackendAccessTokenProvider {
  const SessionBackendAccessTokenProvider(this._sessionManager);

  final SessionManager _sessionManager;

  @override
  Future<String?> getAccessToken() => _sessionManager.validAccessToken();

  @override
  Future<String?> refreshAccessToken() => _sessionManager.forceRefresh();
}
