import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_genealogy_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Coordina la lectura de genealogía sin bloquear la ficha ni su foto.
class AnimalGenealogyCubit extends Cubit<ResultState<AnimalGenealogy>> {
  /// Crea el Cubit con el caso de uso local.
  AnimalGenealogyCubit(this._getGenealogy) : super(const ResultState.initial());

  final GetAnimalGenealogyUseCase _getGenealogy;
  int _loadVersion = 0;

  /// Carga [animalId]; una lectura anterior nunca reemplaza la más reciente.
  Future<void> load(String animalId) async {
    if (isClosed) return;
    final version = ++_loadVersion;
    emit(const ResultState.loading());
    final result = await _getGenealogy(animalId);
    if (isClosed || version != _loadVersion) return;

    emit(
      result.when(
        success: ResultState.data,
        failure: (error) => ResultState.error(error.copyWith(message: AnimalDetailStrings.genealogyLoadError)),
      ),
    );
  }
}
