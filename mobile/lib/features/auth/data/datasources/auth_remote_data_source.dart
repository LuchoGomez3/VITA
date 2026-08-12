import 'dart:convert';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/auth/data/models/auth_remote_session.dart';
import 'package:http/http.dart' as http;

/// Cliente remoto de autenticacion contra el backend.
class AuthRemoteDataSource {
  /// Crea el cliente con la URL base del backend.
  const AuthRemoteDataSource({
    required String backendBaseUrl,
    required http.Client client,
    Duration requestTimeout = const Duration(seconds: 10),
  }) : _backendBaseUrl = backendBaseUrl,
       _client = client,
       _requestTimeout = requestTimeout;

  final String _backendBaseUrl;
  final http.Client _client;
  final Duration _requestTimeout;

  /// Registra un usuario nuevo y devuelve la sesion que abre de inmediato.
  ///
  /// El registro es online-only y el backend ya devuelve una sesion completa
  /// (igual contrato que `signIn`), para que el cliente pueda seguir operando
  /// sin pedir credenciales de nuevo (p. ej. para registrar su
  /// establecimiento a continuacion).
  Future<AuthRemoteSession> register({
    required String firstName,
    required String lastName,
    required String email,
    required String cuit,
    required String password,
  }) async {
    final response = await _client
        .post(
          _uri('/api/v1/usuarios/registro'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nombre': firstName,
            'apellido': lastName,
            'email': email,
            'cuit': cuit,
            'password': password,
          }),
        )
        .timeout(_requestTimeout);

    final body = _decodeResponse(response);
    _throwIfUnsuccessful(
      response,
      body,
      fallbackMessage: 'No se pudo crear la cuenta. Intenta nuevamente.',
    );

    return _sessionFromBody(body);
  }

  /// Ejecuta el login OAuth2 password form y devuelve token + usuario.
  ///
  /// El backend usa el nombre `username` por el estandar OAuth2, pero para VITA
  /// ese campo es el email del usuario. Mantener esa traduccion aca evita que
  /// la UI y el dominio tengan que hablar de "usuario" cuando realmente es
  /// correo electronico.
  Future<AuthRemoteSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client
        .post(
          _uri('/api/auth/login'),
          headers: const {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'username': email,
            'password': password,
          },
        )
        .timeout(_requestTimeout);

    final body = _decodeResponse(response);
    if (response.statusCode == 401) {
      throw const DomainException(
        message: 'Email o contrasena incorrectos.',
        code: DomainErrorCode.unauthorized,
      );
    }

    _throwIfUnsuccessful(response, body);
    return _sessionFromBody(body);
  }

  /// Renueva la sesion usando el refresh token persistido.
  Future<AuthRemoteSession> refreshSession({
    required String refreshToken,
  }) async {
    final response = await _client
        .post(
          _uri('/api/auth/refresh'),
          headers: const {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'refresh_token': refreshToken,
          }),
        )
        .timeout(_requestTimeout);

    final body = _decodeResponse(response);
    if (response.statusCode == 401) {
      throw const DomainException(
        message: 'La sesion expiro. Inicia sesion nuevamente.',
        code: DomainErrorCode.unauthorized,
      );
    }

    _throwIfUnsuccessful(
      response,
      body,
      fallbackMessage: 'No se pudo renovar la sesion.',
    );
    return _sessionFromBody(body);
  }

  /// Lee el perfil asociado al token Bearer.
  ///
  /// Este metodo queda disponible para validaciones online puntuales. No se usa
  /// durante `restoreSession`, porque restaurar debe poder hacerse sin internet.
  Future<Map<String, dynamic>> getCurrentUser(String accessToken) async {
    final response = await _client
        .get(
          _uri('/api/auth/me'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        )
        .timeout(_requestTimeout);

    final body = _decodeResponse(response);
    _throwIfUnsuccessful(response, body);
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const DomainException(
      message: 'El backend no devolvio el usuario autenticado.',
    );
  }

  Uri _uri(String path) {
    return Uri.parse('$_backendBaseUrl$path');
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      throw const DomainException(
        message: 'No se pudo interpretar la respuesta del backend.',
      );
    }

    throw const DomainException(
      message: 'El backend devolvio una respuesta inesperada.',
    );
  }

  AuthRemoteSession _sessionFromBody(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];
      final expiresIn = data['expires_in'];
      final userJson = data['usuario'];
      if (accessToken is String &&
          accessToken.isNotEmpty &&
          refreshToken is String &&
          refreshToken.isNotEmpty &&
          expiresIn is num &&
          expiresIn > 0 &&
          userJson is Map<String, dynamic>) {
        return AuthRemoteSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: expiresIn.toInt(),
          userJson: userJson,
        );
      }
    }

    throw const DomainException(
      message: 'El backend no devolvio una sesion valida.',
    );
  }

  void _throwIfUnsuccessful(
    http.Response response,
    Map<String, dynamic> body, {
    String fallbackMessage = 'No se pudo iniciar sesion. Intenta nuevamente.',
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final detail = body['detail'];
    if (detail is String && detail.isNotEmpty) {
      throw DomainException(message: detail);
    }

    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;
      if (firstError is Map<String, dynamic>) {
        final message = firstError['message'];
        if (message is String && message.isNotEmpty) {
          throw DomainException(
            message: message,
            code: DomainErrorCode.validation,
          );
        }
      }
    }

    throw DomainException(message: fallbackMessage);
  }
}
