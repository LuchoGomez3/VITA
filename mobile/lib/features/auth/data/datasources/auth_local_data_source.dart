import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/data/models/stored_auth_session.dart';

/// Fuente local de autenticacion persistida.
///
/// Esta clase es el unico punto de la feature auth que conoce secure storage.
/// El resto del flujo trabaja con entidades de dominio y no necesita saber si
/// la sesion vino de red, memoria o almacenamiento seguro.
class AuthLocalDataSource {
  /// Crea el datasource con el storage seguro inyectado.
  const AuthLocalDataSource({
    required SecureStorageService secureStorage,
  }) : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  /// Guarda la sesion para que pueda restaurarse aunque la app se cierre.
  Future<void> saveSession(StoredAuthSession session) {
    return _secureStorage.write(
      key: SecureStorageKeys.authSession,
      value: session.toEncodedJson(),
    );
  }

  /// Lee la sesion guardada, o `null` si el usuario nunca inicio sesion.
  Future<StoredAuthSession?> readSession() async {
    final encoded = await _secureStorage.read(SecureStorageKeys.authSession);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    return StoredAuthSession.fromEncodedJson(encoded);
  }

  /// Elimina la sesion persistida durante logout o ante datos corruptos.
  Future<void> clearSession() {
    return _secureStorage.delete(SecureStorageKeys.authSession);
  }
}
