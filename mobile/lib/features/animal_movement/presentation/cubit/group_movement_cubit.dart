import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_tag_kind.dart';
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
  Future<void> _tagReads = Future<void>.value();
  int _pendingTagReads = 0;

  /// Carga los animales iniciales y los destinos locales.
  Future<void> start(List<String> animalIds) async {
    emit(state.copyWith(preparation: const ResultState.loading()));
    final result = await _prepare(animalIds);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(preparation: ResultState.data(data), animals: data.animals));
      case Failure(:final error):
        emit(state.copyWith(preparation: ResultState.error(error)));
    }
  }

  /// Resuelve una lectura; indica si la pantalla puede limpiar el campo.
  Future<bool> addTag(String tag) async {
    if (isClosed || state.submission is Loading<GroupMovementSummary>) return false;
    final kind = state.tagKind;
    final previous = _tagReads;
    final completed = Completer<void>();
    _tagReads = completed.future;
    _pendingTagReads++;
    emit(state.copyWith(tagResolution: const ResultState.loading()));
    try {
      // El bastón puede repetir Enter antes de que termine SQLite. Resolver en
      // orden hace que el caso de uso vea siempre la selección más reciente.
      await previous;
      if (isClosed) return false;
      return await _resolveAndAddTag(tag, kind);
    } finally {
      _pendingTagReads--;
      completed.complete();
    }
  }

  Future<bool> _resolveAndAddTag(String tag, MovementTagKind kind) async {
    emit(state.copyWith(tagResolution: const ResultState.loading()));
    final result = await _resolveTag(
      tag: tag,
      kind: kind,
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

  /// Elige el identificador y limpia el error de la captura anterior.
  void selectTagKind(MovementTagKind kind) {
    if (_pendingTagReads > 0 || state.submission is Loading<GroupMovementSummary>) return;
    emit(state.copyWith(tagKind: kind, tagResolution: const ResultState.initial()));
  }

  /// Quita un animal de la selección.
  void remove(String animalId) {
    if (state.submission is Loading<GroupMovementSummary>) return;
    emit(
      state.copyWith(
        animals: [
          for (final animal in state.animals)
            if (animal.id != animalId) animal,
        ],
      ),
    );
  }

  /// Elige el potrero de destino.
  void selectDestination(String lotId) {
    if (state.submission is Loading<GroupMovementSummary>) return;
    emit(state.copyWith(destinationId: lotId, submission: const ResultState.initial()));
  }

  /// Cambia la fecha efectiva del movimiento.
  void selectDate(DateTime date) {
    if (state.submission is Loading<GroupMovementSummary>) return;
    emit(state.copyWith(occurredAt: date));
  }

  /// Registra la selección con el motivo indicado.
  Future<void> submit(String reason) async {
    if (state.submission is Loading<GroupMovementSummary> || _pendingTagReads > 0) return;
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
        final saved = state.savedSummary.combine(_withDestination(data, destinationId));
        emit(state.copyWith(savedSummary: saved, submission: ResultState.data(saved)));
      case Failure<GroupMovementSummary>(:final error):
        if (error.reason case MovementPartialFailure(:final movedCount, :final movedAnimalIds)) {
          final movedIds = movedAnimalIds.toSet();
          final saved = state.savedSummary.combine(
            _withDestination(
              GroupMovementSummary(movedCount: movedCount, alreadyThereCount: 0),
              destinationId,
            ),
          );
          emit(
            state.copyWith(
              savedSummary: saved,
              animals: [
                for (final animal in state.animals)
                  if (!movedIds.contains(animal.id)) animal,
              ],
              submission: ResultState.error(error),
            ),
          );
          return;
        }
        emit(state.copyWith(submission: ResultState.error(error)));
    }
  }

  GroupMovementSummary _withDestination(GroupMovementSummary summary, String destinationId) => summary.copyWith(
    destinations: {destinationId: state.destinations.where((lot) => lot.id == destinationId).first.name},
  );
}
