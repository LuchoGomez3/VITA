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

    test('returns local animals whose RFID starts with the prefix', () async {
      animalBrickStore.animals = [
        _brickAnimal,
        _createBrickAnimal(
          localId: 'another-animal',
          rfidTagNumber: '982000499999999',
        ),
        _createBrickAnimal(
          localId: 'other-establishment',
          establishmentId: 'other-establishment',
        ),
      ];

      final result = await repository.findByRfidPrefix(
        rfidPrefix: '9820004',
        establishmentId: establishmentId,
      );

      expect(result, isA<Success<List<IdentifiedAnimal>>>());
      final animals = (result as Success<List<IdentifiedAnimal>>).data;
      expect(animals.map((animal) => animal.id), [
        'animal-id',
        'another-animal',
      ]);
    });
  });
}

final _brickAnimal = _createBrickAnimal();

BrickAnimalModel _createBrickAnimal({
  String localId = 'animal-id',
  String rfidTagNumber = '982000412991416',
  String establishmentId = 'establishment-id',
}) => BrickAnimalModel(
  localId: localId,
  rfidTagNumber: rfidTagNumber,
  visualTag: '003 1295',
  sex: BrickAnimalSex.female,
  breed: 'Aberdeen Angus',
  birthDate: DateTime(2025, 3, 14),
  categoryId: 'category-id',
  categoryName: 'Ternera',
  lotId: 'lot-id',
  lotName: 'La Cumbre',
  establishmentId: establishmentId,
  initialWeight: 32.5,
  weighingMethod: BrickAnimalWeighingMethod.manual,
  weighingDate: DateTime(2025, 3, 14),
  createdAt: DateTime(2025, 3, 14),
  updatedAt: DateTime(2025, 3, 14),
);

class _FakeAnimalBrickStore implements AnimalBrickStore {
  BrickAnimalModel? animal;
  List<BrickAnimalModel> animals = const [];
  bool throwOnLookup = false;

  @override
  Future<BrickAnimalModel> updateAnimal(BrickAnimalModel animal) => upsertAnimal(animal);

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
  Future<List<BrickAnimalModel>> getLocalAnimals() async => animals;

  @override
  Future<void> pullRemoteAnimals(String establishmentId) async {}

  @override
  Future<void> retryRejectedAnimal(String animalId) async {}

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async => animal;
}
