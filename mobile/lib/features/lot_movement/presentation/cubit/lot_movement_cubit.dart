import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/entities/lot_movement.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/use_cases/lot_movement_use_cases.dart';

part 'lot_movement_cubit.freezed.dart';

/// Selección y operaciones independientes, con estados asíncronos del proyecto.
@freezed
sealed class LotMovementState with _$LotMovementState {
  /// sourceLotId null representa únicamente los animales sin lote.
  const factory LotMovementState({
    @Default(ResultState<MovementContext>.initial()) ResultState<MovementContext> context,
    @Default(ResultState<AnimalLotMovement>.initial()) ResultState<AnimalLotMovement> saving,
    @Default(ResultState<void>.initial()) ResultState<void> retrying,
    @Default(<String>[]) List<String> selectedIds,
    String? sourceLotId,
    @Default(false) bool refreshing,
  }) = _LotMovementState;
}

/// Coordina selección y guardado usando exclusivamente casos de uso.
class LotMovementCubit extends Cubit<LotMovementState> {
  /// La ficha puede preseleccionar un animal; campo puede fijar el lote de origen.
  LotMovementCubit({
    required String establishmentId,
    required LoadMovementContextUseCase loadContext,
    required SaveLotMovementUseCase saveMovement,
    required RetryLotMovementUseCase retryMovement,
    String? initialAnimalId,
    String? sourceLotId,
  }) : _establishmentId = establishmentId,
       _load = loadContext,
       _save = saveMovement,
       _retry = retryMovement,
       _initialAnimalId = initialAnimalId,
       super(LotMovementState(sourceLotId: sourceLotId)) {
    _subscription = _load.changes.listen((_) {
      // El pull ya termina leyendo SQLite; sus eventos intermedios no deben
      // invalidar la carga remota ni ocultar el aviso de trabajo con caché.
      if (!state.refreshing) unawaited(load());
    });
  }
  final String _establishmentId;
  final LoadMovementContextUseCase _load;
  final SaveLotMovementUseCase _save;
  final RetryLotMovementUseCase _retry;
  String? _initialAnimalId;
  late final StreamSubscription<void> _subscription;
  int _loadVersion = 0;

  /// Primero lee SQLite; la consulta remota conserva la selección y la pantalla.
  Future<void> load({bool refreshRemote = false}) async {
    final version = ++_loadVersion;
    if (state.context is! Data<MovementContext>) emit(state.copyWith(context: const ResultState.loading()));
    if (refreshRemote) emit(state.copyWith(refreshing: true));
    final result = await _load(_establishmentId, refreshRemote: refreshRemote);
    if (isClosed || version != _loadVersion) return;
    switch (result) {
      case Failure(:final error):
        emit(state.copyWith(context: ResultState.error(error), refreshing: false));
      case Success(:final data):
        final initial = data.animals.where((a) => a.id == _initialAnimalId).firstOrNull;
        if (initial != null) _initialAnimalId = null;
        emit(
          state.copyWith(
            context: ResultState.data(
              !refreshRemote && state.context is Data<MovementContext>
                  ? data.copyWith(usingCachedData: (state.context as Data<MovementContext>).data.usingCachedData)
                  : data,
            ),
            refreshing: false,
            sourceLotId: initial == null ? state.sourceLotId : initial.lotId,
            selectedIds: initial == null
                ? state.selectedIds
                : initial.canMove
                ? [initial.id]
                : [],
          ),
        );
    }
  }

  /// Cambiar de grupo limpia la selección para no mezclar lotes de origen.
  void selectOrigin(String? lotId) {
    if (state.saving is Loading<AnimalLotMovement>) return;
    _initialAnimalId = null;
    emit(state.copyWith(sourceLotId: lotId, selectedIds: [], saving: const ResultState.initial()));
  }

  /// Sólo permite seleccionar animales del grupo activo y sin otro traslado abierto.
  void selectAnimal(MovementAnimal animal, {required bool selected}) {
    if (state.saving is Loading<AnimalLotMovement> || !animal.canMove || animal.lotId != state.sourceLotId) return;
    final ids = state.selectedIds.toSet();
    if (selected) {
      ids.add(animal.id);
    } else {
      ids.remove(animal.id);
    }
    emit(state.copyWith(selectedIds: ids.toList(), saving: const ResultState.initial()));
  }

  /// Bloquea envíos duplicados mientras la transacción local está en curso.
  Future<void> save({required String destinationLotId, required DateTime occurredAt, required String reason}) async {
    if (state.saving is Loading<AnimalLotMovement>) return;
    emit(state.copyWith(saving: const ResultState.loading()));
    final result = await _save(
      establishmentId: _establishmentId,
      sourceLotId: state.sourceLotId,
      destinationLotId: destinationLotId,
      animalIds: state.selectedIds,
      occurredAt: occurredAt,
      reason: reason,
    );
    if (isClosed) return;
    switch (result) {
      case Failure(:final error):
        emit(state.copyWith(saving: ResultState.error(error)));
      case Success(:final data):
        emit(state.copyWith(saving: ResultState.data(data), selectedIds: []));
        await load();
    }
  }

  /// Usa el ID del historial; el reintento no ejecuta de nuevo el movimiento local.
  Future<void> retry(String movementId) async {
    if (state.retrying is Loading<void>) return;
    emit(state.copyWith(retrying: const ResultState.loading()));
    final result = await _retry(movementId);
    if (isClosed) return;
    switch (result) {
      case Failure(:final error):
        emit(state.copyWith(retrying: ResultState.error(error)));
      case Success():
        emit(state.copyWith(retrying: const ResultState.data(null)));
    }
    await load();
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
