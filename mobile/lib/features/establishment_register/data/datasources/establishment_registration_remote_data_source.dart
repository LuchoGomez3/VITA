import 'dart:convert';

import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/establishment_register/data/mappers/establishment_registration_json_mapper.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:http/http.dart' as http;

/// Cliente remoto del alta de establecimiento contra el backend.
///
/// A diferencia de `AuthRemoteDataSource`, preserva el `code` de dominio que
/// devuelve el backend en vez de colapsarlo todo a `validation`: la UI
/// necesita distinguir `renspa_duplicado` (conflicto, vuelve al paso 2) del
/// resto de los errores de formato.
class EstablishmentRegistrationRemoteDataSource {
  /// Crea el cliente remoto con la URL base y el proveedor de token.
  const EstablishmentRegistrationRemoteDataSource({
    required String backendBaseUrl,
    required BackendAccessTokenProvider tokenProvider,
    required http.Client client,
    Duration requestTimeout = const Duration(seconds: 15),
  }) : _backendBaseUrl = backendBaseUrl,
       _tokenProvider = tokenProvider,
       _client = client,
       _requestTimeout = requestTimeout;

  final String _backendBaseUrl;
  final BackendAccessTokenProvider _tokenProvider;
  final http.Client _client;
  final Duration _requestTimeout;

  /// Crea el establecimiento y devuelve el JSON confirmado por el backend.
  Future<Map<String, dynamic>> register(
    EstablishmentRegistration registration,
  ) async {
    final token = await _tokenProvider.getAccessToken();
    if (token == null) {
      throw const DomainException(
        message: 'No hay una sesion activa para registrar el establecimiento.',
        code: DomainErrorCode.unauthorized,
      );
    }

    final response = await _client
        .post(
          Uri.parse('$_backendBaseUrl/api/v1/establecimientos'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(EstablishmentRegistrationJsonMapper.toJson(registration)),
        )
        .timeout(_requestTimeout);

    final body = _decodeResponse(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }

      throw const DomainException(
        message: 'El backend no devolvio el establecimiento creado.',
      );
    }

    throw _errorFromBody(body);
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

  DomainException _errorFromBody(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;
      if (firstError is Map<String, dynamic>) {
        final message = firstError['message'];
        final code = firstError['code'];
        if (message is String && message.isNotEmpty) {
          return DomainException(
            message: message,
            code: _domainCodeFor(code is String ? code : null),
          );
        }
      }
    }

    return const DomainException(
      message: 'No se pudo registrar el establecimiento. Intenta nuevamente.',
    );
  }

  DomainErrorCode _domainCodeFor(String? backendCode) {
    return switch (backendCode) {
      'renspa_duplicado' => DomainErrorCode.conflict,
      'renspa_formato_invalido' ||
      'cuit_invalido' ||
      'superficie_invalida' ||
      'renspa_vacio' => DomainErrorCode.validation,
      _ => DomainErrorCode.unknown,
    };
  }
}
