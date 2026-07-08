import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
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
    // Brick no sabe de sesiones. Antes de enviar al backend, este wrapper pide
    // el token vigente y lo agrega como Bearer.
    final token = await _tokenProvider.getAccessToken();
    if (token == null) {
      // Sin sesión disponible: lanzamos para que Brick retenga la request en la
      // cola hasta que exista sesión, en vez de perderla.
      throw StateError('Backend access token is not available.');
    }

    request.headers['Authorization'] = 'Bearer $token';
    _logRequest(request);

    // Si la request contiene un `id` cliente, la tratamos como sync-able. El
    // resultado se publica despues de recibir la response del backend.
    final syncRequest = _syncRequestFrom(request);
    var bufferedResponse = await _sendBuffered(request);

    // 401/403 al drenar la cola: lo más probable es que el access token venció
    // mientras el dispositivo estuvo offline. Intentamos renovar una vez y
    // reintentar con el token nuevo antes de dar la request por fallida.
    if (_isUnauthorized(bufferedResponse.statusCode) && request is http.Request) {
      final refreshedToken = await _tokenProvider.refreshAccessToken();
      if (refreshedToken != null) {
        bufferedResponse = await _sendBuffered(
          _cloneWithToken(request, refreshedToken),
        );
      }
    }

    _logResponse(bufferedResponse);

    if (_isUnauthorized(bufferedResponse.statusCode)) {
      // No se pudo autorizar (refresh muerto o sin red). Lanzamos para que Brick
      // RETENGA la request en la cola y la reintente tras el próximo login.
      // Nunca la marcamos como rechazada: perder una operación hecha en el campo
      // por un token vencido es justo lo que el offline-first debe evitar.
      throw StateError(
        'Sesión no autorizada al sincronizar; request retenida para reintentar.',
      );
    }

    // Los errores 5xx son transitorios: Brick debe conservar la request en cola
    // y reintentar. Los 2xx/4xx funcionales (validación, conflicto) se informan
    // al store para marcar synchronized o rejected en SQLite.
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

  bool _isUnauthorized(int statusCode) =>
      statusCode == 401 || statusCode == 403;

  /// Envía la request y buffea la response para poder leer el body una vez,
  /// loguearlo y, si hace falta, reintentar tras renovar el token.
  Future<http.Response> _sendBuffered(http.BaseRequest request) async {
    final response = await _inner.send(request);
    return http.Response.fromStream(response);
  }

  /// Copia una request ya enviada para reintentarla con un token nuevo.
  ///
  /// Una `http.Request` no se puede reenviar tras finalizarse, por eso se clona
  /// método, url, headers (con el Authorization renovado) y bytes del body.
  http.Request _cloneWithToken(http.Request original, String token) {
    return http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..headers['Authorization'] = 'Bearer $token'
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection
      ..bodyBytes = original.bodyBytes;
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

/// Datos minimos de una request sync-able observada por el cliente HTTP.
class _ObservedSyncRequest {
  const _ObservedSyncRequest({
    required this.resourcePath,
    required this.localId,
  });

  final String resourcePath;
  final String localId;
}
