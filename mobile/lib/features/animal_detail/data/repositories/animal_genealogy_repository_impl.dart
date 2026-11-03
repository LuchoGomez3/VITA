import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/data/mappers/animal_genealogy_mapper.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_genealogy_repository.dart';
import 'package:logging/logging.dart';

/// Lee y mapea animales locales del establecimiento del sujeto, sin usar red.
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
  Future<Result<List<GenealogyAnimalRecord>>> getLocalFamily(String animalId) async {
    try {
      final animals = await _animalStore.getLocalAnimals();
      final subject = animals.where((animal) => animal.localId == animalId && animal.deletedAt == null).firstOrNull;
      if (subject == null) return const Result.success([]);

      final categoryNames = {
        for (final category in await _categoryStore.getLocalCategorias()) category.localId: category.name,
      };
      return Result.success([
        for (final animal in animals)
          if (animal.deletedAt == null && animal.establishmentId == subject.establishmentId)
            AnimalGenealogyMapper.fromBrick(animal, categoryNames),
      ]);
    } on Object catch (error, stackTrace) {
      _logger.severe('Failed to read local animal genealogy', error, stackTrace);
      return const Result.failure(DomainException(message: 'animal_genealogy_read_failed'));
    }
  }
}
