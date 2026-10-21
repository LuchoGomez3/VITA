import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_genealogy_repository.dart';

/// Obtiene el árbol genealógico de un animal.
class GetAnimalGenealogyUseCase {
  /// Crea el caso de uso.
  const GetAnimalGenealogyUseCase(this._repository);

  final AnimalGenealogyRepository _repository;

  /// Ejecuta la lectura para [animalId].
  Future<Result<AnimalGenealogy>> call(String animalId) => _repository.getGenealogy(animalId);
}
