import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_genealogy_repository.dart';
import 'package:logging/logging.dart';

/// Arma la genealogía con los animales guardados en el celular (offline-first).
///
/// Solo usa animales vigentes del mismo establecimiento: el backend exige que
/// madre y padre sean del mismo campo, y un animal dado de baja no se muestra.
class AnimalGenealogyRepositoryImpl implements AnimalGenealogyRepository {
  /// Crea el repositorio sobre los stores locales.
  const AnimalGenealogyRepositoryImpl({
    required AnimalBrickStore animalStore,
    required CategoriaBrickStore categoryStore,
  }) : _animalStore = animalStore,
       _categoryStore = categoryStore;

  static final _logger = Logger('AnimalGenealogyRepository');

  final AnimalBrickStore _animalStore;
  final CategoriaBrickStore _categoryStore;

  @override
  Future<Result<AnimalGenealogy>> getGenealogy(String animalId) async {
    try {
      final animals = await _animalStore.getLocalAnimals();
      final categoryNames = {
        for (final category in await _categoryStore.getLocalCategorias()) category.localId: category.name,
      };
      final byId = {for (final animal in animals) animal.localId: animal};
      final subject = byId[animalId];
      if (subject == null) {
        return const Result.success(AnimalGenealogy());
      }

      // Ningún nodo puede ser el propio animal ni repetirse en su línea: un
      // dato mal cargado (madre = hija) no tiene que dibujar un árbol circular.
      BrickAnimalModel? relative(String? id, Set<String> excluded) {
        if (id == null || excluded.contains(id)) return null;
        final animal = byId[id];
        if (animal == null || animal.deletedAt != null || animal.establishmentId != subject.establishmentId) {
          return null;
        }
        return animal;
      }

      GenealogyAnimal? node(BrickAnimalModel? animal) => animal == null
          ? null
          : GenealogyAnimal(
              id: animal.localId,
              visualTag: animal.visualTag,
              breed: animal.breed,
              categoryName: animal.categoryName.isNotEmpty
                  ? animal.categoryName
                  : categoryNames[animal.categoryId] ?? '',
            );

      final father = relative(subject.fatherId, {animalId});
      final mother = relative(subject.motherId, {animalId});
      final paternalLine = {animalId, ?father?.localId};
      final maternalLine = {animalId, ?mother?.localId};

      final offspring =
          animals
              .where(
                (animal) =>
                    animal.localId != animalId &&
                    animal.deletedAt == null &&
                    animal.establishmentId == subject.establishmentId &&
                    (animal.motherId == animalId || animal.fatherId == animalId),
              )
              .toList()
            ..sort((a, b) => b.birthDate.compareTo(a.birthDate));

      return Result.success(
        AnimalGenealogy(
          father: node(father),
          mother: node(mother),
          paternalGrandfather: node(relative(father?.fatherId, paternalLine)),
          paternalGrandmother: node(relative(father?.motherId, paternalLine)),
          maternalGrandfather: node(relative(mother?.fatherId, maternalLine)),
          maternalGrandmother: node(relative(mother?.motherId, maternalLine)),
          offspring: [for (final child in offspring) node(child)!],
        ),
      );
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudo leer la genealogía del animal $animalId', error, stackTrace);
      return const Result.failure(
        DomainException(message: 'No se pudo cargar la genealogía del animal.'),
      );
    }
  }
}
