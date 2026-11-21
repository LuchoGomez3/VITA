import 'package:frontend_mayoral/brick/models/health_operation.model.dart';
import 'package:frontend_mayoral/features/health/data/repositories/health_repository_impl.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';

/// Presenta la actividad sanitaria con el contrato público de Sync.
class HealthSyncActivity {
  /// Resuelve el repositorio local cuando Sync solicita la actividad.
  const HealthSyncActivity(this._repository);

  final HealthRepositoryImpl? Function() _repository;

  /// Lee los pendientes de la sesión visible.
  Future<List<SyncQueueOperation>> readPending() async {
    final operations = await _repository()?.pendingOperations() ?? const [];
    return [
      for (final operation in operations)
        if (operation.primaryKey case final primaryKey?)
          SyncQueueOperation(
            // Las operaciones sanitarias usan una secuencia SQLite propia.
            queueId: -primaryKey,
            kind: _kind(operation),
            state: SyncOperationState.waiting,
            attempts: 0,
            queuedAt: operation.createdAt,
            lastAttemptAt: operation.createdAt,
          ),
    ];
  }

  /// Lee los rechazos definitivos de la sesión visible.
  Future<List<SyncRejectedRecord>> readRejected() async {
    final operations = await _repository()?.visibleOperations() ?? const [];
    return [
      for (final operation in operations)
        if (operation.rejection case final code?)
          SyncRejectedRecord(
            localId: operation.localId,
            kind: _kind(operation),
            recordedAt: operation.createdAt,
            errorCode: code,
          ),
    ];
  }

  static SyncOperationKind _kind(BrickHealthOperationModel operation) =>
      operation.resultEventId == null ? SyncOperationKind.healthEvent : SyncOperationKind.healthResult;
}
