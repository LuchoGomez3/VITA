import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/sync/queued_request.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory testDirectory;
  late String sqlitePath;
  late String queuePath;
  late AppBrickRepository repository;

  setUpAll(() async {
    sqfliteFfiInit();
    testDirectory = await Directory.systemTemp.createTemp('vita_queued_requests_test_');
    sqlitePath = path.join(testDirectory.path, 'brick.sqlite');
    queuePath = path.join(testDirectory.path, 'queue.sqlite');
    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: queuePath,
      localDatabaseFactory: databaseFactoryFfi,
      tokenProvider: const _TestTokenProvider(),
      // Backend caído: Brick deja la request en la cola para reintentar.
      client: MockClient((request) async => http.Response('server unavailable', 503)),
    );
    repository = AppBrickRepository.instance;
  });

  tearDownAll(() async {
    await databaseFactoryFfi.deleteDatabase(sqlitePath);
    await databaseFactoryFfi.deleteDatabase(queuePath);
    if (testDirectory.existsSync()) {
      await testDirectory.delete(recursive: true);
    }
  });

  test('una request sin respuesta del backend queda visible en la cola', () async {
    expect(await repository.queuedRequests(), isEmpty);

    final lot = await repository.upsertLocal(_lot());
    await repository.enqueueRemoteUpsert<BrickLotModel>(lot);

    final queued = await repository.queuedRequests();
    expect(queued, hasLength(1));
    expect(queued.single.method, 'POST');
    expect(queued.single.path, BrickLotRequestTransformer.lotsPath);
    expect(queued.single.attempts, greaterThanOrEqualTo(1));
    expect(queued.single.createdAt.year, DateTime.now().year);
  });

  test('la vista de la fila no arrastra headers ni body', () {
    final request = BrickQueuedRequest.fromQueueRow(const {
      'id': 7,
      'request_method': 'post',
      'url': 'https://api.example.test/api/v1/pesajes?x=1',
      'attempts': 3,
      'locked': 1,
      'created_at': 1000,
      'updated_at': 2000,
      'headers': '{"Authorization":"Bearer secreto"}',
      'body': '{"caravana":"003 1284"}',
    });

    expect(request.queueId, 7);
    expect(request.method, 'POST');
    expect(request.path, '/api/v1/pesajes');
    expect(request.attempts, 3);
    expect(request.isLocked, isTrue);
    expect(request.createdAt, DateTime.fromMillisecondsSinceEpoch(1000));
    expect(request.updatedAt, DateTime.fromMillisecondsSinceEpoch(2000));
  });
}

BrickLotModel _lot() {
  final timestamp = DateTime.utc(2026, 11, 3);
  return BrickLotModel(
    localId: 'lot-queued',
    establishmentId: 'establishment-id',
    name: 'La Loma',
    boundaryJson: '{}',
    surfaceTenths: 100,
    hasWater: true,
    statusCode: 'activo',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _TestTokenProvider implements BackendAccessTokenProvider {
  const _TestTokenProvider();

  @override
  Future<String?> getAccessToken() async => 'test-token';
}
