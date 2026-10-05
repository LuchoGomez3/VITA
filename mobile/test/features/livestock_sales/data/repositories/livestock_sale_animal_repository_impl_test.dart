import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/repositories/livestock_sale_animal_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_selection_error.dart';

void main() {
  const rfid = '982000412991416';
  late _FakeAnimalBrickStore store;
  late _FakeCategoriaBrickStore categoryStore;
  late _FakeLotBrickStore lotStore;
  late LivestockSaleAnimalRepositoryImpl repository;

  setUp(() {
    store = _FakeAnimalBrickStore();
    categoryStore = _FakeCategoriaBrickStore();
    lotStore = _FakeLotBrickStore();
    repository = LivestockSaleAnimalRepositoryImpl(
      animalBrickStore: store,
      categoryBrickStore: categoryStore,
      lotBrickStore: lotStore,
      establishmentId: 'establishment-id',
    );
  });

  test('maps the most recent non-deleted local animal', () async {
    store.animals = [
      _animal(id: 'old', updatedAt: DateTime(2025)),
      _animal(id: 'deleted', deletedAt: DateTime(2025, 3)),
      _animal(
        id: 'new',
        updatedAt: DateTime(2025, 2),
        status: BrickAnimalProductiveStatus.sold,
      ),
    ];

    final result = await repository.findLocalByRfidTagNumber(rfid);

    expect(result, isA<Success<LivestockSaleAnimal?>>());
    final animal = (result as Success<LivestockSaleAnimal?>).data;
    expect(animal?.id, 'new');
    expect(animal?.status, LivestockSaleAnimalStatus.sold);
  });

  test('returns null when the RFID is absent locally', () async {
    store.animals = [_animal(id: 'other', rfid: '982000412991417')];

    final result = await repository.findLocalByRfidTagNumber(rfid);

    expect(result, const Result<LivestockSaleAnimal?>.success(null));
  });

  test('resolves category and lot names from local catalogs', () async {
    store.animals = [
      _animal(id: 'animal-id', categoryName: '', lotName: ''),
    ];
    categoryStore.categories = [_category(name: 'Novillo')];
    lotStore.lots = [_lot(name: 'Lote Norte')];

    final result = await repository.findLocalByRfidTagNumber(rfid);

    final animal = (result as Success<LivestockSaleAnimal?>).data;
    expect(animal?.categoryName, 'Novillo');
    expect(animal?.lotName, 'Lote Norte');
  });

  test('refreshes productive status before returning the first match', () async {
    store
      ..animals = [_animal(id: 'animal-id')]
      ..remoteAnimals = [
        _animal(
          id: 'animal-id',
          status: BrickAnimalProductiveStatus.dead,
        ),
      ];

    final result = await repository.findLocalByRfidTagNumber(rfid);

    final animal = (result as Success<LivestockSaleAnimal?>).data;
    expect(animal?.status, LivestockSaleAnimalStatus.dead);
  });

  test('returns a typed failure when SQLite cannot be read', () async {
    store.throwOnRead = true;

    final result = await repository.findLocalByRfidTagNumber(rfid);

    expect(result, isA<Failure<LivestockSaleAnimal?>>());
    final error = (result as Failure<LivestockSaleAnimal?>).error;
    expect(error.reason, LivestockSaleSelectionError.localRead);
  });
}

BrickAnimalModel _animal({
  required String id,
  String rfid = '982000412991416',
  DateTime? updatedAt,
  DateTime? deletedAt,
  BrickAnimalProductiveStatus status = BrickAnimalProductiveStatus.active,
  String categoryName = 'Ternera',
  String lotName = 'La Cumbre',
}) {
  final timestamp = updatedAt ?? DateTime(2025, 3, 14);
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: rfid,
    visualTag: '003 1295',
    sex: BrickAnimalSex.female,
    breed: 'Aberdeen Angus',
    birthDate: DateTime(2025, 3, 14),
    categoryId: 'category-id',
    categoryName: categoryName,
    lotId: 'lot-id',
    lotName: lotName,
    establishmentId: 'establishment-id',
    initialWeight: 32.5,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: timestamp,
    createdAt: timestamp,
    updatedAt: timestamp,
    deletedAt: deletedAt,
    productiveStatus: status,
  );
}

BrickCategoriaModel _category({required String name}) {
  final timestamp = DateTime(2025, 3, 14);
  return BrickCategoriaModel(
    localId: 'category-id',
    name: name,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

BrickLotModel _lot({required String name}) {
  final timestamp = DateTime(2025, 3, 14);
  return BrickLotModel(
    localId: 'lot-id',
    establishmentId: 'establishment-id',
    name: name,
    boundaryJson: '{}',
    surfaceTenths: 10,
    hasWater: true,
    statusCode: 'activo',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _FakeAnimalBrickStore implements AnimalBrickStore {
  List<BrickAnimalModel> animals = [];
  List<BrickAnimalModel>? remoteAnimals;
  bool throwOnRead = false;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async {
    if (throwOnRead) throw Exception('SQLite unavailable');
    return animals;
  }

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) async => animal;

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async => null;

  @override
  Future<BrickAnimalModel?> getAnimalByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) async => null;

  @override
  Future<void> pullRemoteAnimals(String establishmentId) async {
    final refreshed = remoteAnimals;
    if (refreshed != null) animals = refreshed;
  }

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async => animal;
}

class _FakeCategoriaBrickStore implements CategoriaBrickStore {
  List<BrickCategoriaModel> categories = [];

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias(
    String establishmentId,
  ) async => categories;

  @override
  Future<void> pullRemoteCategorias(String establishmentId) async {}

  @override
  Future<BrickCategoriaModel> upsertCategoria(
    BrickCategoriaModel categoria,
  ) async => categoria;
}

class _FakeLotBrickStore implements LotBrickStore {
  List<BrickLotModel> lots = [];

  @override
  Future<BrickLotModel?> getLocalLot(String lotId) async => null;

  @override
  Future<List<BrickLotModel>> getLocalLots(String establishmentId) async => lots;

  @override
  Future<void> pullRemoteLots(String establishmentId) async {}

  @override
  Future<BrickLotModel> upsertLocalLot(BrickLotModel lot) async => lot;
}
