import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/sync_activity_repository.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/sync_queue_repository.dart';

/// Estado de la vista de la cola de sincronización.
@immutable
class SyncQueueViewState {
  /// Crea el estado.
  const SyncQueueViewState({
    this.snapshot,
    this.isOnline,
    this.error,
    this.isSynchronizing = false,
    this.rejected = const [],
    this.recentlySent = const [],
  });

  /// Última foto leída de la cola; `null` hasta la primera lectura.
  final SyncQueueSnapshot? snapshot;

  /// Conectividad del dispositivo; `null` mientras no se conoce.
  final bool? isOnline;

  /// Error de la última lectura, si falló.
  final DomainException? error;

  /// `true` mientras corre una sincronización pedida a mano.
  final bool isSynchronizing;

  /// Registros que el backend rechazó, el más reciente primero.
  final List<SyncRejectedRecord> rejected;

  /// Registros aceptados por el backend en esta sesión, el más reciente primero.
  final List<SyncSentRecord> recentlySent;

  /// Cantidad de operaciones pendientes, 0 si todavía no se leyó la cola.
  int get pendingCount => snapshot?.pendingCount ?? 0;

  /// Copia el estado reemplazando los campos indicados.
  SyncQueueViewState copyWith({
    SyncQueueSnapshot? snapshot,
    bool? isOnline,
    DomainException? error,
    bool clearError = false,
    bool? isSynchronizing,
    List<SyncRejectedRecord>? rejected,
    List<SyncSentRecord>? recentlySent,
  }) {
    return SyncQueueViewState(
      snapshot: snapshot ?? this.snapshot,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : error ?? this.error,
      isSynchronizing: isSynchronizing ?? this.isSynchronizing,
      rejected: rejected ?? this.rejected,
      recentlySent: recentlySent ?? this.recentlySent,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SyncQueueViewState &&
      other.snapshot == snapshot &&
      other.isOnline == isOnline &&
      other.error == error &&
      other.isSynchronizing == isSynchronizing &&
      listEquals(other.rejected, rejected) &&
      listEquals(other.recentlySent, recentlySent);

  @override
  int get hashCode =>
      Object.hash(snapshot, isOnline, error, isSynchronizing, Object.hashAll(rejected), Object.hashAll(recentlySent));
}

/// Mantiene en vivo la cola de operaciones pendientes de sincronizar.
///
/// Los rechazados y el historial son opcionales: el indicador de la nube solo
/// necesita la cantidad de pendientes y no tiene por qué leer más tablas.
class SyncQueueCubit extends Cubit<SyncQueueViewState> {
  /// Crea el cubit y empieza a observar la cola y la conectividad.
  SyncQueueCubit({
    required SyncQueueRepository repository,
    required Stream<bool> connectivityChanges,
    required Future<bool> Function() synchronizeNow,
    SyncRejectionsRepository? rejections,
    SyncHistoryRepository? history,
  }) : _synchronizeNow = synchronizeNow,
       super(const SyncQueueViewState()) {
    _queueSubscription = repository.watch().listen(
      (snapshot) => emit(state.copyWith(snapshot: snapshot, clearError: true)),
      onError: (Object error) => emit(
        state.copyWith(
          error: error is DomainException
              ? error
              : const DomainException(message: 'No se pudo leer la cola de sincronización.'),
        ),
      ),
    );
    _connectivitySubscription = connectivityChanges.listen(
      (isOnline) => emit(state.copyWith(isOnline: isOnline)),
    );
    // Un error leyendo los rechazados no tapa la cola: se registra y la
    // sección queda con la última lectura buena.
    _rejectionsSubscription = rejections?.watch().listen(
      (records) => emit(state.copyWith(rejected: records)),
      onError: (Object error) => debugPrint('[Sync queue] rejections unavailable: $error'),
    );
    _historySubscription = history?.watch().listen(
      (records) => emit(state.copyWith(recentlySent: records)),
    );
  }

  final Future<bool> Function() _synchronizeNow;
  late final StreamSubscription<SyncQueueSnapshot> _queueSubscription;
  late final StreamSubscription<bool> _connectivitySubscription;
  StreamSubscription<List<SyncRejectedRecord>>? _rejectionsSubscription;
  StreamSubscription<List<SyncSentRecord>>? _historySubscription;

  /// Pide una sincronización inmediata. La cola se sigue vaciando sola; esto
  /// solo adelanta el próximo ciclo cuando el productor recupera señal.
  ///
  /// Devuelve `false` si el ciclo falló, para que la vista lo informe. Los
  /// registros siguen guardados en el teléfono en cualquier caso.
  Future<bool> synchronizeNow() async {
    if (state.isSynchronizing) return true;
    emit(state.copyWith(isSynchronizing: true));
    try {
      return await _synchronizeNow();
    } on Object catch (error, stackTrace) {
      debugPrint('[Sync queue] manual sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      if (!isClosed) emit(state.copyWith(isSynchronizing: false));
    }
  }

  @override
  Future<void> close() async {
    await _queueSubscription.cancel();
    await _connectivitySubscription.cancel();
    await _rejectionsSubscription?.cancel();
    await _historySubscription?.cancel();
    return super.close();
  }
}
