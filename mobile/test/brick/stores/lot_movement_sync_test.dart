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
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppBrickRepository repository;
  late BrickAnimalLotMovementStore movements;
  late Directory directory;
  final requests = <http.Request>[];
  var online = false;
  final remoteByPath = <String, List<Map<String, dynamic>>>{};
  setUpAll(() async {
    sqfliteFfiInit();
    directory = await Directory.systemTemp.createTemp('vita_movement_sync_');
    await AppBrickRepository.configure(
      sqlitePath: '${directory.path}/data.db',
      offlineQueuePath: '${directory.path}/queue.db',
      backendBaseUrl: 'http://localhost:8000',
      localDatabaseFactory: databaseFactoryFfi,
      tokenProvider: _Token(),
      client: MockClient((request) async {
        requests.add(request);
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({'success': true, 'data': remoteByPath[request.url.path] ?? []}),
            200,
            request: request,
          );
        }
        return http.Response(
          online ? '{"success":true,"data":{}}' : '{"error":"offline"}',
          online ? 201 : 503,
          request: request,
        );
      }),
    );
    repository = AppBrickRepository.instance;
    repository.offlineQueueForTesting.stop();
    BrickAnimalStore.configure(repository);
    BrickLotStore.configure(repository);
    BrickAnimalLotMovementStore.configure(repository);
    movements = BrickAnimalLotMovementStore.instance;
    await Future<void>.delayed(Duration.zero);
    await repository.upsertLocal(_lot('destination'));
  });
  tearDownAll(() async {
    await movements.dispose();
    await BrickAnimalStore.instance.dispose();
    await BrickLotStore.instance.dispose();
    await databaseFactoryFfi.deleteDatabase('${directory.path}/data.db');
    await databaseFactoryFfi.deleteDatabase('${directory.path}/queue.db');
    await directory.delete(recursive: true);
  });
  Future<BrickAnimalModel> animal(String id) async => (await BrickAnimalStore.instance.getAnimalById(id))!;
  // Conserva la PK para modificar el mismo lote, sin insertar otra fila local.
  Future<void> destinationStatus(BrickLotSyncStatus status) async {
    final lot = (await BrickLotStore.instance.getLocalLot('destination'))!;
    await repository.upsertLocal(lot.copyWith(syncStatus: status));
  }

  Future<List<Map<String, dynamic>>> jobsFor(String id) async =>
      (await repository.offlineQueueForTesting.client.requestManager.unprocessedRequests())
          .where((job) => (jsonDecode(job['body'] as String) as Map<String, dynamic>)['id'] == id)
          .toList();

  test('asignación inicial es durable y encola exactamente el contrato sin responsable', () async {
    await repository.upsertLocal(_animal('initial', ''));
    await movements.moveAnimals(_movement('initial-move', 'initial', null));
    await movements.recoverPending();
    final stored = await animal('initial');
    expect(stored.lotId, 'destination');
    expect(stored.lotSyncStatus, BrickAnimalSyncStatus.pending);
    expect(stored.syncStatus, BrickAnimalSyncStatus.synchronized);
    final job = (await jobsFor('initial-move')).single;
    final body = jsonDecode(job['body'] as String) as Map<String, dynamic>;
    expect(
      body.keys,
      unorderedEquals([
        'id',
        'establecimiento_id',
        'lote_origen_id',
        'lote_destino_id',
        'animal_ids',
        'fecha_movimiento',
        'motivo',
      ]),
    );
    expect(body['lote_origen_id'], isNull);
    expect(body['animal_ids'], ['initial']);
    expect(job['url'], 'http://localhost:8000/api/v1/movimientos_lotes');
    expect(job['request_method'], 'POST');
  });
  test('traslado mantiene historial y rechaza orígenes mixtos sin cambios parciales', () async {
    await repository.upsertLocal(_animal('transfer', 'source'));
    await repository.upsertLocal(_animal('other', 'different'));
    final invalid = BrickAnimalLotMovementModel(
      localId: 'mixed',
      establishmentId: 'establishment',
      sourceLotId: 'source',
      destinationLotId: 'destination',
      animalIdsJson: '["transfer","other"]',
      occurredAt: _date,
      reason: 'Rotación',
      createdAt: _date,
      updatedAt: _date,
    );
    await expectLater(movements.moveAnimals(invalid), throwsA(isA<DomainException>()));
    expect((await animal('transfer')).lotId, 'source');
    expect((await movements.getLocalMovements('establishment')).any((m) => m.localId == 'mixed'), isFalse);
    await movements.moveAnimals(_movement('transfer-move', 'transfer', 'source'));
    expect((await animal('transfer')).lotId, 'destination');
    expect(
      (await movements.getLocalMovements('establishment')).firstWhere((m) => m.localId == 'transfer-move').sourceLotId,
      'source',
    );
  });
  test('reintentos offline y recuperación deduplican jobs y conservan UUID y payload', () async {
    final originalJob = (await jobsFor('initial-move')).single;
    final request = repository.offlineQueueForTesting.client.requestManager.sqliteToRequest(originalJob)!;
    online = false;
    await repository.offlineQueueForTesting.transmitRequest(request);
    expect(requests.last.headers['authorization'], 'Bearer synthetic-test-token');
    expect(await jobsFor('initial-move'), hasLength(1));
    await movements.recoverPending();
    await movements.retry('initial-move');
    expect(await jobsFor('initial-move'), hasLength(1));
    expect((await jobsFor('initial-move')).single['body'], originalJob['body']);
    // Simula cierre luego de guardar el movimiento, antes de persistir su job.
    await repository.offlineQueueForTesting.client.requestManager.deleteUnprocessedRequest(
      (await jobsFor('initial-move')).single['id'] as int,
    );
    await movements.recoverPending();
    expect((await jobsFor('initial-move')).single['body'], originalJob['body']);
  });
  test('rechazo sigue visible y otra edición no confirma la ubicación', () async {
    await movements.applySyncResult(
      const BackendSyncResult(
        resourcePath: '/api/v1/movimientos_lotes',
        localId: 'transfer-move',
        synchronized: false,
        errorCode: 'source_conflict',
      ),
    );
    await BrickAnimalStore.instance.applyAnimalSyncResult(
      const BackendSyncResult(resourcePath: '/api/v1/animales/transfer', localId: 'transfer', synchronized: true),
    );
    expect((await animal('transfer')).lotSyncStatus, BrickAnimalSyncStatus.rejected);
    final rejected = (await movements.getLocalMovements(
      'establishment',
    )).firstWhere((m) => m.localId == 'transfer-move');
    expect(rejected.syncStatus, BrickMovementSyncStatus.rejected);
    expect(rejected.syncErrorCode, 'source_conflict');
    await movements.retry('transfer-move');
    expect((await animal('transfer')).lotSyncStatus, BrickAnimalSyncStatus.pending);
    expect((await jobsFor('transfer-move')).single['body'], contains('"id":"transfer-move"'));
  });
  test('HTTP 201 confirma el mismo movimiento y elimina su job', () async {
    online = true;
    final job = (await jobsFor('initial-move')).single;
    await repository.offlineQueueForTesting.transmitRequest(
      repository.offlineQueueForTesting.client.requestManager.sqliteToRequest(job)!,
    );
    // El cliente publica el resultado por el stream compartido de Brick.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await jobsFor('initial-move'), isEmpty);
    expect((await animal('initial')).lotSyncStatus, BrickAnimalSyncStatus.synchronized);
    expect(
      (await movements.getLocalMovements('establishment')).firstWhere((m) => m.localId == 'initial-move').syncStatus,
      BrickMovementSyncStatus.synchronized,
    );
    await movements.moveAnimals(_movement('initial-move', 'initial', null));
    expect(
      (await movements.getLocalMovements('establishment')).where((m) => m.localId == 'initial-move'),
      hasLength(1),
    );
    expect(await jobsFor('initial-move'), isEmpty);
    await expectLater(movements.moveAnimals(_movement('initial-move', 'other', null)), throwsA(isA<DomainException>()));
  });
  test('destino sólo local no permite guardar ni cambiar la ubicación', () async {
    await destinationStatus(BrickLotSyncStatus.pending);
    await repository.upsertLocal(_animal('local-destination-animal', 'source'));
    await expectLater(
      movements.moveAnimals(_movement('invalid-local-destination', 'local-destination-animal', 'source')),
      throwsA(isA<DomainException>()),
    );
    expect((await animal('local-destination-animal')).lotId, 'source');
    expect(await jobsFor('invalid-local-destination'), isEmpty);
    await destinationStatus(BrickLotSyncStatus.synchronized);
  });
  test('rechazo de un destino local libera animales y conserva el intento sin reencolarlo', () async {
    await repository.upsertLocal(_animal('released-animal', ''));
    final movement = _movement('released-move', 'released-animal', null);
    // Representa una operación guardada con la versión anterior de la app.
    await movements.moveAnimals(movement);
    await destinationStatus(BrickLotSyncStatus.pending);
    await movements.applySyncResult(
      const BackendSyncResult(
        resourcePath: '/api/v1/movimientos_lotes',
        localId: 'released-move',
        synchronized: false,
        errorCode: 'lote_destino_no_disponible',
      ),
    );
    expect((await animal('released-animal')).lotId, '');
    expect((await animal('released-animal')).lotSyncStatus, BrickAnimalSyncStatus.synchronized);
    final stored = (await movements.getLocalMovements('establishment')).firstWhere((m) => m.localId == 'released-move');
    expect(stored.syncStatus, BrickMovementSyncStatus.rejected);
    expect(stored.syncErrorCode, startsWith(BrickAnimalLotMovementStore.releasedDestinationPrefix));
    await movements.recoverPending();
    expect(await jobsFor('released-move'), isEmpty);
    await expectLater(movements.retry('released-move'), throwsA(isA<DomainException>()));
    await destinationStatus(BrickLotSyncStatus.synchronized);
    await movements.moveAnimals(_movement('replacement-move', 'released-animal', null));
    expect((await animal('released-animal')).lotId, 'destination');
    // Una respuesta atrasada del intento anterior no afecta el nuevo traslado.
    await movements.applySyncResult(
      const BackendSyncResult(
        resourcePath: '/api/v1/movimientos_lotes',
        localId: 'released-move',
        synchronized: false,
        errorCode: 'lote_destino_no_disponible',
      ),
    );
    expect((await animal('released-animal')).lotMovementId, 'replacement-move');
    expect((await animal('released-animal')).lotSyncStatus, BrickAnimalSyncStatus.pending);
  });
  test('un pendiente o job en vuelo no se libera hasta conocer el rechazo definitivo', () async {
    await repository.upsertLocal(_animal('in-flight-animal', 'source'));
    await movements.moveAnimals(_movement('in-flight-move', 'in-flight-animal', 'source'));
    await destinationStatus(BrickLotSyncStatus.pending);
    await movements.recoverPending();
    expect((await animal('in-flight-animal')).lotSyncStatus, BrickAnimalSyncStatus.pending);
    final manager = repository.offlineQueueForTesting.client.requestManager;
    final db = await manager.getDb();
    final job = (await jobsFor('in-flight-move')).single;
    // Simula el bloqueo que Brick toma antes de transmitir la request.
    await db.update(manager.tableName, {manager.lockedColumn: 1}, where: 'id = ?', whereArgs: [job['id']]);
    await movements.applySyncResult(
      const BackendSyncResult(
        resourcePath: '/api/v1/movimientos_lotes',
        localId: 'in-flight-move',
        synchronized: false,
        errorCode: 'lote_destino_no_disponible',
      ),
    );
    expect((await animal('in-flight-animal')).lotId, 'destination');
    expect(await jobsFor('in-flight-move'), hasLength(1));
    await db.update(manager.tableName, {manager.lockedColumn: 0}, where: 'id = ?', whereArgs: [job['id']]);
    await movements.recoverPending();
    expect((await animal('in-flight-animal')).lotId, 'source');
    expect((await animal('in-flight-animal')).lotSyncStatus, BrickAnimalSyncStatus.synchronized);
    expect(await jobsFor('in-flight-move'), isEmpty);
    await destinationStatus(BrickLotSyncStatus.synchronized);
  });
  test('GET de lotes activos e historial hidrata ubicaciones recibidas de otro dispositivo', () async {
    final provider = repository.remoteProvider;
    final lotData = await provider.modelDictionary.adapterFor[BrickLotModel]!.toRest(
      _lot('destination'),
      provider: provider,
      repository: repository,
    );
    final animalData = await provider.modelDictionary.adapterFor[BrickAnimalModel]!.toRest(
      _animal('remote-animal', 'destination'),
      provider: provider,
      repository: repository,
    );
    final pendingData = await provider.modelDictionary.adapterFor[BrickAnimalModel]!.toRest(
      _animal('transfer', 'source'),
      provider: provider,
      repository: repository,
    );
    final unassignedData = await provider.modelDictionary.adapterFor[BrickAnimalModel]!.toRest(
      _animal('remote-unassigned', ''),
      provider: provider,
      repository: repository,
    );
    unassignedData['lote_id'] = null;
    final movementData = await provider.modelDictionary.adapterFor[BrickAnimalLotMovementModel]!.toRest(
      _movement('remote-history', 'remote-animal', null),
      provider: provider,
      repository: repository,
    );
    movementData.addAll({
      'created_at': _date.toIso8601String(),
      'updated_at': _date.toIso8601String(),
      'responsable_id': null,
    });
    remoteByPath.addAll({
      '/api/v1/lotes': [lotData],
      '/api/v1/animales': [animalData, unassignedData, pendingData],
      '/api/v1/movimientos_lotes': [movementData],
    });
    await BrickLotStore.instance.pullActiveLots('establishment');
    await movements.pullMovements('establishment');
    expect((await animal('remote-animal')).lotId, 'destination');
    expect((await animal('remote-unassigned')).lotId, '');
    expect((await animal('transfer')).lotId, 'destination');
    expect((await animal('transfer')).lotSyncStatus, BrickAnimalSyncStatus.pending);
    final history = (await movements.getLocalMovements(
      'establishment',
    )).firstWhere((m) => m.localId == 'remote-history');
    expect(history.syncStatus, BrickMovementSyncStatus.synchronized);
    expect(history.sourceLotId, isNull);
    final lotRequest = requests.lastWhere((r) => r.url.path == '/api/v1/lotes');
    expect(lotRequest.url.queryParameters, {'establecimiento_id': 'establishment', 'estado': 'activo'});
    final animalRequest = requests.lastWhere((r) => r.url.path == '/api/v1/animales');
    expect(animalRequest.url.queryParameters['establecimiento_id'], 'establishment');
    expect(animalRequest.url.queryParameters.containsKey('lote_id'), isFalse);
    final historyRequest = requests.lastWhere((r) => r.url.path == '/api/v1/movimientos_lotes' && r.method == 'GET');
    expect(historyRequest.url.queryParameters['establecimiento_id'], 'establishment');
  });
  test('confirmaciones concurrentes de edición y movimiento preservan ambos estados', () async {
    await repository.upsertLocal(_animal('concurrent', 'source').copyWith(syncStatus: BrickAnimalSyncStatus.pending));
    await movements.moveAnimals(_movement('concurrent-move', 'concurrent', 'source'));
    await Future.wait([
      BrickAnimalStore.instance.applyAnimalSyncResult(
        const BackendSyncResult(resourcePath: '/api/v1/animales/concurrent', localId: 'concurrent', synchronized: true),
      ),
      movements.applySyncResult(
        const BackendSyncResult(
          resourcePath: '/api/v1/movimientos_lotes',
          localId: 'concurrent-move',
          synchronized: true,
        ),
      ),
    ]);
    final stored = await animal('concurrent');
    expect(stored.syncStatus, BrickAnimalSyncStatus.synchronized);
    expect(stored.lotSyncStatus, BrickAnimalSyncStatus.synchronized);
    expect(stored.lotId, 'destination');
  });
}

