import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory testDirectory;
  late String sqlitePath;
  late String queuePath;
  late AppBrickRepository repository;
  late BrickLotStore lotStore;
  late BrickAnimalLotMovementStore movementStore;

  setUpAll(() async {
    sqfliteFfiInit();
    testDirectory = await Directory.systemTemp.createTemp(
      'vita_lot_persistence_test_',
    );
    sqlitePath = path.join(testDirectory.path, 'brick.sqlite');
    queuePath = path.join(testDirectory.path, 'queue.sqlite');
    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: queuePath,
      localDatabaseFactory: databaseFactoryFfi,
    );
    repository = AppBrickRepository.instance;
    BrickLotStore.configure(repository, enableRemoteSync: false);
    BrickAnimalLotMovementStore.configure(
      repository,
      enableRemoteSync: false,
    );
    lotStore = BrickLotStore.instance;
    movementStore = BrickAnimalLotMovementStore.instance;
  });

  tearDownAll(() async {
    await databaseFactoryFfi.deleteDatabase(sqlitePath);
    await databaseFactoryFfi.deleteDatabase(queuePath);
    if (testDirectory.existsSync()) {
      await testDirectory.delete(recursive: true);
    }
  });

  test('editar el mismo UUID conserva una sola fila SQLite', () async {
    await lotStore.upsertLocalLot(_lot(id: 'lot-upsert', name: 'Original'));

    await lotStore.upsertLocalLot(
      _lot(
        id: 'lot-upsert',
        name: 'Editado',
        updatedAt: DateTime.utc(2026, 8, 31, 12),
      ),
    );

    final stored = await repository.sqliteProvider.get<BrickLotModel>(
      repository: repository,
    );
    final matches = stored.where((lot) => lot.localId == 'lot-upsert');
    expect(matches, hasLength(1));
    expect(matches.single.name, 'Editado');
  });

  test('revierte todas las escrituras cuando falla la transaccion', () async {
    final original = await repository.upsertLocal<BrickAnimalModel>(
      _animal(id: 'animal-rollback', lotId: 'source-lot'),
    );

    await expectLater(
      repository.runLocalTransaction<void>((transaction) async {
        await transaction.upsert<BrickAnimalModel>(
          original.copyWith(lotId: 'destination-lot'),
        );
        throw StateError('forced transaction failure');
      }),
      throwsStateError,
    );

    final stored = await repository.sqliteProvider.get<BrickAnimalModel>(
      repository: repository,
    );
    final animal = stored.singleWhere(
      (item) => item.localId == 'animal-rollback',
    );
    expect(animal.lotId, 'source-lot');
  });

  test('guarda animales y movimiento dentro de la misma operacion', () async {
    final original = await repository.upsertLocal<BrickAnimalModel>(
      _animal(id: 'animal-success', lotId: 'source-lot'),
    );
    final movement = _movement(id: 'movement-success');

    await movementStore.saveWithAnimals(
      animals: [original.copyWith(lotId: 'destination-lot')],
      movement: movement,
    );

    final animals = await repository.sqliteProvider.get<BrickAnimalModel>(
      repository: repository,
    );
    final movements = await repository.sqliteProvider.get<BrickAnimalLotMovementModel>(repository: repository);
    expect(
      animals.singleWhere((item) => item.localId == 'animal-success').lotId,
      'destination-lot',
    );
    expect(
      movements.where((item) => item.localId == movement.localId),
      hasLength(1),
    );
  });
}

BrickLotModel _lot({
  required String id,
  required String name,
  DateTime? updatedAt,
}) {
  final timestamp = updatedAt ?? DateTime.utc(2026, 8, 31);
  return BrickLotModel(
    localId: id,
    establishmentId: 'establishment-id',
    name: name,
    boundaryJson: '{}',
    surfaceTenths: 100,
    hasWater: true,
    statusCode: 'active',
    createdAt: DateTime.utc(2026, 8, 31),
    updatedAt: timestamp,
  );
}

BrickAnimalModel _animal({required String id, required String lotId}) {
  final timestamp = DateTime.utc(2026, 8, 31);
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: '982000412991416',
    visualTag: '003 1295',
    sex: BrickAnimalSex.female,
    breed: 'Aberdeen Angus',
    birthDate: DateTime.utc(2025, 3, 14),
    categoryId: 'category-id',
    lotId: lotId,
    establishmentId: 'establishment-id',
    initialWeight: 32.5,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: timestamp,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

BrickAnimalLotMovementModel _movement({required String id}) {
  final timestamp = DateTime.utc(2026, 8, 31);
  return BrickAnimalLotMovementModel(
    localId: id,
    establishmentId: 'establishment-id',
    sourceLotId: 'source-lot',
    destinationLotId: 'destination-lot',
    animalIdsJson: '["animal-success"]',
    occurredAt: timestamp,
    reason: 'Rotacion',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
