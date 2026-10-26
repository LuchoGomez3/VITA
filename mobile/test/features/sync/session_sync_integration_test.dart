import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/initial_data_sync_repository_impl.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/initial_data_sync_repository.dart';
import 'package:frontend_mayoral/features/sync/domain/services/offline_sync_coordinator.dart';
import 'package:frontend_mayoral/features/sync/domain/use_cases/prepare_initial_data_sync_use_case.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../team/team_fakes.dart';

void main() {
  test('el cambio de cuenta espera las escrituras viejas y deja en SQLite la versión nueva', () async {
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp('vita_session_sync_');
    final sqlitePath = path.join(directory.path, 'brick.sqlite');
    final queuePath = path.join(directory.path, 'queue.sqlite');
    addTearDown(() async {
      await databaseFactoryFfi.deleteDatabase(sqlitePath);
      await databaseFactoryFfi.deleteDatabase(queuePath);
      await directory.delete();
    });
    final provider = SessionBackendAccessTokenProvider.instance..startSession(_session('account-a'));
    addTearDown(provider.clearAccessToken);
    final previousResponse = Completer<http.Response>();
    final previousStarted = Completer<void>();
    final requests = <String>[];
    final client = MockClient((request) async {
      final account = request.headers['Authorization'];
      requests.add('$account ${request.url.path}');
      if (request.url.path == '/api/v1/establecimientos') {
        return _ok([
          {
            'id': 'shared-field',
            'owner_id': 'synthetic-owner',
            'nombre': 'Campo compartido',
            'rol': 'employee',
            'created_at': '2026-10-01T00:00:00Z',
            'updated_at': '2026-10-23T00:00:00Z',
          },
        ]);
      }
      if (request.url.path == '/api/v1/animales') {
        if (account == 'Bearer account-a') {
          previousStarted.complete();
          return previousResponse.future;
        }
        return _ok([_animal('NEW', DateTime.utc(2026, 10, 23))]);
      }
      return _ok(<Object?>[]);
    });
    addTearDown(client.close);
    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: queuePath,
      backendBaseUrl: 'https://api.example.com',
      localDatabaseFactory: databaseFactoryFfi,
      tokenProvider: provider,
      client: client,
    );
    final brick = AppBrickRepository.instance;
    BrickAnimalStore.configure(brick);
    BrickCategoriaStore.configure(brick);
    BrickLotStore.configure(brick);
    BrickPesajeStore.configure(brick);
    BrickAnimalLotMovementStore.configure(brick, animalStore: BrickAnimalStore.instance);
    final initialSync = _CountingSyncRepository(
      InitialDataSyncRepositoryImpl(
        secureStorage: MemoryStorage(),
        establishmentRemoteDataSource: EstablishmentRemoteDataSource(
          backendBaseUrl: 'https://api.example.com',
          tokenProvider: provider,
          client: client,
        ),
        animalStore: BrickAnimalStore.instance,
        categoryStore: BrickCategoriaStore.instance,
        lotStore: BrickLotStore.instance,
        weighingStore: BrickPesajeStore.instance,
        movementStore: BrickAnimalLotMovementStore.instance,
        syncOperatingExpenseData: (_) async => fail('Employee cannot sync finances'),
        sessionIdentity: () => provider.sessionGeneration,
        persistSessionData: provider.persistSessionData,
      ),
    );
    final coordinator = OfflineSyncCoordinator(
      prepareInitialDataSyncUseCase: PrepareInitialDataSyncUseCase(initialSync),
      sessionIdentity: () => provider.sessionGeneration,
    );
    addTearDown(coordinator.dispose);
    final published = <Result<PostAuthenticationSummary>>[];
    final subscription = coordinator.results.listen(published.add);
    addTearDown(subscription.cancel);
    final previous = coordinator.synchronize();
    await previousStarted.future;
    provider
      ..clearAccessToken()
      ..startSession(_session('account-b'));
    final current = coordinator.synchronize();
    addTearDown(() async {
      if (!previousResponse.isCompleted) previousResponse.complete(_ok([_animal('OLD', DateTime.utc(2026, 10, 22))]));
      await Future.wait([previous, current]);
    });

    final overlapped = initialSync.calls > 1;
    if (overlapped) await current;
    previousResponse.complete(_ok([_animal('OLD', DateTime.utc(2026, 10, 22))]));
    expect(await previous, isA<Failure<PostAuthenticationSummary>>());
    expect(await current, isA<Success<PostAuthenticationSummary>>());

    final animals = await brick.sqliteProvider.get<BrickAnimalModel>(repository: brick);
    expect(animals, hasLength(1));
    expect(animals.single.visualTag, 'NEW');
    expect(animals.single.updatedAt, DateTime.utc(2026, 10, 23));
    expect(overlapped, isFalse, reason: 'La cuenta nueva espera las escrituras anteriores');
    expect(initialSync.calls, 2);
    expect(published, hasLength(1));
    expect(requests.where((request) => request == 'Bearer account-a /api/v1/animales'), hasLength(1));
  });
}

class _CountingSyncRepository implements InitialDataSyncRepository {
  _CountingSyncRepository(this.delegate);
  final InitialDataSyncRepository delegate;
  int calls = 0;

  @override
  Future<Result<PostAuthenticationSummary>> sync() {
    calls++;
    return delegate.sync();
  }
}

BackendTokenSession _session(String token) => BackendTokenSession(
  accessToken: token,
  refreshToken: 'synthetic-refresh',
  accessTokenExpiresAt: DateTime.utc(2030),
);

Map<String, Object?> _animal(String visualTag, DateTime updatedAt) => {
  'id': 'shared-animal',
  'establecimiento_id': 'shared-field',
  'sexo': 'hembra',
  'caravana_visual': visualTag,
  'estado': 'activo',
  'created_at': '2026-10-01T00:00:00Z',
  'updated_at': updatedAt.toIso8601String(),
};

http.Response _ok(Object data) => http.Response(
  jsonEncode({'success': true, 'data': data}),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