final _date = DateTime.utc(2026, 10, 5, 12);
BrickLotModel _lot(String id) => BrickLotModel(
  localId: id,
  establishmentId: 'establishment',
  name: 'Norte',
  boundaryJson: '{}',
  surfaceTenths: 100,
  hasWater: true,
  statusCode: 'activo',
  createdAt: _date,
  updatedAt: _date,
  syncStatus: BrickLotSyncStatus.synchronized,
);
BrickAnimalModel _animal(String id, String lotId) => BrickAnimalModel(
  localId: id,
  rfidTagNumber: id,
  visualTag: id,
  sex: BrickAnimalSex.female,
  breed: 'Angus',
  birthDate: _date,
  categoryId: 'cow',
  lotId: lotId,
  establishmentId: 'establishment',
  initialWeight: null,
  weighingMethod: BrickAnimalWeighingMethod.manual,
  weighingDate: _date,
  createdAt: _date,
  updatedAt: _date,
  syncStatus: BrickAnimalSyncStatus.synchronized,
);
BrickAnimalLotMovementModel _movement(String id, String animalId, String? source) => BrickAnimalLotMovementModel(
  localId: id,
  establishmentId: 'establishment',
  sourceLotId: source,
  destinationLotId: 'destination',
  animalIdsJson: jsonEncode([animalId]),
  occurredAt: _date,
  reason: 'Rotación',
  createdAt: _date,
  updatedAt: _date,
);

/// Token sintético para comprobar el header sin usar credenciales reales.
class _Token implements BackendAccessTokenProvider {
  @override
  Future<String?> getAccessToken() async => 'synthetic-test-token';
}
