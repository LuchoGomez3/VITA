import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:http/http.dart' as http;

/// Cliente HTTP usado por Brick para hablar con el backend autenticado.
///
/// Responsabilidades:
/// - Pedir el JWT actual a [BackendAccessTokenProvider].
/// - Agregar `Authorization: Bearer <token>` a cada request.
/// - Loguear request/response en debug para poder auditar el sync.
/// - Observar respuestas de requests sync-able y publicar [BackendSyncResult].
///
/// Este cliente no guarda nada en SQLite. Solo mira lo que pasa en la capa HTTP;
/// los stores de cada entidad deciden que hacer con el resultado.
class AuthenticatedBackendClient extends http.BaseClient {
  /// Crea un cliente HTTP autenticado para el [RestProvider] de Brick.
  ///
  /// [inner] permite inyectar un cliente falso en tests. En runtime se usa el
  /// cliente HTTP real por defecto.
  AuthenticatedBackendClient({
    required BackendAccessTokenProvider tokenProvider,
    required BackendSyncResultHandler onSyncResult,
    http.Client? inner,
  }) : _tokenProvider = tokenProvider,
       _onSyncResult = onSyncResult,
       _inner = inner ?? http.Client();

  final BackendAccessTokenProvider _tokenProvider;
  final BackendSyncResultHandler _onSyncResult;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final syncRequest = _syncRequestFrom(request);

    // Brick no sabe de sesiones. Antes de enviar al backend, este wrapper pide
    // el token vigente y lo agrega como Bearer.
    String? token;
    try {
      token = await _resolveAccessToken(
        request: request,
        syncRequest: syncRequest,
      );
    } on _TransientBackendAuthException catch (error) {
      return error.response;
    }
    if (token == null) {
      return _syntheticResponse(
        request: request,
        syncRequest: syncRequest,
        statusCode: 401,
        body: const {'error': 'auth_error'},
      );
    }

    request.headers['Authorization'] = 'Bearer $token';
    _logRequest(request);

    // Si la request contiene un `id` cliente, la tratamos como sync-able. El
    // resultado se publica despues de recibir la response del backend.
    final response = await _inner.send(request);

    // Convertimos a Response para poder leer el body una vez, loguearlo y
    // parsear errores. Luego reconstruimos StreamedResponse porque BaseClient
    // debe devolver ese tipo.
    final bufferedResponse = await http.Response.fromStream(response);
    _logResponse(bufferedResponse);

    // Los errores 5xx son transitorios: Brick debe conservar la request en cola
    // y reintentar. Los 2xx/4xx se informan al store para marcar synchronized o
    // rejected en SQLite.
    if (syncRequest != null && bufferedResponse.statusCode < 500) {
      await _onSyncResult(
        BackendSyncResult(
          resourcePath: syncRequest.resourcePath,
          localId: syncRequest.localId,
          synchronized: bufferedResponse.statusCode >= 200 && bufferedResponse.statusCode < 300,
          errorCode: _errorCodeFromResponse(bufferedResponse),
        ),
      );
    }

