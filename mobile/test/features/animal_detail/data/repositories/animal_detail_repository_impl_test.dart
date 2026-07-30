import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/data/datasources/animal_detail_remote_data_source.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_detail_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';

void main() {
  group('AnimalDetailRepositoryImpl', () {
    test('returns local Brick data before querying the backend', () async {
      final brickStore = _FakeAnimalBrickStore(localAnimal: _brickAnimal);
      final remoteDataSource = _FakeAnimalDetailRemoteDataSource();
      final repository = AnimalDetailRepositoryImpl(
        brickStore: brickStore,
        categoriaBrickStore: _FakeCategoriaBrickStore(),
        pesajeBrickStore: _FakePesajeBrickStore(),
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
        categoriaBrickStore: _FakeCategoriaBrickStore(),
        pesajeBrickStore: _FakePesajeBrickStore(),
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

    test('loads real weights and resolves the category name', () async {
      final pesajeStore = _FakePesajeBrickStore(pesajes: [_firstPesaje, _latestPesaje]);
      final categoriaStore = _FakeCategoriaBrickStore(
        categorias: [_categoria],
      );
      final repository = AnimalDetailRepositoryImpl(
        brickStore: _FakeAnimalBrickStore(localAnimal: _brickAnimal),
        categoriaBrickStore: categoriaStore,
        pesajeBrickStore: pesajeStore,
        remoteDataSource: _FakeAnimalDetailRemoteDataSource(),
      );

      final result = await repository.getById(_animalId);

      final detail = (result as Success<AnimalDetail>).data;
      expect(pesajeStore.pulledAnimalId, _animalId);
      expect(categoriaStore.pullCalls, 1);
      expect(detail.categoryName, 'Novillito');
      expect(detail.weightHistory.map((record) => record.weightKg), [210, 245]);
      expect(detail.currentWeight, 245);
      expect(detail.weighingDate, _latestPesaje.date);
      expect(detail.weighingMethod, AnimalWeighingMethod.bluetoothScale);
    });

    test('uses cached related data when remote pulls fail', () async {
      final repository = AnimalDetailRepositoryImpl(
        brickStore: _FakeAnimalBrickStore(localAnimal: _brickAnimal),
        categoriaBrickStore: _FakeCategoriaBrickStore(
          categorias: [_categoria],
          failPull: true,
        ),
        pesajeBrickStore: _FakePesajeBrickStore(
          pesajes: [_firstPesaje],
          failPull: true,
        ),
        remoteDataSource: _FakeAnimalDetailRemoteDataSource(),
      );

      final result = await repository.getById(_animalId);

      final detail = (result as Success<AnimalDetail>).data;
      expect(detail.categoryName, 'Novillito');
      expect(detail.weightHistory.single.weightKg, 210);
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

final _categoria = BrickCategoriaModel(
  localId: 'category-id',
  establishmentId: 'establishment-id',
  name: 'Novillito',
  createdAt: DateTime(2025),
  updatedAt: DateTime(2025),
);

final _firstPesaje = BrickPesajeModel(
  localId: 'weighing-1',
  establishmentId: 'establishment-id',
  animalId: _animalId,
  weightKg: 210,
  date: DateTime(2025, 5),
  createdAt: DateTime(2025, 5),
  updatedAt: DateTime(2025, 5),
);

final _latestPesaje = BrickPesajeModel(
  localId: 'weighing-2',
  establishmentId: 'establishment-id',
  animalId: _animalId,
  weightKg: 245,
  date: DateTime(2025, 6),
  method: BrickPesajeMethod.bluetoothScale,
  createdAt: DateTime(2025, 6),
  updatedAt: DateTime(2025, 6),
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
  Future<List<BrickAnimalModel>> getLocalAnimals() async {
    return localAnimal == null ? const [] : [localAnimal!];
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

class _FakeCategoriaBrickStore implements CategoriaBrickStore {
  _FakeCategoriaBrickStore({
    this.categorias = const [],
    this.failPull = false,
  });

  final List<BrickCategoriaModel> categorias;
  final bool failPull;
  int pullCalls = 0;

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias(
    String establishmentId,
  ) async => categorias;

  @override
  Future<void> pullRemoteCategorias(String establishmentId) async {
    pullCalls += 1;
    if (failPull) {
      throw Exception('offline');
    }
  }

  @override
  Future<BrickCategoriaModel> upsertCategoria(
    BrickCategoriaModel categoria,
  ) async => categoria;
}

class _FakePesajeBrickStore implements PesajeBrickStore {
  _FakePesajeBrickStore({
    this.pesajes = const [],
    this.failPull = false,
  });

  final List<BrickPesajeModel> pesajes;
  final bool failPull;
  String? pulledAnimalId;

  @override
  Future<List<BrickPesajeModel>> loadPesajesByAnimal(
    String establishmentId,
    String animalId,
  ) async {
    pulledAnimalId = animalId;
    if (failPull) {
      throw Exception('offline');
    }
    return pesajes;
  }

  @override
  Future<List<BrickPesajeModel>> getLocalPesajesByAnimal(
    String animalId,
  ) async => pesajes;

  @override
  Future<List<BrickPesajeModel>> getLocalPesajes() async => pesajes;

  @override
  Future<void> pullRemotePesajes(
    String establishmentId, {
    String? animalId,
  }) async {
    pulledAnimalId = animalId;
    if (failPull) {
      throw Exception('offline');
    }
  }

  @override
  Future<BrickPesajeModel> upsertPesaje(BrickPesajeModel pesaje) async => pesaje;
}

class _FakeTokenProvider implements BackendAccessTokenProvider {
  @override
  Future<String?> getAccessToken() async => 'token';
}
