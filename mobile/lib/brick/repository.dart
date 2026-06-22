import 'package:brick_offline_first/brick_offline_first.dart';
import 'dart:async';

import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
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
    required RestProvider restProvider,
    required super.migrations,
    required super.offlineQueueManager,
  }) : super(
         restProvider: restProvider,
       );

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
    final restProvider = RestProvider(
      _futureBackendBaseUrl,
      modelDictionary: restModelDictionary,
      client: client,
    );

    final repository = AppBrickRepository._(
      sqliteProvider: sqliteProvider,
      restProvider: restProvider,
      migrations: migrations.toSet(),
      offlineQueueManager: RestRequestSqliteCacheManager(
        offlineQueuePath,
        databaseFactory: databaseFactory,
      ),
    );

    await repository.initialize();
    _instance = repository;
  }

  /// Base URL placeholder reserved for the future `/v1/animales` sync flow.
  static const _futureBackendBaseUrl = 'https://vita-sync.invalid';

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async {
    final savedAnimal = await upsert<BrickAnimalModel>(
      animal,
      policy: OfflineFirstUpsertPolicy.optimisticLocal,
    );

    final storedAnimals = await get<BrickAnimalModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );

    // TODO(agustin): Remove this temporary debug logging once we add a proper
    // way to inspect locally persisted animals during development.
    print('[Brick] Stored animals: ${storedAnimals.length}');
    for (final currentAnimal in storedAnimals) {
      print(
        '[Brick] animal localId=${currentAnimal.localId} '
        'rfid=${currentAnimal.rfidTagNumber} '
        'visualTag=${currentAnimal.visualTag} '
        'syncStatus=${currentAnimal.syncStatus.name}',
      );
    }

    return savedAnimal;
  }
}
