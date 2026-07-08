import 'dart:async';
import 'dart:convert';

import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/features/auth/data/models/session.dart';
import 'package:http/http.dart' as http;

/// Credenciales inválidas o refresh vencido/revocado (HTTP 401 del backend).
///
/// El repositorio la traduce a un error de dominio "unauthorized"; en el flujo
/// de sync implica que el usuario debe volver a loguearse.
class AuthUnauthorizedException implements Exception {
  const AuthUnauthorizedException([this.message = 'No autorizado']);

  final String message;
}

/// No se pudo contactar al backend (sin conexión o error transitorio).
///
/// Es esperable en el campo: el llamador decide si reintentar o seguir con la
/// sesión cacheada.
class AuthNetworkException implements Exception {
  const AuthNetworkException([this.message = 'Sin conexión con el servidor']);

  final String message;
}

/// Cliente HTTP contra los endpoints de autenticación del backend FastAPI.
///
/// No conoce almacenamiento ni estado: solo traduce request/response. La
/// persistencia y el manejo de sesión viven en el SessionManager.
class AuthRemoteDataSource {
  AuthRemoteDataSource({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.current.backendBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  /// Inicia sesión con email + contraseña. Devuelve la sesión completa.
  ///
  /// `/auth/login` usa `OAuth2PasswordRequestForm`, por eso el body va como
  /// `application/x-www-form-urlencoded` con `username`/`password`.
  Future<Session> login({
    required String username,
    required String password,
  }) async {
    final response = await _post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
    return _sessionFromResponse(response);
  }

  /// Renueva la sesión con el `refresh_token`. 401 => refresh muerto.
  Future<Session> refresh(String refreshToken) async {
    final response = await _post(
      Uri.parse('$_baseUrl/api/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    return _sessionFromResponse(response);
  }

  Future<http.Response> _post(
    Uri url, {
    required Map<String, String> headers,
    required Object body,
  }) async {
    try {
      return await _client.post(url, headers: headers, body: body);
    } on Object catch (error) {
      // SocketException / timeouts / DNS: todo lo tratamos como falta de red.
      throw AuthNetworkException('No se pudo conectar: $error');
    }
  }

  Session _sessionFromResponse(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AuthUnauthorizedException('Credenciales inválidas');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthNetworkException('Error del servidor (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const AuthNetworkException('Respuesta de sesión inválida');
    }
    return Session.fromBackendJson(data);
  }

  void close() => _client.close();
}
