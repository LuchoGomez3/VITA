import 'dart:convert';

import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';

/// Version serializable de la sesion que vive en secure storage.
///
/// No usamos la entidad de dominio como JSON directo para mantener una frontera
/// clara: dominio modela negocio, data decide como persistirlo. Este modelo es
/// deliberadamente chico: token y datos minimos del usuario necesarios para
/// reabrir la app offline sin consultar `/api/auth/me`.
class StoredAuthSession {
  /// Crea una sesion persistible.
  const StoredAuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.cuit,
  });

  /// Construye el modelo local desde la entidad usada por el resto de la app.
  factory StoredAuthSession.fromDomain(AuthSession session) {
    return StoredAuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      accessTokenExpiresAt: session.accessTokenExpiresAt,
      userId: session.user.id,
      email: session.user.email,
      firstName: session.user.firstName,
      lastName: session.user.lastName,
      cuit: session.user.cuit,
    );
  }

  /// Decodifica el JSON guardado en secure storage.
  factory StoredAuthSession.fromJson(Map<String, dynamic> json) {
    return StoredAuthSession(
      accessToken: _readString(json, 'access_token'),
      refreshToken: _readString(json, 'refresh_token'),
      accessTokenExpiresAt: _readDateTime(json, 'access_token_expires_at'),
      userId: _readString(json, 'user_id'),
      email: _readString(json, 'email'),
      firstName: _readString(json, 'first_name'),
      lastName: _readString(json, 'last_name'),
      cuit: _readNullableString(json, 'cuit'),
    );
  }

  /// Decodifica un string JSON completo.
  factory StoredAuthSession.fromEncodedJson(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Stored auth session is not a JSON object.');
    }

    return StoredAuthSession.fromJson(decoded);
  }

  /// JWT usado por backend y por Brick para requests autenticadas.
  final String accessToken;

  /// Token persistido para renovar la sesion cuando vuelva la conexion.
  final String refreshToken;

  /// Fecha de expiracion del access token.
  final DateTime accessTokenExpiresAt;

  /// ID backend/Supabase del usuario.
  final String userId;

  /// Email del usuario autenticado.
  final String email;

  /// Nombre visible del usuario.
  final String firstName;

  /// Apellido visible del usuario.
  final String lastName;

  /// CUIT del productor cuando el backend lo provee.
  final String? cuit;

  /// Convierte el modelo persistido a la entidad de dominio.
  AuthSession toDomain() {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt,
      user: AppUser(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        cuit: cuit,
      ),
    );
  }

  /// Codifica el modelo como JSON plano para secure storage.
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_token_expires_at': accessTokenExpiresAt.toUtc().toIso8601String(),
      'user_id': userId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'cuit': cuit,
    };
  }

  /// Codifica el objeto completo como string para el storage seguro.
  String toEncodedJson() {
    return jsonEncode(toJson());
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }

    return '';
  }

  static String? _readNullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  static DateTime _readDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.toUtc();
      }
    }

    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
