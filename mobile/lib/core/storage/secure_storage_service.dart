import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contrato minimo para leer y escribir valores sensibles.
///
/// La app usa este contrato en vez de depender directamente del plugin para que
/// las features puedan testearse con implementaciones fake en memoria.
abstract class SecureStorageService {
  /// Guarda [value] asociado a [key].
  Future<void> write({
    required String key,
    required String value,
  });

  /// Lee el valor asociado a [key], o `null` si todavia no existe.
  Future<String?> read(String key);

  /// Borra el valor asociado a [key].
  Future<void> delete(String key);
}

/// Implementacion productiva basada en el storage seguro de cada plataforma.
///
/// `flutter_secure_storage` usa Keychain en iOS/macOS y mecanismos cifrados del
/// sistema en Android/desktop. Aca solo exponemos operaciones puntuales para no
/// mezclar detalles del plugin con la arquitectura de auth.
class FlutterSecureStorageService implements SecureStorageService {
  /// Crea el servicio con una instancia inyectable para tests de integracion.
  const FlutterSecureStorageService({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    Duration operationTimeout = const Duration(seconds: 5),
  }) : _storage = storage,
       _operationTimeout = operationTimeout;

  final FlutterSecureStorage _storage;
  final Duration _operationTimeout;

  @override
  Future<void> write({
    required String key,
    required String value,
  }) {
    return _storage.write(key: key, value: value).timeout(_operationTimeout);
  }

  @override
  Future<String?> read(String key) {
    return _storage.read(key: key).timeout(_operationTimeout);
  }

  @override
  Future<void> delete(String key) {
    return _storage.delete(key: key).timeout(_operationTimeout);
  }
}
