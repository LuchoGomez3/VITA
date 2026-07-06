import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';

/// Coordinates loading state for the animal detail screen.
class AnimalDetailCubit extends Cubit<ResultState<AnimalDetail>> {
  /// Creates the cubit with the use case that loads animal details.
  AnimalDetailCubit({
    required GetAnimalDetailUseCase getAnimalDetailUseCase,
  }) : _getAnimalDetailUseCase = getAnimalDetailUseCase,
       super(const ResultState.initial());

  final GetAnimalDetailUseCase _getAnimalDetailUseCase;

  /// Loads animal detail data for [animalId].
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
