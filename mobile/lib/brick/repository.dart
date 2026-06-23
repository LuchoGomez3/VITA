import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/authenticated_backend_client.dart';
import 'package:frontend_mayoral/brick/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/db/schema.g.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

/// Contract used by feature repositories to persist animal registrations.
abstract class AnimalBrickStore {
  /// Persists [animal] locally in Brick and leaves it ready for future sync.
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal);
}

/// Offline-first Brick repository used across the mobile app.
class AppBrickRepository extends OfflineFirstWithRestRepository<BrickAnimalModel> implements AnimalBrickStore {
  AppBrickRepository._({
    required super.sqliteProvider,
    required super.restProvider,
    required super.migrations,
    required super.offlineQueueManager,
    required super.reattemptForStatusCodes,
  });

  static AppBrickRepository? _instance;

  /// Singleton repository configured during app startup.
  static AppBrickRepository get instance {
    final repository = _instance;
    if (repository == null) {
      throw StateError('AppBrickRepository has not been initialized yet.');
    }
    return repository;
  }

  /// Configures and initializes the shared Brick repository.
  static Future<void> configure({
    required String sqlitePath,
    required String offlineQueuePath,
    String? backendBaseUrl,
    BackendAccessTokenProvider tokenProvider = const DartDefineBackendAccessTokenProvider(),
    http.Client? client,
  }) async {
    if (_instance != null) {
      return;
    }

    final sqliteProvider = SqliteProvider(
      sqlitePath,
      databaseFactory: databaseFactory,
      modelDictionary: sqliteModelDictionary,
    );
    final syncResults = StreamController<AnimalSyncResult>();
    final restClient = AuthenticatedBackendClient(
      tokenProvider: tokenProvider,
      inner: client,
      onAnimalSyncResult: (result) {
        syncResults.add(result);
        return Future<void>.value();
      },
    );
    final restProvider = RestProvider(
      backendBaseUrl ?? AppConfig.current.backendBaseUrl,
      modelDictionary: restModelDictionary,
      client: restClient,
    );

    final repository = AppBrickRepository._(
      sqliteProvider: sqliteProvider,
      restProvider: restProvider,
      migrations: migrations.toSet(),
      offlineQueueManager: RestRequestSqliteCacheManager(
        offlineQueuePath,
        databaseFactory: databaseFactory,
      ),
      reattemptForStatusCodes: const [500, 501, 502, 503, 504],
    );

    syncResults.stream.listen(repository.applyAnimalSyncResult);

    await repository.initialize();
    _instance = repository;
  }

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async {
    final primaryKey = await sqliteProvider.upsert<BrickAnimalModel>(
      animal,
      repository: this,
    );
    final savedAnimal = animal..primaryKey = primaryKey;
    memoryCacheProvider.upsert<BrickAnimalModel>(savedAnimal);
    await notifySubscriptionsWithLocalData<BrickAnimalModel>();

    unawaited(_enqueueAnimalUpsert(savedAnimal));

    return savedAnimal;
  }

  Future<void> _enqueueAnimalUpsert(BrickAnimalModel animal) async {
    try {
      await remoteProvider.upsert<BrickAnimalModel>(
        animal,
        repository: this,
      );
    } on Object catch (error) {
      logger.warning('#upsert animal sync enqueue failure: $error');
    }
  }

  /// Applies the backend sync result to the local Brick record.
  Future<void> applyAnimalSyncResult(AnimalSyncResult result) async {
    final storedAnimals = await get<BrickAnimalModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );

    for (final animal in storedAnimals) {
      if (animal.localId != result.localId) {
        continue;
      }

      final updatedAnimal = animal.copyWith(
        syncStatus: result.synchronized ? BrickAnimalSyncStatus.synchronized : BrickAnimalSyncStatus.rejected,
        syncErrorCode: result.errorCode,
      );
      await sqliteProvider.upsert<BrickAnimalModel>(
        updatedAnimal,
        repository: this,
      );
      return;
    }
  }
}
