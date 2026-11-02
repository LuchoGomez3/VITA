import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_photo_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/retry_animal_sync_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_state.dart';

/// Coordina el estado de carga de la pantalla de detalle de animal.
class AnimalDetailCubit extends Cubit<AnimalDetailState> {
  /// Crea el cubit con el caso de uso que obtiene la ficha del animal.
  AnimalDetailCubit({
    required GetAnimalDetailUseCase getAnimalDetailUseCase,
    required GetAnimalPhotoUseCase getAnimalPhotoUseCase,
    required RetryAnimalSyncUseCase retryAnimalSyncUseCase,
  }) : _getAnimalDetailUseCase = getAnimalDetailUseCase,
       _getAnimalPhotoUseCase = getAnimalPhotoUseCase,
       _retryAnimalSyncUseCase = retryAnimalSyncUseCase,
       super(AnimalDetailState.initial);

  final GetAnimalDetailUseCase _getAnimalDetailUseCase;
  final GetAnimalPhotoUseCase _getAnimalPhotoUseCase;
  final RetryAnimalSyncUseCase _retryAnimalSyncUseCase;

  /// Carga los datos del animal identificado por [animalId].
  Future<void> loadAnimalData(String animalId) async {
    if (isClosed) return;
    emit(
      state.copyWith(
        detail: const ResultState.loading(),
        photo: const ResultState.initial(),
      ),
    );

    final result = await _getAnimalDetailUseCase(animalId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            detail: ResultState.data(data),
            photo: const ResultState.loading(),
          ),
        );
        await _loadPhoto(data);
      case Failure(:final error):
        emit(state.copyWith(detail: ResultState.error(error)));
    }
  }

  Future<void> _loadPhoto(AnimalDetail detail) async {
    if (isClosed) return;
    final result = await _getAnimalPhotoUseCase(
      establishmentId: detail.establishmentId,
      animalId: detail.id,
    );
    if (isClosed) return;
    switch (result) {
      case Success<AnimalPhoto?>(:final data):
        emit(state.copyWith(photo: ResultState.data(data)));
      case Failure<AnimalPhoto?>(:final error):
        emit(state.copyWith(photo: ResultState.error(error)));
    }
  }

  /// Vuelve a encolar un alta rechazada y refresca su estado local.
  Future<void> retrySync(String animalId) async {
    if (isClosed) return;
    emit(state.copyWith(detail: const ResultState.loading()));
    final result = await _retryAnimalSyncUseCase(animalId);
    if (isClosed) return;
    switch (result) {
      case Success<void>():
        await loadAnimalData(animalId);
      case Failure<void>(:final error):
        emit(state.copyWith(detail: ResultState.error(error)));
    }
  }
}
