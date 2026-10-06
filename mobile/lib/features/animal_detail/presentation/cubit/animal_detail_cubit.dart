import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_change.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/retry_animal_sync_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/save_animal_detail_change_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_state.dart';

/// Coordina lecturas y ediciones mediante casos de uso, sin acceso directo a Brick.
class AnimalDetailCubit extends Cubit<AnimalDetailState> {
  /// Recibe los casos de uso que resuelve el composition root.
  AnimalDetailCubit({
    required GetAnimalDetailUseCase getAnimalDetailUseCase,
    required SaveAnimalDetailChangeUseCase saveChangeUseCase,
    RetryAnimalSyncUseCase? retryAnimalSyncUseCase,
  }) : _getAnimalDetailUseCase = getAnimalDetailUseCase,
       _saveChangeUseCase = saveChangeUseCase,
       _retryAnimalSyncUseCase = retryAnimalSyncUseCase,
       super(const AnimalDetailState());

  final GetAnimalDetailUseCase _getAnimalDetailUseCase;
  final SaveAnimalDetailChangeUseCase _saveChangeUseCase;
  final RetryAnimalSyncUseCase? _retryAnimalSyncUseCase;

  /// Carga la ficha; una edición en curso conserva la propiedad del estado.
  Future<void> loadAnimalData(String animalId) async {
    if (state.saving is Loading<AnimalDetail>) return;
    emit(state.copyWith(detail: const ResultState.loading()));
    final result = await _getAnimalDetailUseCase(animalId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(detail: ResultState.data(data)));
      case Failure(:final error):
        emit(state.copyWith(detail: ResultState.error(error)));
    }
  }

  /// Serializa pulsaciones y mantiene la ficha visible mientras guarda en SQLite.
  Future<void> save(AnimalDetailChange change) async {
    final current = state.detail;
    if (state.saving is Loading<AnimalDetail> || current is! Data<AnimalDetail>) return;
    emit(state.copyWith(saving: const ResultState.loading(), lastChange: change));
    final result = await _saveChangeUseCase(current.data.id, change);
    if (isClosed) return;
    switch (result) {
      case Failure(:final error):
        emit(state.copyWith(saving: ResultState.error(error)));
      case Success(:final data):
        emit(
          state.copyWith(
            detail: ResultState.data(data),
            saving: ResultState.data(data),
            undoStatus: change is RecordAnimalDeath
                ? current.data.status
                : change is UndoAnimalDeath
                ? null
                : state.undoStatus,
            deathVersion: change is RecordAnimalDeath
                ? data.updatedAt
                : change is UndoAnimalDeath
                ? null
                : state.deathVersion,
          ),
        );
    }
  }

  /// Revierte únicamente la baja confirmada en esta ficha, con un timestamp nuevo.
  Future<void> undoDeath() async {
    final previousStatus = state.undoStatus;
    final version = state.deathVersion;
    if (previousStatus == null || version == null) return;
    await save(AnimalDetailChange.undoDeath(previousStatus: previousStatus, deathUpdatedAt: version));
  }

  /// Vuelve a encolar un alta rechazada y refresca su estado local.
  Future<void> retrySync(String animalId) async {
    final retry = _retryAnimalSyncUseCase;
    if (retry == null) return;
    emit(state.copyWith(detail: const ResultState.loading()));
    final result = await retry(animalId);
    if (isClosed) return;
    switch (result) {
      case Success<void>():
        await loadAnimalData(animalId);
      case Failure<void>(:final error):
        emit(state.copyWith(detail: ResultState.error(error)));
    }
  }
}
