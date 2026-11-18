import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/brick/sync/queued_request.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/sync/data/mappers/sync_operation_kind_mapper.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/sync_queue_repository.dart';

/// Lee la cola offline de Brick y la traduce a operaciones de dominio.
///
/// La cola de Brick no avisa cuando reintenta, bloquea o borra una fila: lo
/// hace con su propio timer. Por eso, mientras haya alguien suscripto, se
/// vuelve a leer cada intervalo de consulta además de reaccionar a los cambios (escrituras
/// locales y respuestas del backend). Sin suscriptores no se consulta nada.
class SyncQueueRepositoryImpl implements SyncQueueRepository {
  /// Crea el repositorio.
  SyncQueueRepositoryImpl({
    required Future<List<BrickQueuedRequest>> Function() readQueue,
    required Stream<void> changes,
    Duration pollInterval = const Duration(seconds: 2),
    DateTime Function() now = DateTime.now,
  }) : _readQueue = readQueue,
       _changes = changes,
       _pollInterval = pollInterval,
       _now = now;

  final Future<List<BrickQueuedRequest>> Function() _readQueue;
  final Stream<void> _changes;
  final Duration _pollInterval;
  final DateTime Function() _now;

  @override
  Stream<SyncQueueSnapshot> watch() {
    late final StreamController<SyncQueueSnapshot> controller;
    StreamSubscription<void>? changesSubscription;
    Timer? pollTimer;
    SyncQueueSnapshot? lastSnapshot;
    var reading = false;
    var readAgain = false;

    Future<void> refresh() async {
      // Una lectura a la vez; si llega otro aviso mientras tanto, se relee
      // una sola vez al terminar para no perder el último estado.
      if (reading) {
        readAgain = true;
        return;
      }
      reading = true;
      try {
        do {
          readAgain = false;
          final requests = await _readQueue();
          if (controller.isClosed) return;
          final snapshot = SyncQueueSnapshot(
            operations: requests.map(operationFromRequest).toList(growable: false),
            readAt: _now(),
          );
          if (snapshot != lastSnapshot) {
            lastSnapshot = snapshot;
            controller.add(snapshot);
          }
        } while (readAgain && !controller.isClosed);
      } on Object catch (error, stackTrace) {
        debugPrint('[Sync queue] read failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        lastSnapshot = null;
        if (!controller.isClosed) {
          controller.addError(
            DomainException(message: 'No se pudo leer la cola de sincronización.', reason: error),
            stackTrace,
          );
        }
      } finally {
        reading = false;
      }
    }

    controller = StreamController<SyncQueueSnapshot>(
      onListen: () {
        unawaited(refresh());
        changesSubscription = _changes.listen((_) => unawaited(refresh()));
        pollTimer = Timer.periodic(_pollInterval, (_) => unawaited(refresh()));
      },
      onCancel: () async {
        pollTimer?.cancel();
        await changesSubscription?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  /// Traduce una request de la cola a la operación que ve el productor.
  @visibleForTesting
  static SyncQueueOperation operationFromRequest(BrickQueuedRequest request) {
    return SyncQueueOperation(
      queueId: request.queueId,
      kind: syncOperationKindFor(request.path, method: request.method),
      state: request.isLocked
          ? SyncOperationState.sending
          : request.attempts > 1
          ? SyncOperationState.retrying
          : SyncOperationState.waiting,
      attempts: request.attempts,
      queuedAt: request.createdAt,
      lastAttemptAt: request.updatedAt,
    );
  }
}
