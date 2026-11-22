import 'package:brick_offline_first_with_rest/offline_queue.dart';
import 'package:flutter/foundation.dart';

/// Request REST que sigue en la cola offline de Brick.
///
/// Expone solo metadatos: nunca headers ni body, porque la fila persistida
/// puede contener el payload completo del productor. Las features deciden
/// cómo nombrar la operación a partir de [method] y [path].
@immutable
class BrickQueuedRequest {
  /// Crea la vista de una fila de la cola.
  const BrickQueuedRequest({
    required this.queueId,
    required this.method,
    required this.path,
    required this.attempts,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Construye la vista desde una fila de `RestRequestSqliteCacheManager`.
  factory BrickQueuedRequest.fromQueueRow(Map<String, dynamic> row) {
    final url = row[HTTP_JOBS_URL_COLUMN];
    return BrickQueuedRequest(
      queueId: row[HTTP_JOBS_PRIMARY_KEY_COLUMN] as int,
      method: (row[HTTP_JOBS_REQUEST_METHOD_COLUMN] as String?)?.toUpperCase() ?? '',
      path: url is String ? Uri.tryParse(url)?.path ?? '' : '',
      attempts: row[HTTP_JOBS_ATTEMPTS_COLUMN] as int? ?? 1,
      isLocked: row[HTTP_JOBS_LOCKED_COLUMN] == 1,
      createdAt: _dateFromMillis(row[HTTP_JOBS_CREATED_AT_COLUMN]),
      updatedAt: _dateFromMillis(row[HTTP_JOBS_UPDATED_AT]),
    );
  }

  /// Clave autoincremental de la fila en la cola SQLite.
  final int queueId;

  /// Método HTTP en mayúsculas (`POST`, `PUT`, ...).
  final String method;

  /// Path del recurso, sin host ni query, por ejemplo `/api/v1/pesajes`.
  final String path;

  /// Intentos de envío realizados; Brick arranca en 1 al encolar.
  final int attempts;

  /// `true` mientras la cola tiene tomada la request para reenviarla.
  final bool isLocked;

  /// Momento en que se encoló la request.
  final DateTime createdAt;

  /// Último intento de envío o cambio de estado de la fila.
  final DateTime updatedAt;

  static DateTime _dateFromMillis(Object? value) => DateTime.fromMillisecondsSinceEpoch(value is int ? value : 0);

  @override
  bool operator ==(Object other) =>
      other is BrickQueuedRequest &&
      other.queueId == queueId &&
      other.method == method &&
      other.path == path &&
      other.attempts == attempts &&
      other.isLocked == isLocked &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(queueId, method, path, attempts, isLocked, createdAt, updatedAt);
}
