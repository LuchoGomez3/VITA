import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_mayoral/features/auth/data/models/session.dart';

/// Persistencia segura de la sesión en el dispositivo.
///
/// Usa el almacenamiento cifrado del SO (Keychain / Keystore) porque guarda
/// tokens. Es lo que permite que la app abra autenticada tras cerrarse, incluso
/// sin conexión.
class SessionStorage {
  SessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'vita_session';

  final FlutterSecureStorage _storage;

  /// Lee la sesión guardada. Devuelve `null` si no hay o si está corrupta.
  Future<Session?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return Session.fromStorageJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      // Formato inválido (versión vieja / dato corrupto): la tratamos como sin
      // sesión para no dejar la app en un estado inconsistente.
      await clear();
      return null;
    }
  }

  /// Guarda (o reemplaza) la sesión.
  Future<void> write(Session session) {
    return _storage.write(key: _key, value: jsonEncode(session.toStorageJson()));
  }

  /// Borra la sesión (logout / refresh vencido).
  Future<void> clear() => _storage.delete(key: _key);
}
