import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
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
    BrickAnimalLotMovementStore.configure(
      AppBrickRepository.instance,
      enableRemoteSync: false,
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
}

BrickAnimalModel _animal(BrickAnimalProductiveStatus status) {
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
    createdAt: timestamp,
    updatedAt: timestamp,
  );
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
