import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/livestock/data/repositories/animal_list_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/animal_list_entry.dart';

void main() {
  AnimalListRepositoryImpl repository({
    List<BrickAnimalModel> animals = const [],
    List<BrickPesajeModel> weighings = const [],
    bool failAnimals = false,
  }) {
    return AnimalListRepositoryImpl(
      animalStore: _FakeAnimalStore(animals, fail: failAnimals),
      pesajeStore: _FakePesajeStore(weighings),
      categoryStore: _FakeCategoryStore(),
      lotStore: _FakeLotStore(),
      establishmentCatalog: const EstablishmentCatalog(secureStorage: _EmptyStorage()),
    );
  }

  Future<List<AnimalListEntry>> animalsOf(AnimalListRepositoryImpl repository) async =>
      ((await repository.getAnimals()) as Success<List<AnimalListEntry>>).data;

  test('fills the category and lot names of animals pulled without them', () async {
    final entries = await animalsOf(repository(animals: [_animal('a1')]));

    expect(entries.single.categoryName, 'Novillo');
    expect(entries.single.lotName, 'El Bajo');
    expect(entries.single.establishmentId, 'campo-1');
  });

  test('the last weight is the latest weighing, or the initial weight if there is none', () async {
    final entries = await animalsOf(
      repository(
        animals: [_animal('con-pesajes'), _animal('sin-pesajes', initialWeight: 300)],
        weighings: [
          _weighing('con-pesajes', 380, DateTime.utc(2026, 10, 14)),
          _weighing('con-pesajes', 388, DateTime.utc(2026, 10, 8)),
        ],
      ),
    );
    final byId = {for (final entry in entries) entry.id: entry};

    expect(byId['con-pesajes']!.lastWeightKg, 380);
    expect(byId['con-pesajes']!.lastWeighingDate, DateTime.utc(2026, 10, 14));
    expect(byId['sin-pesajes']!.lastWeightKg, 300);
    expect(byId['sin-pesajes']!.lastWeighingDate, _initialWeighingDate);
  });

  test('leaves out animals with a logical delete and lists the newest first', () async {
    final entries = await animalsOf(
      repository(
        animals: [
          _animal('viejo', createdAt: DateTime.utc(2026, 1, 1)),
          _animal('borrado', deletedAt: DateTime.utc(2026, 5, 1)),
          _animal('nuevo', createdAt: DateTime.utc(2026, 6, 1)),
        ],
      ),
    );

    expect(entries.map((entry) => entry.id), ['nuevo', 'viejo']);
  });

  test('returns a readable failure when the local store fails', () async {
    final result = await repository(failAnimals: true).getAnimals();

    expect(
      result,
      isA<Failure<List<AnimalListEntry>>>().having((f) => f.error.message, 'message', contains('animales')),
    );
  });
}

final _initialWeighingDate = DateTime.utc(2026, 5, 8);

BrickAnimalModel _animal(String id, {double initialWeight = 320, DateTime? createdAt, DateTime? deletedAt}) {
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: '982000412884005',
    visualTag: '004 0028',
    sex: BrickAnimalSex.male,
    breed: 'Hereford',
    birthDate: DateTime.utc(2024, 6, 12),
    categoryId: 'cat-novillo',
    lotId: 'lote-bajo',
    establishmentId: 'campo-1',
    initialWeight: initialWeight,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: _initialWeighingDate,
    createdAt: createdAt ?? DateTime.utc(2026, 5, 8),
    updatedAt: DateTime.utc(2026, 5, 8),
    deletedAt: deletedAt,
  );
}

BrickPesajeModel _weighing(String animalId, double kg, DateTime date) => BrickPesajeModel(
  localId: '$animalId-$kg',
  establishmentId: 'campo-1',
  animalId: animalId,
  weightKg: kg,
  date: date,
  createdAt: date,
  updatedAt: date,
);

class _FakeAnimalStore implements AnimalBrickStore {
  _FakeAnimalStore(this.animals, {this.fail = false});

  final List<BrickAnimalModel> animals;
  final bool fail;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async {
    if (fail) {
      throw StateError('SQLite no disponible');
    }
    return animals;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakePesajeStore implements PesajeBrickStore {
  _FakePesajeStore(this.weighings);

  final List<BrickPesajeModel> weighings;

  @override
  Future<List<BrickPesajeModel>> getLocalPesajes() async => weighings;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakeCategoryStore implements CategoriaBrickStore {
  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias() async => [
    BrickCategoriaModel(
      localId: 'cat-novillo',
      name: 'Novillo',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakeLotStore implements LotBrickStore {
  @override
  Future<List<BrickLotModel>> getLocalLots(String establishmentId) async => [
    BrickLotModel(
      localId: 'lote-bajo',
      establishmentId: establishmentId,
      name: 'El Bajo',
      boundaryJson: '{}',
      surfaceTenths: 950,
      hasWater: false,
      statusCode: 'activo',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _EmptyStorage implements SecureStorageService {
  const _EmptyStorage();

  @override
  Future<String?> read(String key) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}
