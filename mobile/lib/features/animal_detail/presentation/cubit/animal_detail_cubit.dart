import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';

/// Coordina el estado de carga de la pantalla de detalle de animal.
class AnimalDetailCubit extends Cubit<ResultState<AnimalDetail>> {
  /// Crea el cubit con el caso de uso que obtiene la ficha del animal.
  AnimalDetailCubit({
    required GetAnimalDetailUseCase getAnimalDetailUseCase,
  }) : _getAnimalDetailUseCase = getAnimalDetailUseCase,
       super(const ResultState.initial());

  final GetAnimalDetailUseCase _getAnimalDetailUseCase;

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
}
