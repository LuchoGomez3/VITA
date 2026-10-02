import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/retry_animal_sync_use_case.dart';

/// Coordina el estado de carga de la pantalla de detalle de animal.
class AnimalDetailCubit extends Cubit<ResultState<AnimalDetail>> {
  /// Crea el cubit con el caso de uso que obtiene la ficha del animal.
  AnimalDetailCubit({
    required GetAnimalDetailUseCase getAnimalDetailUseCase,
    required RetryAnimalSyncUseCase retryAnimalSyncUseCase,
  }) : _getAnimalDetailUseCase = getAnimalDetailUseCase,
       _retryAnimalSyncUseCase = retryAnimalSyncUseCase,
       super(const ResultState.initial());

  final GetAnimalDetailUseCase _getAnimalDetailUseCase;
  final RetryAnimalSyncUseCase _retryAnimalSyncUseCase;

  /// Carga los datos del animal identificado por [animalId].
  Future<void> loadAnimalData(String animalId) async {
    emit(const ResultState.loading());

    final result = await _getAnimalDetailUseCase(animalId);
    switch (result) {
      case Success(:final data):
        emit(ResultState.data(data));
      case Failure(:final error):
        emit(ResultState.error(error));
    }
  }

  /// Vuelve a encolar un alta rechazada y refresca su estado local.
  Future<void> retrySync(String animalId) async {
    emit(const ResultState.loading());
    final result = await _retryAnimalSyncUseCase(animalId);
    switch (result) {
      case Success<void>():
        await loadAnimalData(animalId);
      case Failure<void>(:final error):
        emit(ResultState.error(error));
    }
  }
}