    return http.StreamedResponse(
      Stream<List<int>>.value(bufferedResponse.bodyBytes),
      bufferedResponse.statusCode,
      contentLength: bufferedResponse.contentLength,
      request: bufferedResponse.request,
      headers: bufferedResponse.headers,
      isRedirect: bufferedResponse.isRedirect,
      persistentConnection: bufferedResponse.persistentConnection,
      reasonPhrase: bufferedResponse.reasonPhrase,
    );
  }

  Future<String?> _resolveAccessToken({
    required http.BaseRequest request,
    required _ObservedSyncRequest? syncRequest,
  }) async {
    try {
      return await _tokenProvider.getAccessToken();
    } on DomainException catch (error) {
      if (error.code == DomainErrorCode.unauthorized) {
        return null;
      }

      throw _TransientBackendAuthException(
        _syntheticResponse(
          request: request,
          syncRequest: syncRequest,
          statusCode: 503,
          body: const {'error': 'offline'},
        ),
      );
    }
  }

  http.StreamedResponse _syntheticResponse({
    required http.BaseRequest request,
    required _ObservedSyncRequest? syncRequest,
    required int statusCode,
    required Map<String, Object?> body,
  }) {
    final encodedBody = jsonEncode(body);
    final response = http.Response(
      encodedBody,
      statusCode,
      request: request,
      headers: const {'content-type': 'application/json'},
    );
    _logResponse(response);

    if (syncRequest != null && statusCode < 500) {
      unawaited(
        _onSyncResult(
          BackendSyncResult(
            resourcePath: syncRequest.resourcePath,
            localId: syncRequest.localId,
            synchronized: false,
            errorCode: _errorCodeFromResponse(response),
          ),
        ),
      );
    }

    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  /// Imprime la request solo en debug.
  ///
  /// El header Authorization se redacta para no mostrar tokens en consola.
  void _logRequest(http.BaseRequest request) {
    if (!kDebugMode) {
      return;
    }

    final buffer = StringBuffer()
      ..writeln('[Backend HTTP] --> ${request.method} ${request.url}')
      ..writeln('[Backend HTTP] headers: ${_redactedHeaders(request.headers)}');

    if (request is http.Request && request.body.isNotEmpty) {
      buffer.writeln('[Backend HTTP] body: ${request.body}');
    }

    debugPrint(buffer.toString());
  }

  /// Imprime la response solo en debug.
  ///
  /// Esto es clave mientras se integra Brick porque permite ver payloads reales
  /// y errores del backend desde la Debug Console.
  void _logResponse(http.Response response) {
    if (!kDebugMode) {
      return;
    }

    final buffer = StringBuffer()
      ..writeln('[Backend HTTP] <-- ${response.statusCode} ${response.request?.url}')
      ..writeln('[Backend HTTP] headers: ${_redactedHeaders(response.headers)}');

    if (response.body.isNotEmpty) {
      buffer.writeln('[Backend HTTP] body: ${response.body}');
    }

    debugPrint(buffer.toString());
  }

  /// Oculta valores sensibles antes de escribir headers en consola.
  Map<String, String> _redactedHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, 'Bearer <redacted>');
      }

      return MapEntry(key, value);
    });
  }

  /// Detecta si una request puede generar un resultado de sync local.
  ///
  /// Por ahora observamos `POST` con un `id` en el body, que es el caso del alta
  /// offline-first. El path queda generico para que cada store filtre su recurso.
  _ObservedSyncRequest? _syncRequestFrom(http.BaseRequest request) {
    if (request.method != 'POST') {
      return null;
    }

    final localId = _localIdFromRequest(request);
    if (localId == null) {
      return null;
    }

    return _ObservedSyncRequest(
      resourcePath: request.url.path,
      localId: localId,
    );
  }

  /// Extrae el UUID cliente enviado al backend como `id`.
  ///
  /// Ese id es el puente entre la response remota y el registro guardado en
  /// SQLite, por ejemplo para pasar de `pending` a `synchronized`.
  String? _localIdFromRequest(http.BaseRequest request) {
    if (request is! http.Request || request.body.isEmpty) {
      return null;
    }

    final decoded = _decodeJson(request.body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final id = decoded['id'];
    return id is String && id.isNotEmpty ? id : null;
  }

  /// Normaliza errores del backend a un codigo simple para guardar localmente.
  ///
  /// El backend usa `StandardResponse.errors[].code` para errores funcionales.
  /// Si llega una validacion FastAPI tradicional, se marca como
  /// `validation_error`. Si falla auth con formato legacy, se marca `auth_error`.
  String? _errorCodeFromResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return null;
    }

    final decoded = _decodeJson(response.body);
    if (decoded is Map<String, dynamic>) {
      final errors = decoded['errors'];
      if (errors is List && errors.isNotEmpty) {
        final firstError = errors.first;
        if (firstError is Map<String, dynamic>) {
          final code = firstError['code'];
          if (code is String && code.isNotEmpty) {
            return code;
          }
        }
      }

      final detail = decoded['detail'];
      if (detail is List) {
        return 'validation_error';
      }

      final error = decoded['error'];
      if (error is String && error.isNotEmpty) {
        return 'auth_error';
      }
    }

    return 'sync_failed';
  }

  /// Intenta decodificar JSON sin romper el flujo si el body no es JSON.
  Object? _decodeJson(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class _TransientBackendAuthException implements Exception {
  const _TransientBackendAuthException(this.response);

  final http.StreamedResponse response;
}

/// Datos minimos de una request sync-able observada por el cliente HTTP.
class _ObservedSyncRequest {
  const _ObservedSyncRequest({
    required this.resourcePath,
    required this.localId,
  });

  final String resourcePath;
  final String localId;
}
