import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';

/// Caso de uso que carga la ficha de un animal sin exponer la fuente de datos.
class GetAnimalDetailUseCase {
  /// Crea el caso de uso con el repository de detalle.
  const GetAnimalDetailUseCase(this._repository);

  final AnimalDetailRepository _repository;

  /// Lee el animal desde cache local o backend segun disponibilidad.
  Future<Result<AnimalDetail>> call(String animalId) {
    return _repository.getById(animalId);
  }
}
