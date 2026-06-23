import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/brick/backend_access_token_provider.dart';
import 'package:http/http.dart' as http;

/// Result of a backend sync attempt for one locally persisted animal.
class AnimalSyncResult {
  /// Creates a sync result from a backend response.
  const AnimalSyncResult({
    required this.localId,
    required this.synchronized,
    this.errorCode,
  });

  /// Client-generated UUID used as the local and backend animal identity.
  final String localId;

  /// Whether the backend accepted the animal.
  final bool synchronized;

  /// Backend/domain error code when the animal was rejected.
  final String? errorCode;
}

/// Callback invoked after the backend answers an animal sync request.
typedef AnimalSyncResultHandler = Future<void> Function(AnimalSyncResult result);

/// Adds Bearer authentication and observes animal sync responses.
class AuthenticatedBackendClient extends http.BaseClient {
  /// Creates an authenticated backend client.
  AuthenticatedBackendClient({
    required BackendAccessTokenProvider tokenProvider,
    required AnimalSyncResultHandler onAnimalSyncResult,
    http.Client? inner,
  }) : _tokenProvider = tokenProvider,
       _onAnimalSyncResult = onAnimalSyncResult,
       _inner = inner ?? http.Client();

  final BackendAccessTokenProvider _tokenProvider;
  final AnimalSyncResultHandler _onAnimalSyncResult;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _tokenProvider.getAccessToken();
    if (token == null) {
      throw StateError('Backend access token is not available.');
    }

    request.headers['Authorization'] = 'Bearer $token';
    _logRequest(request);

    final animalId = _animalIdFromRequest(request);
    final response = await _inner.send(request);
    final bufferedResponse = await http.Response.fromStream(response);
    _logResponse(bufferedResponse);

    if (animalId != null && _isAnimalUpsert(request) && bufferedResponse.statusCode < 500) {
      await _onAnimalSyncResult(
        AnimalSyncResult(
          localId: animalId,
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

  Map<String, String> _redactedHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, 'Bearer <redacted>');
      }

      return MapEntry(key, value);
    });
  }

  bool _isAnimalUpsert(http.BaseRequest request) {
    return request.method == 'POST' && request.url.path.endsWith('/api/v1/animales');
  }

  String? _animalIdFromRequest(http.BaseRequest request) {
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
