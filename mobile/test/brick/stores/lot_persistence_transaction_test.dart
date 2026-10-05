import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
      tokenProvider: const _TestTokenProvider(),
      client: MockClient(
        (request) async => http.Response('server unavailable', 503),
      ),
    );
    repository = AppBrickRepository.instance;
    BrickLotStore.configure(repository);
    BrickAnimalLotMovementStore.configure(repository);
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

  test('marca movimiento y animales como rechazados por backend', () async {
    final original = await repository.upsertLocal<BrickAnimalModel>(
      _animal(id: 'animal-rejected', lotId: 'source-lot'),
    );
    final movement = _movement(
      id: 'movement-rejected',
      animalId: 'animal-rejected',
    );
    await movementStore.saveWithAnimals(
      animals: [original.copyWith(lotId: 'destination-lot')],
      movement: movement,
    );

    await movementStore.applyMovementSyncResult(
      const BackendSyncResult(
        resourcePath: '/api/v1/movimientos_lotes',
        localId: 'movement-rejected',
        synchronized: false,
        errorCode: 'animales_no_pertenecen_lote_origen',
      ),
    );

    final movements = await repository.getLocal<BrickAnimalLotMovementModel>();
    final animals = await repository.getLocal<BrickAnimalModel>();
    expect(
      movements.singleWhere((item) => item.localId == movement.localId).syncStatus,
      BrickAnimalLotMovementSyncStatus.rejected,
    );
    final rejectedAnimal = animals.singleWhere(
      (item) => item.localId == 'animal-rejected',
    );
    expect(rejectedAnimal.syncStatus, BrickAnimalSyncStatus.rejected);
    expect(
      rejectedAnimal.syncErrorCode,
      'animales_no_pertenecen_lote_origen',
    );
  });

  test('reemplaza el lote local con la respuesta autoritativa', () async {
    final local = await lotStore.upsertLocalLot(
      _lot(id: 'lot-authoritative', name: 'Nombre local'),
    );

    await lotStore.applyLotSyncResult(
      BackendSyncResult(
        resourcePath: '/api/v1/lotes',
        localId: local.localId,
        synchronized: true,
        responseData: {
          'id': local.localId,
          'establecimiento_id': local.establishmentId,
          'nombre': 'Nombre servidor',
          'geometria_local': {
            'type': 'LocalPolygon',
            'coordinate_space': 'establishment_canvas_v1',
            'version': 1,
            'extent': {'width': 1000.0, 'height': 1000.0},
            'vertices': [
              {'x': 0.0, 'y': 0.0},
              {'x': 10.0, 'y': 0.0},
              {'x': 0.0, 'y': 10.0},
            ],
          },
          'modo_geometria': 'local_schematic',
          'superficie_ha': 10.0,
          'recurso_forrajero_codigo': null,
          'tiene_agua': true,
          'estado': 'activo',
          'created_at': '2026-08-31T00:00:00Z',
          'updated_at': '2026-08-31T00:00:00Z',
          'deleted_at': null,
        },
      ),
    );

    final saved = await lotStore.getLocalLot(local.localId);
    expect(saved?.name, 'Nombre servidor');
    expect(saved?.syncStatus, BrickLotSyncStatus.synchronized);
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
    statusCode: 'activo',
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

BrickAnimalLotMovementModel _movement({
  required String id,
  String animalId = 'animal-success',
}) {
  final timestamp = DateTime.utc(2026, 8, 31);
  return BrickAnimalLotMovementModel(
    localId: id,
    establishmentId: 'establishment-id',
    sourceLotId: 'source-lot',
    destinationLotId: 'destination-lot',
    animalIdsJson: '["$animalId"]',
    occurredAt: timestamp,
    reason: 'Rotacion',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _TestTokenProvider implements BackendAccessTokenProvider {
  const _TestTokenProvider();

  @override
  Future<String?> getAccessToken() async => 'test-token';
}
