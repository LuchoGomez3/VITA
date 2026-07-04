import 'dart:convert';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:http/http.dart' as http;

/// Cliente remoto de autenticacion contra el backend.
class AuthRemoteDataSource {
  /// Crea el cliente con la URL base del backend.
  const AuthRemoteDataSource({
    required String backendBaseUrl,
    required http.Client client,
  }) : _backendBaseUrl = backendBaseUrl,
       _client = client;

  final String _backendBaseUrl;
  final http.Client _client;

  /// Ejecuta el login OAuth2 password form y devuelve el token.
  Future<String> signIn({
    required String username,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/api/auth/login'),
      headers: const {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
      },
    );

    final body = _decodeResponse(response);
    if (response.statusCode == 401) {
      throw const DomainException(
        message: 'Usuario o contraseña incorrectos.',
        code: DomainErrorCode.unauthorized,
      );
    }

    _throwIfUnsuccessful(response, body);
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final accessToken = data['access_token'];
      if (accessToken is String && accessToken.isNotEmpty) {
        return accessToken;
      }
    }

    throw const DomainException(
      message: 'El backend no devolvió un token válido.',
    );
  }

  /// Lee el perfil asociado al token Bearer.
  Future<Map<String, dynamic>> getCurrentUser(String accessToken) async {
    final response = await _client.get(
      _uri('/api/auth/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final body = _decodeResponse(response);
    _throwIfUnsuccessful(response, body);
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const DomainException(
      message: 'El backend no devolvió el usuario autenticado.',
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
      message: 'El backend devolvió una respuesta inesperada.',
    );
  }

  void _throwIfUnsuccessful(
    http.Response response,
    Map<String, dynamic> body,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final detail = body['detail'];
    if (detail is String && detail.isNotEmpty) {
      throw DomainException(message: detail);
    }

    throw const DomainException(
      message: 'No se pudo iniciar sesión. Intentá nuevamente.',
    );
  }
}
