import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/rfid_scan/data/repositories/rfid_animal_lookup_repository_impl.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';

void main() {
  group('RfidAnimalLookupRepositoryImpl', () {
    const rfidTagNumber = '982000412991416';
    const establishmentId = 'establishment-id';
    late _FakeAnimalBrickStore animalBrickStore;
    late RfidAnimalLookupRepositoryImpl repository;

    setUp(() {
      animalBrickStore = _FakeAnimalBrickStore();
      repository = RfidAnimalLookupRepositoryImpl(
        animalBrickStore: animalBrickStore,
      );
    });

    test('maps a locally found animal into the lightweight domain model', () async {
      animalBrickStore.animal = _brickAnimal;

      final result = await repository.findByRfidTagNumber(
        rfidTagNumber: rfidTagNumber,
        establishmentId: establishmentId,
      );

      expect(result, isA<Success<IdentifiedAnimal?>>());
      final animal = (result as Success<IdentifiedAnimal?>).data;
      expect(animal?.id, 'animal-id');
      expect(animal?.sex, IdentifiedAnimalSex.female);
      expect(animal?.categoryName, 'Ternera');
      expect(animal?.lotName, 'La Cumbre');
    });

    test('returns a successful null when the animal is not in SQLite', () async {
      final result = await repository.findByRfidTagNumber(
        rfidTagNumber: rfidTagNumber,
        establishmentId: establishmentId,
      );

      expect(result, const Result<IdentifiedAnimal?>.success(null));
    });

    test('returns a failure when the local store cannot be read', () async {
      animalBrickStore.throwOnLookup = true;

      final result = await repository.findByRfidTagNumber(
        rfidTagNumber: rfidTagNumber,
        establishmentId: establishmentId,
      );

      expect(result, isA<Failure<IdentifiedAnimal?>>());
    });
  });
}

final _brickAnimal = BrickAnimalModel(
  localId: 'animal-id',
  rfidTagNumber: '982000412991416',
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
  weighingDate: DateTime(2025, 3, 14),
  createdAt: DateTime(2025, 3, 14),
  updatedAt: DateTime(2025, 3, 14),
);

class _FakeAnimalBrickStore implements AnimalBrickStore {
  BrickAnimalModel? animal;
  bool throwOnLookup = false;

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) async => animal;

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async => null;

  @override
  Future<BrickAnimalModel?> getAnimalByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) async {
    if (throwOnLookup) {
      throw Exception('SQLite unavailable');
    }

    return animal;
  }

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async => const [];

  @override
  Future<void> pullRemoteAnimals(String establishmentId) async {}

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async => animal;
}
