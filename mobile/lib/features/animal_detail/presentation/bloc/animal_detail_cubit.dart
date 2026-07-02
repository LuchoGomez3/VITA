import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/bloc/animal_detail_state.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Coordinates loading state for the animal detail screen.
class AnimalDetailCubit extends Cubit<AnimalDetailState> {
  /// Creates the cubit in its initial state.
  AnimalDetailCubit() : super(AnimalDetailInitial());

  /// Loads animal detail data for [animalId].
  Future<void> loadAnimalData(String animalId) async {
    emit(AnimalDetailLoading());

    try {
      await Future<void>.delayed(const Duration(seconds: 2));

      emit(
        AnimalDetailLoaded(
          raza: AnimalDetailStrings.breedValue,
          sexo: AnimalDetailStrings.sexValue,
          categoria: AnimalDetailStrings.categoryValue,
          pesoActual: 410,
        ),
      );
    } on Exception {
      emit(AnimalDetailError(AnimalDetailStrings.loadError));
    }
  }
}
