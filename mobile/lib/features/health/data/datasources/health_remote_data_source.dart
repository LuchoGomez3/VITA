import 'dart:convert';

import 'package:frontend_mayoral/brick/auth/authenticated_backend_client.dart';
import 'package:frontend_mayoral/features/health/data/mappers/health_codec.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:http/http.dart' as http;

const _invalidResponseCode = 'respuesta_sanitaria_invalida';

/// Error remoto clasificado sin exponer datos sanitarios en logs.
class HealthRemoteFailure implements Exception {
  /// Conserva el estado HTTP y el motivo estable que devolvió el servidor.
  const HealthRemoteFailure(this.status, this.code, {this.currentEvent, this.rejection});

  /// Estado HTTP.
  final int status;

  /// Código funcional de la respuesta.
  final String code;

  /// Resultado autoritativo de otra carga aceptada previamente.
  final HealthEvent? currentEvent;

  /// Animal o campo que permite orientar la corrección del registro.
  final HealthRejectionDetails? rejection;

  /// Un FastAPI anterior a Sanidad responde 404 sin código de dominio.
  bool get routeUnavailable => status == 404 && code == _invalidResponseCode;

  /// Se puede procesar como rechazo definitivo.
  bool get definitive =>
      status == 400 ||
      status == 403 ||
      status == 409 ||
      status == 410 ||
      status == 422 ||
      (status == 404 && code == 'evento_sanitario_no_encontrado');
}

/// Página de cambios del historial sanitario.
typedef HealthHistoryPage = ({List<HealthEvent> events, String cursor, bool hasMore});

/// Implementa el contrato de Sanidad con respuesta directa de cada mutación.
class HealthRemoteDataSource {
  /// Usa el transporte autenticado de Brick y conserva el envelope sanitario.
  const HealthRemoteDataSource({
    required String baseUrl,
    required GuardedBackendSender send,
  }) : _baseUrl = baseUrl,
       _send = send;

  static const _events = '/api/v1/eventos_sanitarios';
  static const _animals = '/api/v1/animales';
  final String _baseUrl;
  final GuardedBackendSender _send;

  /// Actualiza las prácticas y productos que el establecimiento tiene habilitados.
  Future<HealthCatalog> catalog(String establishmentId, Future<void> Function() guard) async {
    final response = await _request(
      'GET',
      '$_events/catalogo',
      guard,
      query: {'establecimiento_id': establishmentId},
    );
    return HealthCodec.catalogFrom(response['data'] as Map<String, dynamic>, establishmentId);
  }

  /// Descarga los eventos desde el último cursor confirmado.
  Future<HealthHistoryPage> history(String establishmentId, String? cursor, Future<void> Function() guard) async {
    final response = await _request(
      'GET',
      _events,
      guard,
      query: {'establecimiento_id': establishmentId, if (cursor != null) 'cursor': cursor},
    );
    final meta = response['meta'] as Map<String, dynamic>;
    return (
      events: _eventsFrom(response['data']),
      cursor: meta['next_cursor'] as String,
      hasMore: meta['has_more'] as bool,
    );
  }

  /// Registra el grupo o completa el resultado del evento objetivo.
  Future<List<HealthEvent>> submit(String body, Future<void> Function() guard, {String? resultEventId}) async {
    if (resultEventId == null) {
      final response = await _request('POST', _events, guard, body: body);
      return _eventsFrom(response['data']);
    }
    final response = await _request('PUT', '$_events/$resultEventId/resultado', guard, body: body);
    return [HealthCodec.eventFrom(response['data'] as Map<String, dynamic>, remote: true)];
  }

  /// Comprueba que el UUID se haya creado en el establecimiento correcto.
  Future<bool> hasAnimal(String id, String establishmentId, Future<void> Function() guard) async {
    try {
      final data = (await _request('GET', '$_animals/$id', guard))['data'] as Map<String, dynamic>;
      return data['id'] == id && data['establecimiento_id'] == establishmentId && data['deleted_at'] == null;
    } on HealthRemoteFailure catch (error) {
      if (error.status == 404) return false;
      rethrow;
    }
  }

  /// Recupera un alta local por el mismo endpoint y UUID del flujo animal.
  Future<Map<String, dynamic>> recoverAnimal(String body, Future<void> Function() guard) async =>
      (await _request('POST', _animals, guard, body: body))['data'] as Map<String, dynamic>;

  static List<HealthEvent> _eventsFrom(Object? values) {
    if (values is! List) throw const FormatException('Invalid health event list');
    return values.cast<Map<String, dynamic>>().map((item) => HealthCodec.eventFrom(item, remote: true)).toList();
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path,
    Future<void> Function() guard, {
    Map<String, String>? query,
    String? body,
  }) async {
    final request = http.Request(method, Uri.parse('$_baseUrl$path').replace(queryParameters: query));
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = body;
    }
    return _decode(await _send(request, guard: guard));
  }

  static Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic>? envelope;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) envelope = decoded;
    } on FormatException {
      if (response.statusCode >= 200 && response.statusCode < 300) rethrow;
    }
    if (response.statusCode >= 200 && response.statusCode < 300 && envelope?['success'] == true) {
      return envelope!;
    }
    final errors = envelope?['errors'];
    final error = errors is List ? errors.whereType<Map<String, dynamic>>().firstOrNull : null;
    final code = error?['code'] as String? ?? _invalidResponseCode;
    final details = error?['details'];
    final currentEvent = details is Map<String, dynamic> ? details['evento'] : null;
    throw HealthRemoteFailure(
      response.statusCode,
      code,
      rejection: HealthCodec.rejectionFrom(details),
      currentEvent: currentEvent is Map<String, dynamic> && code == 'resultado_ya_completado'
          ? HealthCodec.eventFrom(currentEvent, remote: true)
          : null,
    );
  }
}
