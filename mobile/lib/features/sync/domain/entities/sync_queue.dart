import 'package:flutter/foundation.dart';

/// Qué tipo de registro intenta llegar al backend.
enum SyncOperationKind {
  /// Alta de un animal.
  animalRegistration,

  /// Cambio sobre un animal ya existente.
  animalUpdate,

  /// Animal, cuando no se sabe si fue un alta o un cambio (por ejemplo, en
  /// un rechazo leído de SQLite).
  animal,

  /// Pesaje individual.
  weighing,

  /// Movimiento de animales entre lotes.
  lotMovement,

  /// Alta o edición de un lote.
  lot,

  /// Egreso operativo.
  operatingExpense,

  /// Categoría de egreso operativo.
  operatingExpenseCategory,

  /// Registro sanitario para uno o varios animales.
  healthEvent,

  /// Primer resultado informado de un estudio sanitario.
  healthResult,

  /// Recurso sin traducción conocida; se muestra igual para no ocultar nada.
  other,
}

/// En qué punto del envío está una operación.
enum SyncOperationState {
  /// Encolada, espera su turno o que vuelva la conexión.
  waiting,

  /// La cola la tomó y la está enviando ahora.
  sending,

  /// Ya falló al menos una vez por un error transitorio y se va a reintentar.
  retrying,
}

/// Una operación local que todavía no llegó al backend.
@immutable
class SyncQueueOperation {
  /// Crea la operación.
  const SyncQueueOperation({
    required this.queueId,
    required this.kind,
    required this.state,
    required this.attempts,
    required this.queuedAt,
    required this.lastAttemptAt,
  });

  /// Identificador estable dentro de la cola local.
  final int queueId;

  /// Tipo de registro.
  final SyncOperationKind kind;

  /// Estado del envío.
  final SyncOperationState state;

  /// Intentos de envío realizados.
  final int attempts;

  /// Momento en que se registró la operación offline.
  final DateTime queuedAt;

  /// Último intento de envío.
  final DateTime lastAttemptAt;

  @override
  bool operator ==(Object other) =>
      other is SyncQueueOperation &&
      other.queueId == queueId &&
      other.kind == kind &&
      other.state == state &&
      other.attempts == attempts &&
      other.queuedAt == queuedAt &&
      other.lastAttemptAt == lastAttemptAt;

  @override
  int get hashCode => Object.hash(queueId, kind, state, attempts, queuedAt, lastAttemptAt);
}

/// Foto de la cola de sincronización en un instante.
@immutable
class SyncQueueSnapshot {
  /// Crea la foto con las operaciones en el orden en que se van a enviar.
  const SyncQueueSnapshot({required this.operations, required this.readAt});

  /// Operaciones pendientes, la próxima en enviarse primero.
  final List<SyncQueueOperation> operations;

  /// Momento en que se leyó la cola.
  final DateTime readAt;

  /// Cantidad de operaciones que faltan llegar al backend.
  int get pendingCount => operations.length;

  /// `true` cuando no queda nada por enviar.
  bool get isEmpty => operations.isEmpty;

  /// `true` si alguna operación se está enviando en este momento.
  bool get isSending => operations.any((operation) => operation.state == SyncOperationState.sending);

  /// Dos fotos son iguales si tienen las mismas operaciones, sin importar
  /// cuándo se leyeron: así la UI no se redibuja en cada consulta periódica.
  @override
  bool operator ==(Object other) => other is SyncQueueSnapshot && listEquals(other.operations, operations);

  @override
  int get hashCode => Object.hashAll(operations);
}
