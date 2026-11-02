import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/errors/movement_failure.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/use_cases/animal_movement_use_cases.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/group_movement_state.dart';

/// Arma la selección por caravana y coordina el guardado sin conocer persistencia.
class GroupMovementCubit extends Cubit<GroupMovementState> {
  /// Crea el cubit con las operaciones del dominio.
  GroupMovementCubit({
    required PrepareGroupMovementUseCase prepare,
    required ResolveMovementTagUseCase resolveTag,
    required RegisterGroupMovementUseCase register,
  }) : _prepare = prepare,
       _resolveTag = resolveTag,
       _register = register,
       super(const GroupMovementState());

  final PrepareGroupMovementUseCase _prepare;
  final ResolveMovementTagUseCase _resolveTag;
  final RegisterGroupMovementUseCase _register;

  /// Carga el animal inicial y los destinos locales.
  Future<void> start(String animalId) async {
    emit(state.copyWith(preparation: const ResultState.loading()));
    final result = await _prepare(animalId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(preparation: ResultState.data(data), animals: [data.animal]));
      case Failure(:final error):
        emit(state.copyWith(preparation: ResultState.error(error)));
    }
  }

  /// Resuelve una lectura; indica si la pantalla puede limpiar el campo.
  Future<bool> addTag(String tag) async {
    emit(state.copyWith(tagResolution: const ResultState.loading()));
    final result = await _resolveTag(
      tag: tag,
      establishmentId: state.establishmentId,
      selectedIds: {for (final animal in state.animals) animal.id},
    );
    if (isClosed) return false;
    switch (result) {
      case Success<MovementAnimal>(:final data):
        emit(
          state.copyWith(
            animals: [...state.animals, data],
            tagResolution: ResultState.data(data),
            submission: const ResultState.initial(),
          ),
        );
        return true;
      case Failure<MovementAnimal>(:final error):
        emit(state.copyWith(tagResolution: ResultState.error(error)));
        return false;
    }
    return false;
  }

  /// Quita un animal de la selección.
  void remove(String animalId) => emit(
    state.copyWith(
      animals: [
        for (final animal in state.animals)
          if (animal.id != animalId) animal,
      ],
    ),
  );

  /// Elige el potrero de destino.
  void selectDestination(String lotId) =>
      emit(state.copyWith(destinationId: lotId, submission: const ResultState.initial()));

  /// Cambia la fecha efectiva del movimiento.
  void selectDate(DateTime date) => emit(state.copyWith(occurredAt: date));

  /// Registra la selección con el motivo indicado.
  Future<void> submit(String reason) async {
    final destinationId = state.destinationId;
    if (destinationId == null) {
      emit(
        state.copyWith(
          submission: ResultState.error(
            movementException(const MovementFailure.destinationRequired()),
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(submission: const ResultState.loading()));
    final result = await _register(
      establishmentId: state.establishmentId,
      animals: state.animals,
      destinationLotId: destinationId,
      occurredAt: state.occurredAt ?? DateTime.now(),
      reason: reason,
    );
    if (isClosed) return;
    switch (result) {
      case Success<GroupMovementSummary>(:final data):
        emit(state.copyWith(submission: ResultState.data(data)));
      case Failure<GroupMovementSummary>(:final error):
        emit(state.copyWith(submission: ResultState.error(error)));
    }
  }
}
