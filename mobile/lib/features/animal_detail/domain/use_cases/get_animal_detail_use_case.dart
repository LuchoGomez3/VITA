import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';

/// Caso de uso que obtiene la ficha de un animal.
class GetAnimalDetailUseCase {
  /// Crea el caso de uso con el repositorio de detalle.
  const GetAnimalDetailUseCase(this._repository);

  final AnimalDetailRepository _repository;

  /// Obtiene la ficha del animal identificado por [animalId].
  Future<Result<AnimalDetail>> call(String animalId) {
    return _repository.getById(animalId);
  }
}
