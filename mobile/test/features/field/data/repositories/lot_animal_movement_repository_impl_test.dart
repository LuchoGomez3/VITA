import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/data/repositories/lot_animal_movement_repository_impl.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory testDirectory;
  late String sqlitePath;
  late String queuePath;
  late BrickAnimalLotMovementStore movementStore;

  setUpAll(() async {
    sqfliteFfiInit();
    testDirectory = await Directory.systemTemp.createTemp(
      'vita_inactive_animal_movement_test_',
    );
    sqlitePath = path.join(testDirectory.path, 'brick.sqlite');
    queuePath = path.join(testDirectory.path, 'queue.sqlite');
    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: queuePath,
      localDatabaseFactory: databaseFactoryFfi,
    );
    BrickAnimalStore.configure(AppBrickRepository.instance);
    BrickAnimalLotMovementStore.configure(
      AppBrickRepository.instance,
      animalStore: BrickAnimalStore.instance,
    );
    movementStore = BrickAnimalLotMovementStore.instance;
  });

  tearDownAll(() async {
    await databaseFactoryFfi.deleteDatabase(sqlitePath);
    await databaseFactoryFfi.deleteDatabase(queuePath);
    if (testDirectory.existsSync()) {
      await testDirectory.delete(recursive: true);
    }
  });

  for (final status in [
    BrickAnimalProductiveStatus.sold,
    BrickAnimalProductiveStatus.dead,
    BrickAnimalProductiveStatus.removed,
    BrickAnimalProductiveStatus.unknown,
  ]) {
    test('rejects moving an animal with status ${status.name}', () async {
      final repository = LotAnimalMovementRepositoryImpl(
        animalStore: _FakeAnimalStore(_animal(status)),
        lotStore: const _FakeLotStore(),
        movementStore: movementStore,
      );

      final result = await repository.moveAnimals(_movement());

      expect(result, isA<Failure<LotAnimalMovement>>());
    });
  }

  test('movement pending state stays on the movement aggregate', () async {
    final movementStore = _CapturingMovementStore();
    final repository = LotAnimalMovementRepositoryImpl(
      animalStore: _FakeAnimalStore(
        _animal(
          BrickAnimalProductiveStatus.active,
          syncStatus: BrickAnimalSyncStatus.synchronized,
        ),
      ),
      lotStore: const _FakeLotStore(),
      movementStore: movementStore,
    );

    final result = await repository.moveAnimals(_movement());

    expect(result, isA<Success<LotAnimalMovement>>());
    expect(
      movementStore.savedAnimals.single.syncStatus,
      BrickAnimalSyncStatus.synchronized,
    );
    expect(
      movementStore.savedMovement?.syncStatus,
      BrickAnimalLotMovementSyncStatus.pending,
    );
  });
}

BrickAnimalModel _animal(
  BrickAnimalProductiveStatus status, {
  BrickAnimalSyncStatus syncStatus = BrickAnimalSyncStatus.pending,
}) {
  final timestamp = DateTime.utc(2026, 9, 29);
  return BrickAnimalModel(
    localId: 'animal-id',
    rfidTagNumber: '982000000000001',
    visualTag: 'A1',
    sex: BrickAnimalSex.female,
    breed: 'Angus',
    birthDate: DateTime.utc(2025),
    categoryId: 'category-id',
    lotId: 'source-lot',
    establishmentId: 'establishment-id',
    initialWeight: 300,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: timestamp,
    productiveStatus: status,
    syncStatus: syncStatus,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _CapturingMovementStore implements AnimalLotMovementBrickStore {
  @override
  Future<List<BrickAnimalLotMovementModel>> getLocalMovements(String establishmentId) async => const [];

  List<BrickAnimalModel> savedAnimals = const [];
  BrickAnimalLotMovementModel? savedMovement;

  @override
  Future<BrickAnimalLotMovementModel> saveWithAnimals({
    required List<BrickAnimalModel> animals,
    required BrickAnimalLotMovementModel movement,
  }) async {
    savedAnimals = animals;
    savedMovement = movement;
    return movement;
  }

  @override
  Future<BrickAnimalLotMovementModel> save(
    BrickAnimalLotMovementModel movement,
  ) => throw StateError('Unexpected save call');

  @override
  Future<void> pullRemoteMovements(String establishmentId) => throw StateError('Unexpected pullRemoteMovements call');

  @override
  Future<void> pushPendingMovements(String establishmentId) => throw StateError('Unexpected pushPendingMovements call');
}

LotAnimalMovement _movement() {
  final timestamp = DateTime.utc(2026, 9, 29);
  return LotAnimalMovement(
    id: 'movement-id',
    establishmentId: 'establishment-id',
    sourceLotId: 'source-lot',
    destinationLotId: 'destination-lot',
    animalIds: const ['animal-id'],
    occurredAt: timestamp,
    reason: 'Rotacion',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _FakeAnimalStore implements AnimalBrickStore {
  const _FakeAnimalStore(this.animal);

  final BrickAnimalModel animal;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async => [animal];

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) => throw StateError('Unexpected upsertAnimal call');

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) => throw StateError('Unexpected cacheAnimal call');

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) => throw StateError('Unexpected getAnimalById call');

  @override
  Future<BrickAnimalModel?> getAnimalByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) => throw StateError('Unexpected getAnimalByRfidTagNumber call');

  @override
  Future<void> pullRemoteAnimals(String establishmentId) => throw StateError('Unexpected pullRemoteAnimals call');

  @override
  Future<void> retryRejectedAnimal(String animalId) => throw StateError('Unexpected retryRejectedAnimal call');
}

class _FakeLotStore implements LotBrickStore {
  const _FakeLotStore();

  @override
  Future<BrickLotModel?> getLocalLot(String lotId) async {
    final timestamp = DateTime.utc(2026, 9, 29);
    return BrickLotModel(
      localId: lotId,
      establishmentId: 'establishment-id',
      name: 'Destino',
      boundaryJson: '{}',
      surfaceTenths: 100,
      hasWater: true,
      statusCode: 'active',
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  @override
  Future<BrickLotModel> upsertLocalLot(BrickLotModel lot) => throw StateError('Unexpected upsertLocalLot call');

  @override
  Future<List<BrickLotModel>> getLocalLots(String establishmentId) => throw StateError('Unexpected getLocalLots call');

  @override
  Future<void> pullRemoteLots(String establishmentId) => throw StateError('Unexpected pullRemoteLots call');

  @override
  Future<void> pushPendingLots(String establishmentId) => throw StateError('Unexpected pushPendingLots call');
}
