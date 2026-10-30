import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_animal.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/get_vision_animal_options.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';

/// Administra la consulta asincrónica de identidades disponibles para la foto.
class VisionAnimalSelectorCubit extends Cubit<ResultState<VisionAnimalOptions>> {
  /// Recibe el caso de uso y comienza sin datos cargados.
  VisionAnimalSelectorCubit(this._getOptions) : super(const ResultState.initial());

  final GetVisionAnimalOptions _getOptions;

  /// Consulta o refresca las opciones y devuelve los datos al flujo RFID.
  Future<VisionAnimalOptions?> load() async {
    emit(const ResultState.loading());
    try {
      final options = await _getOptions();
      if (!isClosed) emit(ResultState.data(options));
      return options;
    } on Exception catch (error) {
      if (!isClosed) {
        emit(
          ResultState.error(
            DomainException(message: VisionWeighingStrings.animalLoadError, reason: error),
          ),
        );
      }
      return null;
    }
  }
}
