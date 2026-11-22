import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/sync_activity_repository.dart';

/// Observa los registros rechazados que quedaron guardados en el teléfono.
///
/// Un registro solo pasa a `rejected` cuando responde el backend, y deja de
/// estarlo cuando se corrige localmente, así que alcanza con releer ante cada
/// escritura local y cada respuesta del backend: no hace falta consultar
/// periódicamente como con la cola.
class SyncRejectionsRepositoryImpl implements SyncRejectionsRepository {
  /// Crea el repositorio.
  SyncRejectionsRepositoryImpl({
    required Future<List<SyncRejectedRecord>> Function() readRejected,
    required Stream<void> changes,
  }) : _readRejected = readRejected,
       _changes = changes;

  final Future<List<SyncRejectedRecord>> Function() _readRejected;
  final Stream<void> _changes;

  @override
  Stream<List<SyncRejectedRecord>> watch() {
    late final StreamController<List<SyncRejectedRecord>> controller;
    StreamSubscription<void>? changesSubscription;
    List<SyncRejectedRecord>? lastRecords;
    var reading = false;
    var readAgain = false;

    Future<void> refresh() async {
      if (reading) {
        readAgain = true;
        return;
      }
      reading = true;
      try {
        do {
          readAgain = false;
          final records = await _readRejected();
          if (controller.isClosed) return;
          if (lastRecords == null || !listEquals(records, lastRecords)) {
            lastRecords = records;
            controller.add(records);
          }
        } while (readAgain && !controller.isClosed);
      } on Object catch (error, stackTrace) {
        debugPrint('[Sync rejections] read failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        lastRecords = null;
        if (!controller.isClosed) {
          controller.addError(
            DomainException(message: 'No se pudieron leer los registros rechazados.', reason: error),
            stackTrace,
          );
        }
      } finally {
        reading = false;
      }
    }

    controller = StreamController<List<SyncRejectedRecord>>(
      onListen: () {
        unawaited(refresh());
        changesSubscription = _changes.listen((_) => unawaited(refresh()));
      },
      onCancel: () async {
        await changesSubscription?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }
}
