import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_location_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_location.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_movement_history_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/movement_history_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/data/repositories/animal_movement_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
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
  final remoteBodies = <String, String>{};

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
        (request) async {
          final body = remoteBodies[request.url.path];
          return request.method == 'GET' && body != null
              ? http.Response(body, 200, headers: {'content-type': 'application/json'})
              : http.Response('server unavailable', 503);
        },
      ),
    );
    repository = AppBrickRepository.instance;
    BrickLotStore.configure(repository);
    BrickAnimalStore.configure(repository);
    BrickCategoriaStore.configure(repository);
    BrickAnimalLotMovementStore.configure(
      repository,
      animalStore: BrickAnimalStore.instance,
    );
    lotStore = BrickLotStore.instance;
    movementStore = BrickAnimalLotMovementStore.instance;
  });

  tearDown(remoteBodies.clear);

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

  for (final synchronized in [true, false]) {
    test('el historial abierto observa sync=$synchronized y la ubicación reconciliada después', () async {
      final animalId = 'live-animal-$synchronized';
      final movementId = 'live-movement-$synchronized';
      final original = await repository.upsertLocal(_animal(id: animalId, lotId: 'source-lot'));
      await repository.upsertLocal(
        _movement(
          id: 'previous-$synchronized',
          animalId: animalId,
          destinationLotId: 'source-lot',
          createdAt: DateTime.utc(2025),
          syncStatus: BrickAnimalLotMovementSyncStatus.synchronized,
        ),
      );
      await movementStore.saveWithAnimals(
        animals: [original.copyWith(lotId: 'destination-lot')],
        movement: _movement(id: movementId, animalId: animalId),
      );
      final cubit = MovementHistoryCubit(
        GetAnimalMovementHistoryUseCase(
          AnimalMovementRepositoryImpl(
            animalStore: BrickAnimalStore.instance,
            lotStore: lotStore,
            categoryStore: BrickCategoriaStore.instance,
            movementStore: movementStore,
            localChanges: repository.localChanges,
          ),
        ),
      );
      addTearDown(cubit.close);
      final location = StreamIterator(
        AnimalLocationRepositoryImpl(
          animalStore: BrickAnimalStore.instance,
          lotStore: lotStore,
          localChanges: repository.localChanges,
        ).watchLocation(animalId, establishmentId: 'establishment-id'),
      );
      addTearDown(location.cancel);
      expect(await location.moveNext(), isTrue);
      expect((location.current as Success<AnimalLocation?>).data?.lotId, 'destination-lot');
      await cubit.load(animalId);
      final initial = (cubit.state as Data<List<MovementHistoryEntry>>).data;
      expect(initial.singleWhere((entry) => entry.isCurrent).movementId, movementId);
      expect(initial.singleWhere((entry) => entry.movementId == movementId).syncStatus, MovementSyncStatus.pending);

      final expectedStatus = synchronized ? MovementSyncStatus.synchronized : MovementSyncStatus.rejected;
      final updated = cubit.stream.firstWhere(
        (state) =>
            state is Data<List<MovementHistoryEntry>> &&
            state.data.any((entry) => entry.movementId == movementId && entry.syncStatus == expectedStatus),
      );
      await movementStore.applyMovementSyncResult(
        BackendSyncResult(
          resourcePath: '/api/v1/movimientos_lotes',
          localId: movementId,
          synchronized: synchronized,
          errorCode: synchronized ? null : 'animales_no_pertenecen_lote_origen',
        ),
      );
      await updated;

      // La ubicación autoritativa puede persistirse después del resultado HTTP.
      final reconciled = cubit.stream.firstWhere(
        (state) =>
            state is Data<List<MovementHistoryEntry>> &&
            state.data.any((entry) => entry.movementId == 'previous-$synchronized' && entry.isCurrent),
      );
      final locationChanged = location.moveNext();
      await repository.upsertLocal(original.copyWith(lotId: 'source-lot'));
      await reconciled;
      expect(await locationChanged, isTrue);
      expect((location.current as Success<AnimalLocation?>).data?.lotId, 'source-lot');
    });
  }

  test('una transacción revertida no invalida lecturas locales', () async {
    final changes = <Type>[];
    final subscription = repository.localChanges.listen(changes.add);
    addTearDown(subscription.cancel);
    await expectLater(
      repository.runLocalTransaction<void>((transaction) async {
        await transaction.upsert(_animal(id: 'no-notification', lotId: 'source-lot'));
        throw StateError('rollback');
      }),
      throwsStateError,
    );
    await Future<void>.delayed(Duration.zero);
    expect(changes, isEmpty);
  });

  test('500 animales y un movimiento notifican una vez por tipo después del commit', () async {
    final changes = <Type>[];
    final subscription = repository.localChanges.listen(changes.add);
    addTearDown(subscription.cancel);

    await repository.runLocalTransaction((transaction) async {
      for (var i = 0; i < 500; i++) {
        await transaction.upsert(_animal(id: 'batch-$i', lotId: 'source-lot'));
      }
      await transaction.upsert(_movement(id: 'batch-movement', animalId: 'batch-0'));
    });
    await Future<void>.delayed(Duration.zero);

    expect(changes, [BrickAnimalModel, BrickAnimalLotMovementModel]);
    final saved = await BrickAnimalStore.instance.getLocalAnimals();
    expect(saved.where((animal) => animal.localId.startsWith('batch-')), hasLength(500));
  });

  test('un pull de animales persiste toda la tanda con una sola invalidación', () async {
    final adapter = repository.remoteProvider.modelDictionary.adapterFor[BrickAnimalModel]!;
    final data = [
      for (var i = 0; i < 50; i++)
        await adapter.toRest(
          _animal(id: 'pulled-$i', lotId: 'source-lot'),
          provider: repository.remoteProvider,
          repository: repository,
        ),
    ];
    remoteBodies['/api/v1/animales'] = jsonEncode({'success': true, 'data': data});
    final changes = <Type>[];
    final subscription = repository.localChanges.listen(changes.add);
    addTearDown(subscription.cancel);

    await BrickAnimalStore.instance.pullRemoteAnimals('establishment-id');
    await Future<void>.delayed(Duration.zero);

    expect(changes, [BrickAnimalModel]);
    final saved = await BrickAnimalStore.instance.getLocalAnimals();
    expect(saved.where((animal) => animal.localId.startsWith('pulled-')), hasLength(50));
  });

  test('los pulls de lotes y movimientos notifican una sola vez por tanda', () async {
    final lotAdapter = repository.remoteProvider.modelDictionary.adapterFor[BrickLotModel]!;
    final movementAdapter = repository.remoteProvider.modelDictionary.adapterFor[BrickAnimalLotMovementModel]!;
    final lots = [
      for (var i = 0; i < 30; i++)
        await lotAdapter.toRest(
          _lot(id: 'pulled-lot-$i', name: 'Potrero $i'),
          provider: repository.remoteProvider,
          repository: repository,
        ),
    ];
    final movements = [
      for (var i = 0; i < 30; i++)
        await movementAdapter.toRest(
          _movement(id: 'pulled-movement-$i'),
          provider: repository.remoteProvider,
          repository: repository,
        ),
    ];
    remoteBodies['/api/v1/lotes'] = jsonEncode({'success': true, 'data': lots});
    remoteBodies['/api/v1/movimientos_lotes'] = jsonEncode({'success': true, 'data': movements});
    final changes = <Type>[];
    final subscription = repository.localChanges.listen(changes.add);
    addTearDown(subscription.cancel);

    await lotStore.pullRemoteLots('establishment-id');
    await movementStore.pullRemoteMovements('establishment-id');
    await Future<void>.delayed(Duration.zero);

    expect(changes, [BrickLotModel, BrickAnimalLotMovementModel]);
    expect(
      (await lotStore.getLocalLots('establishment-id')).where((lot) => lot.localId.startsWith('pulled-lot-')),
      hasLength(30),
    );
    expect(
      (await movementStore.getLocalMovements(
        'establishment-id',
      )).where((movement) => movement.localId.startsWith('pulled-movement-')),
      hasLength(30),
    );
  });

  test('la lectura histórica puede resolver un lote borrado en SQLite', () async {
    await repository.upsertLocal(_lot(id: 'history-lot', name: 'Potrero anterior', deletedAt: DateTime.utc(2026, 9)));

    final activeLots = await lotStore.getLocalLots('establishment-id');
    final historyLots = await lotStore.getLocalLots('establishment-id', includeDeleted: true);

    expect(activeLots.where((lot) => lot.localId == 'history-lot'), isEmpty);
    expect(historyLots.singleWhere((lot) => lot.localId == 'history-lot').name, 'Potrero anterior');
  });

  test('leer movimientos deduplica antes de aplicar tombstones y filtra el tenant', () async {
    final old = DateTime.utc(2026, 8);
    final recent = DateTime.utc(2026, 9);
    for (final movement in [
      _movement(id: 'history-deleted', establishmentId: 'history-tenant', updatedAt: old),
      _movement(id: 'history-deleted', establishmentId: 'history-tenant', updatedAt: recent, deletedAt: recent),
      _movement(id: 'history-alive', establishmentId: 'history-tenant', updatedAt: old),
      _movement(id: 'history-alive', establishmentId: 'history-tenant', updatedAt: recent),
      _movement(id: 'history-other', establishmentId: 'other-tenant'),
    ]) {
      await repository.upsertLocal(movement);
    }

    final history = await movementStore.getLocalMovements('history-tenant');

    expect(history.single.localId, 'history-alive');
    expect(history.single.updatedAt, recent);
    expect(history.single.deletedAt, isNull);
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

  test('el rechazo queda aislado en el agregado movimiento', () async {
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
    expect(rejectedAnimal.syncStatus, original.syncStatus);
    expect(rejectedAnimal.syncErrorCode, original.syncErrorCode);
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
  DateTime? deletedAt,
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
    deletedAt: deletedAt,
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
  String destinationLotId = 'destination-lot',
  DateTime? createdAt,
  BrickAnimalLotMovementSyncStatus syncStatus = BrickAnimalLotMovementSyncStatus.pending,
  String animalId = 'animal-success',
  String establishmentId = 'establishment-id',
  DateTime? updatedAt,
  DateTime? deletedAt,
}) {
  final timestamp = DateTime.utc(2026, 8, 31);
  return BrickAnimalLotMovementModel(
    localId: id,
    establishmentId: establishmentId,
    sourceLotId: 'source-lot',
    destinationLotId: destinationLotId,
    animalIdsJson: '["$animalId"]',
    occurredAt: timestamp,
    reason: 'Rotacion',
    createdAt: createdAt ?? timestamp,
    updatedAt: updatedAt ?? timestamp,
    deletedAt: deletedAt,
    syncStatus: syncStatus,
  );
}

class _TestTokenProvider implements BackendAccessTokenProvider {
  const _TestTokenProvider();

  @override
  Future<String?> getAccessToken() async => 'test-token';
}
