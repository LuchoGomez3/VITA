import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/brick_rejected_records_reader.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';
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
    testDirectory = await Directory.systemTemp.createTemp('vita_rejected_records_test_');
    sqlitePath = path.join(testDirectory.path, 'brick.sqlite');
    queuePath = path.join(testDirectory.path, 'queue.sqlite');
    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: queuePath,
      localDatabaseFactory: databaseFactoryFfi,
      tokenProvider: const _TestTokenProvider(),
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

  test('devuelve solo los rechazados de cada modelo, el más reciente primero', () async {
    final reader = BrickRejectedRecordsReader(repository);
    expect(await reader.read(), isEmpty);

    await repository.upsertLocal(
      _lot('lot-ok', DateTime.utc(2026, 11, 3, 10), BrickLotSyncStatus.synchronized),
    );
    await repository.upsertLocal(
      _lot('lot-rejected', DateTime.utc(2026, 11, 3, 9), BrickLotSyncStatus.rejected, errorCode: 'LOTE_SUPERPUESTO'),
    );
    await repository.upsertLocal(_pesaje('pesaje-rejected', DateTime.utc(2026, 11, 3, 12)));

    final rejected = await reader.read();

    expect(rejected.map((record) => record.localId), ['pesaje-rejected', 'lot-rejected']);
    expect(rejected.first.kind, SyncOperationKind.weighing);
    expect(rejected.first.errorCode, isNull);
    expect(rejected.last.kind, SyncOperationKind.lot);
    expect(rejected.last.errorCode, 'LOTE_SUPERPUESTO');
    expect(rejected.last.recordedAt, DateTime.utc(2026, 11, 3, 9));
  });
}

BrickLotModel _lot(String id, DateTime updatedAt, BrickLotSyncStatus status, {String? errorCode}) => BrickLotModel(
  localId: id,
  establishmentId: 'establishment-id',
  name: id,
  boundaryJson: '{}',
  surfaceTenths: 100,
  hasWater: true,
  statusCode: 'activo',
  createdAt: updatedAt,
  updatedAt: updatedAt,
  syncStatus: status,
  syncErrorCode: errorCode,
);

BrickPesajeModel _pesaje(String id, DateTime updatedAt) => BrickPesajeModel(
  localId: id,
  establishmentId: 'establishment-id',
  animalId: 'animal-id',
  weightKg: 320,
  date: updatedAt,
  createdAt: updatedAt,
  updatedAt: updatedAt,
  syncStatus: BrickPesajeSyncStatus.rejected,
);

class _TestTokenProvider implements BackendAccessTokenProvider {
  const _TestTokenProvider();

  @override
  Future<String?> getAccessToken() async => 'test-token';
}
