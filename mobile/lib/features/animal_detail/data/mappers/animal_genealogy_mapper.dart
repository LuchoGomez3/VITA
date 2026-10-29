import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';

/// Traduce persistencia y catálogo local a datos de parentesco de dominio.
class AnimalGenealogyMapper {
  const AnimalGenealogyMapper._();

  /// Conserva relaciones y fecha de nacimiento sin construir el árbol.
  static GenealogyAnimalRecord fromBrick(BrickAnimalModel model, Map<String, String> categoryNames) {
    return GenealogyAnimalRecord(
      animal: GenealogyAnimal(
        id: model.localId,
        visualTag: model.visualTag,
        breed: model.breed,
        categoryName: model.categoryName.isNotEmpty ? model.categoryName : categoryNames[model.categoryId] ?? '',
      ),
      birthDate: model.birthDate,
      motherId: model.motherId,
      fatherId: model.fatherId,
    );
  }
}
