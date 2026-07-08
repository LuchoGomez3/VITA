import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/models/session.dart';
import 'package:frontend_mayoral/features/auth/data/storage/session_storage.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';

/// Fuente única de la sesión en runtime (memoria + almacenamiento seguro).
///
/// Lo consumen: el guard del router (para decidir login vs app), el AuthCubit
/// (login/logout) y el token provider de Brick (para adjuntar y renovar el JWT
/// al sincronizar). Es un [ChangeNotifier] para que GoRouter reevalúe la
/// redirección cuando la sesión cambia.
///
/// Reglas del ciclo offline-first que centraliza:
/// - Al arrancar, [load] rehidrata la sesión desde disco → la app puede entrar
///   autenticada sin red.
/// - [validAccessToken] renueva el token si venció y hay red; si no hay red
///   devuelve el token actual (el sync lo reintenta luego).
/// - Si el refresh está muerto (401), se cierra sesión → el guard manda a login.
///   Un fallo de red NO cierra sesión (se mantiene para reintentar al reconectar).
class SessionManager extends ChangeNotifier {
  SessionManager({
    required SessionStorage storage,
    required AuthRemoteDataSource remote,
  }) : _storage = storage,
       _remote = remote;

  final SessionStorage _storage;
  final AuthRemoteDataSource _remote;

  Session? _current;

  /// Sesión vigente (o `null` si no hay).
  Session? get current => _current;

  /// Usuario autenticado (o `null`).
  AppUser? get user => _current?.user;

  /// `true` si hay una sesión cacheada (habilita operar, incluso offline).
  bool get isAuthenticated => _current != null;

  /// Rehidrata la sesión desde almacenamiento seguro. Llamar al iniciar la app.
  Future<void> load() async {
    _current = await _storage.read();
    notifyListeners();
  }

  /// Inicia sesión contra el backend y la persiste. Requiere conexión.
  ///
  /// Propaga [AuthUnauthorizedException] (credenciales inválidas) y
  /// [AuthNetworkException] (sin conexión) para que el llamador las traduzca.
  Future<AppUser> signIn({
    required String username,
    required String password,
  }) async {
    final session = await _remote.login(username: username, password: password);
    await _persist(session);
    return session.user;
  }

  /// Cierra sesión: borra memoria y disco.
  Future<void> signOut() async {
    _current = null;
    await _storage.clear();
    notifyListeners();
  }

  /// Access token válido para sincronizar; renueva si venció y hay red.
  ///
  /// Devuelve `null` solo si no hay sesión. Si hay sesión pero el refresh falla
  /// por red, devuelve el token actual (posiblemente vencido) y deja que el sync
  /// lo reintente.
  Future<String?> validAccessToken() async {
    final session = _current;
    if (session == null) {
      return null;
    }
    if (!session.isExpired) {
      return session.accessToken;
    }
    final refreshed = await _tryRefresh();
    return refreshed?.accessToken ?? session.accessToken;
  }

  /// Fuerza una renovación (usado por el cliente de sync ante un 401).
  ///
  /// Devuelve el nuevo access token, o `null` si no se pudo renovar (sin red o
  /// refresh muerto → en cuyo caso ya se cerró sesión).
  Future<String?> forceRefresh() async {
    final refreshed = await _tryRefresh();
    return refreshed?.accessToken;
  }

  Future<Session?> _tryRefresh() async {
    final session = _current;
    if (session == null) {
      return null;
    }
    try {
      final renewed = await _remote.refresh(session.refreshToken);
      await _persist(renewed);
      return renewed;
    } on AuthUnauthorizedException {
      // Refresh vencido/revocado: no hay forma de renovar sin re-login. Cerramos
      // sesión para que el guard mande a la pantalla de login. La cola offline
      // persiste en disco y se drena luego del nuevo login.
      await signOut();
      return null;
    } on AuthNetworkException {
      // Sin conexión: mantenemos la sesión y reintentamos más tarde.
      return null;
    }
  }

  Future<void> _persist(Session session) async {
    _current = session;
    await _storage.write(session);
    notifyListeners();
  }
}
