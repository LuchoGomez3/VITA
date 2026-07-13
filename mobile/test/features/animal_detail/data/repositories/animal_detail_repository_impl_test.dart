import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/data/datasources/animal_detail_remote_data_source.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_detail_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

void main() {
  group('AnimalDetailRepositoryImpl', () {
    test('returns local Brick data before querying the backend', () async {
      final brickStore = _FakeAnimalBrickStore(localAnimal: _brickAnimal);
      final remoteDataSource = _FakeAnimalDetailRemoteDataSource();
      final repository = AnimalDetailRepositoryImpl(
        brickStore: brickStore,
        remoteDataSource: remoteDataSource,
      );

      final result = await repository.getById(_animalId);

      expect(result, isA<Success<AnimalDetail>>());
      expect(remoteDataSource.calls, 0);
      final detail = (result as Success<AnimalDetail>).data;
      expect(detail.id, _animalId);
      expect(detail.syncStatus, AnimalSyncStatus.pending);
    });

    test('queries backend when the animal is not cached locally', () async {
      final brickStore = _FakeAnimalBrickStore();
      final remoteDataSource = _FakeAnimalDetailRemoteDataSource();
      final repository = AnimalDetailRepositoryImpl(
        brickStore: brickStore,
        remoteDataSource: remoteDataSource,
      );

      final result = await repository.getById(_animalId);

      expect(result, isA<Success<AnimalDetail>>());
      expect(remoteDataSource.calls, 1);
      expect(brickStore.cachedAnimals.single.localId, _animalId);
      final detail = (result as Success<AnimalDetail>).data;
      expect(detail.id, _animalId);
      expect(detail.syncStatus, AnimalSyncStatus.synchronized);
    });
  });
}

const _animalId = '96a221e0-c202-42ac-8b8e-11d89dc41f8d';

final _brickAnimal = BrickAnimalModel(
  localId: _animalId,
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
  _FakeAnimalBrickStore({
    this.localAnimal,
  });

  final BrickAnimalModel? localAnimal;
  final List<BrickAnimalModel> cachedAnimals = [];

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) async {
    cachedAnimals.add(animal);
    return animal;
  }

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async {
    if (localAnimal?.localId == animalId) {
      return localAnimal;
    }

    return null;
  }

  @override
  Future<void> pullRemoteAnimals(String establishmentId) async {}

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async {
    return animal;
  }
}

class _FakeAnimalDetailRemoteDataSource extends AnimalDetailRemoteDataSource {
  _FakeAnimalDetailRemoteDataSource()
    : super(
        tokenProvider: _FakeTokenProvider(),
      );

  int calls = 0;

  @override
  Future<AnimalDetailBackendDto> getAnimalById(String animalId) async {
    calls += 1;
    return AnimalDetailBackendDto(
      id: animalId,
      establishmentId: 'establishment-id',
      rfidTagNumber: '982000412991416',
      visualTag: '003 1295',
      sex: 'hembra',
      breed: 'Aberdeen Angus',
      birthDate: DateTime(2025, 3, 14),
      categoryId: 'category-id',
      lotId: 'lot-id',
      motherId: null,
      fatherId: null,
      coat: null,
      observations: null,
      createdAt: DateTime(2025, 3, 14),
      updatedAt: DateTime(2025, 3, 14),
    );
  }
}

class _FakeTokenProvider implements BackendAccessTokenProvider {
  @override
  Future<String?> getAccessToken() async => 'token';
}
