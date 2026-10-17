import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_parent.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_parent_repository.dart';

/// Obtiene los animales locales del establecimiento para buscar progenitores.
class GetAnimalParentsUseCase {
  /// Crea el caso de uso con su repositorio.
  const GetAnimalParentsUseCase(this._repository);

  final AnimalParentRepository _repository;

  /// No requiere conexión ni descarga datos remotos.
  Future<Result<List<AnimalParent>>> call(String establishmentId) => _repository.getParents(establishmentId);
}
