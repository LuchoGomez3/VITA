import 'dart:async';

import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:frontend_mayoral/features/sync/data/mappers/sync_operation_kind_mapper.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/sync_activity_repository.dart';

/// Recuerda en memoria los últimos registros que el backend aceptó.
///
/// Brick no guarda historial: al recibir un 2xx borra la request de la cola.
/// Por eso este registrador escucha las respuestas desde que arranca la app y
/// conserva las últimas [capacity]. El historial es de la sesión: no se
/// persiste y se pierde al cerrar la app, que es lo esperable para "enviados
/// recientemente". Los rechazos no se guardan acá: viven en SQLite.
class SyncHistoryRecorder implements SyncHistoryRepository {
  /// Crea el registrador; no escucha nada hasta [start].
  SyncHistoryRecorder({
    required Stream<BackendSyncResult> results,
    this.capacity = 20,
    DateTime Function() now = DateTime.now,
  }) : _results = results,
       _now = now;

  final Stream<BackendSyncResult> _results;
  final DateTime Function() _now;
  final _changes = StreamController<List<SyncSentRecord>>.broadcast();
  StreamSubscription<BackendSyncResult>? _subscription;
  List<SyncSentRecord> _records = const [];

  /// Cantidad máxima de envíos que se recuerdan.
  final int capacity;

  /// Empieza a escuchar las respuestas del backend. Llamarlo dos veces no
  /// duplica la suscripción.
  void start() {
    _subscription ??= _results.listen(_onResult);
  }

  void _onResult(BackendSyncResult result) {
    if (!result.synchronized) return;
    final record = SyncSentRecord(
      localId: result.localId,
      kind: syncOperationKindFor(result.resourcePath),
      sentAt: _now(),
    );
    _records = List.unmodifiable([record, ..._records].take(capacity));
    _changes.add(_records);
  }

  @override
  Stream<List<SyncSentRecord>> watch() async* {
    yield _records;
    yield* _changes.stream;
  }

  /// Deja de escuchar y cierra el stream de cambios.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _changes.close();
  }
}
