import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_registration_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

void main() {
  group('AnimalRegistrationRepositoryImpl', () {
    test('returns a pending domain result when the local save succeeds', () async {
      final brickStore = _FakeAnimalBrickStore();
      final repository = AnimalRegistrationRepositoryImpl(
        brickStore: brickStore,
      );

      final result = await repository.register(_registration);

      expect(result, isA<Success<RegisteredAnimal>>());
      expect(brickStore.savedAnimals.single.rfidTagNumber, _registration.rfidTagNumber);
    });

    test('returns a failure when local persistence throws', () async {
      final brickStore = _FakeAnimalBrickStore(throwOnSave: true);
      final repository = AnimalRegistrationRepositoryImpl(
        brickStore: brickStore,
      );

      final result = await repository.register(_registration);

      expect(result, isA<Failure<RegisteredAnimal>>());
    });
  });
}

final _registration = AnimalRegistration(
  rfidTagNumber: '982000412991416',
  visualTag: '003 1295',
  sex: AnimalSex.female,
  breed: 'Aberdeen Angus',
  birthDate: DateTime(2025, 3, 14),
  lotId: 'lot-id',
  lotName: 'La Cumbre',
  establishmentId: 'establishment-id',
  categoryId: 'category-id',
  categoryName: 'Ternera',
  initialWeight: 32.5,
  weighingDate: DateTime(2025, 3, 14),
);

class _FakeAnimalBrickStore implements AnimalBrickStore {
  _FakeAnimalBrickStore({
    this.throwOnSave = false,
  });

  final bool throwOnSave;
  final List<BrickAnimalModel> savedAnimals = [];

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) async {
    return animal;
  }

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async {
    return null;
  }

  @override
  Future<BrickAnimalModel?> getAnimalByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) async {
    return null;
  }

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async => savedAnimals;

  @override
  Future<void> pullRemoteAnimals(String establishmentId) async {}

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async {
    if (throwOnSave) {
      throw Exception('save failed');
    }

    savedAnimals.add(animal);
    return animal;
  }
}
