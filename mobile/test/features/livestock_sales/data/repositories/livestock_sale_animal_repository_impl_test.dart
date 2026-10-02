import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/repositories/livestock_sale_animal_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_selection_error.dart';

void main() {
  const rfid = '982000412991416';
  late _FakeAnimalBrickStore store;
  late LivestockSaleAnimalRepositoryImpl repository;

  setUp(() {
    store = _FakeAnimalBrickStore();
    repository = LivestockSaleAnimalRepositoryImpl(animalBrickStore: store);
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
    categoryName: 'Ternera',
    lotId: 'lot-id',
    lotName: 'La Cumbre',
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

class _FakeAnimalBrickStore implements AnimalBrickStore {
  List<BrickAnimalModel> animals = [];
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
  Future<void> pullRemoteAnimals(String establishmentId) async {}

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async => animal;
}
