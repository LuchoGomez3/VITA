import 'package:frontend_mayoral/core/errors/domain_exception.dart';

/// Sesion tecnica que Brick necesita para enviar requests autenticadas.
class BackendTokenSession {
  /// Crea una sesion tecnica para el provider compartido.
  const BackendTokenSession({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
  });

  /// JWT corto que se envia como Bearer.
  final String accessToken;

  /// Token largo usado para renovar el access token.
  final String refreshToken;

  /// Fecha de expiracion del access token.
  final DateTime accessTokenExpiresAt;
}

/// Callback que renueva una sesion vencida sin acoplar Brick a auth.
typedef BackendTokenRefreshCallback = Future<BackendTokenSession?> Function(String refreshToken);

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

/// Fuente de token capaz de forzar una renovacion tras un rechazo del backend.
abstract class RefreshableBackendAccessTokenProvider implements BackendAccessTokenProvider {
  /// Renueva la sesion y devuelve el nuevo access token cuando fue posible.
  Future<String?> refreshAccessToken();
}

/// Provider de token compartido por el flujo de login y Brick.
///
/// Mantiene el JWT solo en memoria del proceso. Auth lo hidrata despues de un
/// login exitoso o al restaurar una sesion desde secure storage. Brick no conoce
/// esa persistencia: solo pide el token vigente mediante este contrato.
class SessionBackendAccessTokenProvider implements RefreshableBackendAccessTokenProvider {
  SessionBackendAccessTokenProvider._();

  /// Instancia compartida durante el ciclo de vida de la app.
  static final instance = SessionBackendAccessTokenProvider._();

  String? _accessToken;
  String? _refreshToken;
  DateTime? _accessTokenExpiresAt;
  Future<BackendTokenSession?>? _refreshInFlight;

  /// Callback configurado por auth para renovar un access token vencido.
  BackendTokenRefreshCallback? refreshCallback;

  /// Token actual en memoria.
  String? get accessToken => _accessToken;

  /// Token vigente de la sesion.
  ///
  /// Se conserva para tests y llamadas legacy. Las integraciones nuevas deben
  /// usar [session] para incluir refresh y expiracion.
  set accessToken(String accessToken) {
    _accessToken = accessToken;
  }

  /// Sesion tecnica actual, cuando existe completa en memoria.
  BackendTokenSession? get session {
    final accessToken = _accessToken;
    final refreshToken = _refreshToken;
    final accessTokenExpiresAt = _accessTokenExpiresAt;
    if (accessToken == null || refreshToken == null || accessTokenExpiresAt == null) {
      return null;
    }

    return BackendTokenSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt,
    );
  }

  /// Hidrata todos los datos de sesion que necesita Brick.
  set session(BackendTokenSession session) {
    _accessToken = session.accessToken;
    _refreshToken = session.refreshToken;
    _accessTokenExpiresAt = session.accessTokenExpiresAt.toUtc();
  }

  /// Elimina el token de la sesion local.
  void clearAccessToken() {
    _accessToken = null;
    _refreshToken = null;
    _accessTokenExpiresAt = null;
    _refreshInFlight = null;
  }

  @override
  Future<String?> getAccessToken() async {
    final token = _accessToken;
    if (token == null) {
      return null;
    }

    final expiresAt = _accessTokenExpiresAt;
    if (expiresAt == null || DateTime.now().toUtc().isBefore(expiresAt)) {
      return token;
    }

    final refreshToken = _refreshToken;
    final refreshCallback = this.refreshCallback;
    if (refreshToken == null || refreshToken.isEmpty || refreshCallback == null) {
      throw const DomainException(
        message: 'La sesion expiro. Inicia sesion nuevamente.',
        code: DomainErrorCode.unauthorized,
      );
    }

    BackendTokenSession? refreshed;
    try {
      refreshed = await (_refreshInFlight ??= refreshCallback(refreshToken));
    } on DomainException catch (error) {
      if (error.code == DomainErrorCode.unauthorized) {
        clearAccessToken();
      }
      rethrow;
    } finally {
      _refreshInFlight = null;
    }

    if (refreshed == null) {
      throw const DomainException(
        message: 'No se pudo renovar la sesion por un problema de red.',
        code: DomainErrorCode.offline,
      );
    }

    session = refreshed;
    return refreshed.accessToken;
  }

  /// Fuerza una unica renovacion despues de que el backend rechaza un token.
  ///
  /// Se usa para el caso en que la expiracion local quedo desfasada respecto
  /// del servidor. Los datos offline no se eliminan si la renovacion falla.
  @override
  Future<String?> refreshAccessToken() async {
    final refreshToken = _refreshToken;
    final refreshCallback = this.refreshCallback;
    if (refreshToken == null || refreshToken.isEmpty || refreshCallback == null) {
      clearAccessToken();
      return null;
    }

    BackendTokenSession? refreshed;
    try {
      refreshed = await (_refreshInFlight ??= refreshCallback(refreshToken));
    } on DomainException catch (error) {
      if (error.code == DomainErrorCode.unauthorized) clearAccessToken();
      rethrow;
    } finally {
      _refreshInFlight = null;
    }
    if (refreshed == null) {
      throw const DomainException(
        message: 'No se pudo renovar la sesion por un problema de red.',
        code: DomainErrorCode.offline,
      );
    }
    session = refreshed;
    return refreshed.accessToken;
  }
}
