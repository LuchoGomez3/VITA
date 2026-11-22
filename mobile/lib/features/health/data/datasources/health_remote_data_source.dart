import 'package:frontend_mayoral/brick/auth/guarded_backend_request.dart';
import 'package:frontend_mayoral/features/health/data/mappers/health_codec.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';

const _invalidResponseCode = 'respuesta_sanitaria_invalida';

/// Error remoto clasificado sin exponer datos sanitarios en logs.
class HealthRemoteFailure extends BackendRequestFailure {
  /// Conserva el estado HTTP y el motivo estable que devolvió el servidor.
  HealthRemoteFailure(BackendRequestFailure failure)
    : currentEvent = _conflictEvent(failure),
      rejection = HealthCodec.rejectionFrom(failure.details),
      super(failure.status, failure.code ?? _invalidResponseCode, details: failure.details);

  /// Resultado autoritativo de otra carga aceptada previamente.
  final HealthEvent? currentEvent;

  /// Animal o campo que permite orientar la corrección del registro.
  final HealthRejectionDetails? rejection;

  /// Un FastAPI anterior a Sanidad responde 404 sin código de dominio.
  bool get routeUnavailable => status == 404 && code == _invalidResponseCode;

  /// Se puede procesar como rechazo definitivo.
  @override
  bool get definitive => super.definitive || (status == 404 && code == 'evento_sanitario_no_encontrado');

  static HealthEvent? _conflictEvent(BackendRequestFailure failure) {
    final details = failure.details;
    final event = details is Map<String, dynamic> ? details['evento'] : null;
    return event is Map<String, dynamic> && failure.code == HealthCodec.resultAlreadyRecordedCode
        ? HealthCodec.eventFrom(event, remote: true)
        : null;
  }
}

/// Página de cambios del historial sanitario.
typedef HealthHistoryPage = ({List<HealthEvent> events, String cursor, bool hasMore});

/// Implementa el contrato de Sanidad con respuesta directa de cada mutación.
class HealthRemoteDataSource {
  /// Usa el transporte autenticado de Brick y conserva el envelope sanitario.
  const HealthRemoteDataSource(this._backend);

  static const _events = '/api/v1/eventos_sanitarios';
  final GuardedBackendRequest _backend;

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
    try {
      return await _backend(method, path, guard, query: query, body: body);
    } on BackendRequestFailure catch (error) {
      throw HealthRemoteFailure(error);
    }
  }
}
