import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_genealogy_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';

void main() {
  late _LocalAnimalStore animalStore;
  late _LocalCategoryStore categoryStore;
  late AnimalGenealogyRepositoryImpl repository;

  setUp(() {
    animalStore = _LocalAnimalStore();
    categoryStore = _LocalCategoryStore();
    repository = AnimalGenealogyRepositoryImpl(animalStore: animalStore, categoryStore: categoryStore);
  });

  test('lee solo animales vigentes del establecimiento del sujeto sin usar red', () async {
    animalStore.animals = [
      _animal('ternero', mother: 'vaca', father: 'toro'),
      _animal('vaca'),
      _animal('toro', establishmentId: 'otro-campo'),
      _animal('borrado', deletedAt: DateTime.utc(2026)),
    ];

    final result = await repository.getLocalFamily('ternero');
    final records = (result as Success<List<GenealogyAnimalRecord>>).data;

    expect(records.map((record) => record.animal.id), ['ternero', 'vaca']);
    expect(records.first.motherId, 'vaca');
    expect(records.first.fatherId, 'toro');
    expect(records.first.birthDate, DateTime.utc(2022));
    expect(records.first.animal.categoryName, 'Vaca');
  });

  test('conserva nombre local y permite catálogo vacío', () async {
    animalStore.animals = [_animal('vaca', categoryName: 'Categoría local')];
    categoryStore.categories = [];

    final result = await repository.getLocalFamily('vaca');

    expect((result as Success<List<GenealogyAnimalRecord>>).data.single.animal.categoryName, 'Categoría local');
  });

  test('una categoría sin resolver no inventa un nombre', () async {
    animalStore.animals = [_animal('vaca')];
    categoryStore.categories = [];

    final result = await repository.getLocalFamily('vaca');

    expect((result as Success<List<GenealogyAnimalRecord>>).data.single.animal.categoryName, isEmpty);
  });

  for (final deleted in [false, true]) {
    test('sujeto ${deleted ? 'borrado' : 'ausente'} no expone animales de otro contexto', () async {
      animalStore.animals = [
        _animal('otro'),
        if (deleted) _animal('sujeto', deletedAt: DateTime.utc(2026)),
      ];

      final result = await repository.getLocalFamily('sujeto');

      expect(result, const Result<List<GenealogyAnimalRecord>>.success([]));
    });
  }

  for (final categoryFailure in [false, true]) {
    test('traduce el fallo local de ${categoryFailure ? 'categorías' : 'animales'}', () async {
      animalStore
        ..animals = [_animal('vaca')]
        ..fail = !categoryFailure;
      categoryStore.fail = categoryFailure;

      final result = await repository.getLocalFamily('vaca');

      expect(
        result,
        const Result<List<GenealogyAnimalRecord>>.failure(
          DomainException(message: 'animal_genealogy_read_failed'),
        ),
      );
    });
  }
}

BrickAnimalModel _animal(
  String id, {
  String? tag,
  String? mother,
  String? father,
  String establishmentId = 'campo-1',
  String categoryName = '',
  DateTime? deletedAt,
  DateTime? birthDate,
}) {
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: '982000412884${id.hashCode.abs() % 1000}',
    visualTag: tag ?? id,
    sex: BrickAnimalSex.female,
    breed: 'Aberdeen Angus',
    birthDate: birthDate ?? DateTime.utc(2022),
    categoryId: 'cat-vaca',
    categoryName: categoryName,
    lotId: 'lote-1',
    establishmentId: establishmentId,
    initialWeight: 300,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: DateTime.utc(2026),
    motherId: mother,
    fatherId: father,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    deletedAt: deletedAt,
  );
}

class _LocalAnimalStore implements AnimalBrickStore {
  List<BrickAnimalModel> animals = [];
  bool fail = false;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async {
    if (fail) throw StateError('SQLite unavailable');
    return animals;
  }

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) => throw UnimplementedError();

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) => throw UnimplementedError();

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) => throw UnimplementedError();

  @override
  Future<BrickAnimalModel?> getAnimalByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) => throw UnimplementedError();

  @override
  Future<void> pullRemoteAnimals(String establishmentId) => throw StateError('Unexpected network access');

  @override
  Future<void> retryRejectedAnimal(String animalId) => throw UnimplementedError();
}

class _LocalCategoryStore implements CategoriaBrickStore {
  bool fail = false;
  List<BrickCategoriaModel> categories = [
    BrickCategoriaModel(
      localId: 'cat-vaca',
      name: 'Vaca',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias() async {
    if (fail) throw StateError('SQLite unavailable');
    return categories;
  }

  @override
  Future<void> pullRemoteCategorias() => throw StateError('Unexpected network access');
}
