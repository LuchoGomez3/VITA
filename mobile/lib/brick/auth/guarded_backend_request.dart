import 'dart:convert';

import 'package:frontend_mayoral/brick/auth/authenticated_backend_client.dart';
import 'package:http/http.dart' as http;

/// Rechazo del contrato StandardResponse de FastAPI.
class BackendRequestFailure implements Exception {
  /// Conserva los datos técnicos para el adaptador que interpreta cada recurso.
  const BackendRequestFailure(this.status, this.code, {this.details});

  /// Estado HTTP remoto.
  final int status;

  /// Código funcional remoto, si el servidor devolvió un envelope.
  final String? code;

  /// Detalles específicos del recurso.
  final Object? details;

  /// El servidor rechazó definitivamente la escritura.
  bool get definitive => const {400, 403, 409, 410, 422}.contains(status);
}

/// Lee respuestas de FastAPI usando el transporte autenticado de Brick.
class GuardedBackendRequest {
  /// Comparte el cliente y permite que el dueño de la operación la reconcilie.
  const GuardedBackendRequest({required this.baseUrl, required this.send});

  /// URL del backend configurado.
  final String baseUrl;

  /// Transporte de Brick protegido por la sesión de la operación.
  final GuardedBackendSender send;

  /// Envía una solicitud y devuelve su envelope de éxito.
  Future<Map<String, dynamic>> call(
    String method,
    String path,
    Future<void> Function() guard, {
    Map<String, String>? query,
    String? body,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path').replace(queryParameters: query));
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = body;
    }
    final response = await send(request, guard: guard);
    final succeeded = response.statusCode >= 200 && response.statusCode < 300;
    Map<String, dynamic>? envelope;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) envelope = decoded;
    } on FormatException {
      if (succeeded) rethrow;
    }
    if (succeeded && envelope?['success'] == true) return envelope!;
    final errors = envelope?['errors'];
    final error = errors is List ? errors.whereType<Map<String, dynamic>>().firstOrNull : null;
    throw BackendRequestFailure(response.statusCode, error?['code'] as String?, details: error?['details']);
  }
}
