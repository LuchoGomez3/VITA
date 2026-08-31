import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/auth/authenticated_backend_client.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/db/schema.g.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

/// Repositorio Brick compartido por toda la app.
///
/// Este archivo debe concentrar infraestructura comun: providers, SQLite,
/// RestProvider, cola offline, migraciones y helpers genericos. La logica
/// especifica de cada modelo Brick debe vivir en stores por entidad, por
/// ejemplo `BrickAnimalStore`.
class AppBrickRepository extends OfflineFirstWithRestRepository<OfflineFirstWithRestModel> {
  /// Constructor privado para forzar una unica instancia configurada.
  ///
  /// Brick necesita providers y migraciones ya resueltos al construirse. Por
  /// eso la app debe usar [configure] y luego acceder por [instance].
  AppBrickRepository._({
    required super.sqliteProvider,
    required super.restProvider,
    required super.migrations,
    required super.offlineQueueManager,
    required super.reattemptForStatusCodes,
    required StreamController<BackendSyncResult> syncResults,
    required StreamController<void> authRejections,
  }) : _syncResults = syncResults,
       _authRejections = authRejections;

  static AppBrickRepository? _instance;

  /// Canal interno donde el HTTP client publica resultados de sync del backend.
  ///
  /// El repository global no interpreta estos eventos. Cada store por entidad
  /// filtra los recursos que le corresponden y actualiza su estado local.
  final StreamController<BackendSyncResult> _syncResults;
  final StreamController<void> _authRejections;

  /// Instancia unica configurada durante el arranque de la app.
  ///
  /// Acceder antes de llamar a [configure] es un error de inicializacion.
  static AppBrickRepository get instance {
    final repository = _instance;
    if (repository == null) {
      throw StateError('AppBrickRepository has not been initialized yet.');
    }
    return repository;
  }

  /// Stream generico de resultados de sync observado por el HTTP client.
  ///
  /// Por ejemplo, `BrickAnimalStore` escucha este stream y solo procesa eventos
  /// cuyo [BackendSyncResult.resourcePath] corresponde a `/api/v1/animales`.
  Stream<BackendSyncResult> get syncResults => _syncResults.stream;

  /// Notifica que el backend rechazo una sesion previamente autenticada.
  ///
  /// Auth consume este canal para limpiar solamente las credenciales. Los
  /// datos offline y la cola de sincronizacion permanecen intactos.
  Stream<void> get authRejections => _authRejections.stream;

  /// Configura e inicializa la infraestructura compartida de Brick.
  ///
  /// Parametros principales:
  /// - [sqlitePath]: archivo SQLite principal con las tablas de modelos Brick.
  /// - [offlineQueuePath]: SQLite separado donde Brick guarda requests REST
  ///   pendientes o reintentables.
  /// - [backendBaseUrl]: URL base del backend. Si no se pasa, se toma de
  ///   [AppConfig].
  /// - [tokenProvider]: fuente del Bearer token usado por el cliente REST.
  /// - [client]: cliente HTTP opcional, principalmente util para tests.
  static Future<void> configure({
    required String sqlitePath,
    required String offlineQueuePath,
    String? backendBaseUrl,
    BackendAccessTokenProvider? tokenProvider,
    http.Client? client,
    DatabaseFactory? localDatabaseFactory,
  }) async {
    if (_instance != null) {
      return;
    }

    // Provider local: Brick lo usa para leer/escribir modelos en SQLite.
    final sqliteProvider = SqliteProvider(
      sqlitePath,
      databaseFactory: localDatabaseFactory ?? databaseFactory,
      modelDictionary: sqliteModelDictionary,
    );

    // El cliente HTTP observa responses de backend y publica resultados de sync
    // genericos. La logica de cada entidad queda en su store correspondiente.
    final syncResults = StreamController<BackendSyncResult>.broadcast();
    final authRejections = StreamController<void>.broadcast();
    final restClient = AuthenticatedBackendClient(
      tokenProvider: tokenProvider ?? SessionBackendAccessTokenProvider.instance,
      inner: client,
      onSyncResult: (result) {
        syncResults.add(result);
        return Future<void>.value();
      },
      onUnauthorized: () async => authRejections.add(null),
    );

    // Provider remoto: Brick lo usa para serializar modelos y hacer requests
    // REST. El OfflineFirstWithRestRepository lo envuelve con una cola offline.
    final restProvider = RestProvider(
      backendBaseUrl ?? AppConfig.current.backendBaseUrl,
      modelDictionary: restModelDictionary,
      client: restClient,
    );

    // RestRequestSqliteCacheManager crea la cola SQLite que reintenta requests
    // cuando hay errores transitorios o falta conectividad.
    final repository = AppBrickRepository._(
      sqliteProvider: sqliteProvider,
      restProvider: restProvider,
      migrations: migrations.toSet(),
      syncResults: syncResults,
      authRejections: authRejections,
      offlineQueueManager: RestRequestSqliteCacheManager(
        offlineQueuePath,
        databaseFactory: localDatabaseFactory ?? databaseFactory,
      ),
      // Los 5xx se consideran transitorios: Brick los deja en cola para
      // reintentar. Los 4xx funcionales se procesan como rechazo del sync.
      reattemptForStatusCodes: const [500, 501, 502, 503, 504],
    );

    // initialize() aplica migraciones de la DB principal y de la cola offline.
    await repository.initialize();
    _instance = repository;
  }

  /// Guarda un modelo solo en SQLite y notifica subscribers locales.
  ///
  /// Los stores usan este helper cuando quieren persistir cambios locales sin
  /// disparar automaticamente un request REST adicional.
  Future<TModel> upsertLocal<TModel extends OfflineFirstWithRestModel>(
    TModel model,
  ) async {
    final primaryKey = await sqliteProvider.upsert<TModel>(
      model,
      repository: this,
    );
    final savedModel = model..primaryKey = primaryKey;
    memoryCacheProvider.upsert<TModel>(savedModel);
    await notifySubscriptionsWithLocalData<TModel>();

    return savedModel;
  }

  /// Ejecuta varios upserts locales dentro de una unica transaccion SQLite.
  ///
  /// Los stores de una operacion compuesta, como un movimiento de animales,
  /// usan este limite para evitar estados parciales si alguna escritura falla.
  Future<T> runLocalTransaction<T>(
    Future<T> Function(AppBrickTransaction transaction) callback,
  ) async {
    final afterCommit = <Future<void> Function()>[];
    final result = await sqliteProvider.transaction(
      (sqliteTransaction) => callback(
        AppBrickTransaction._(
          repository: this,
          transaction: sqliteTransaction,
          afterCommit: afterCommit,
        ),
      ),
    );
    for (final action in afterCommit) {
      await action();
    }
    return result;
  }

  /// Envia un modelo al provider REST dejando que Brick maneje la cola offline.
  ///
  /// Este helper no debe bloquear la UX de una feature. Los stores suelen
  /// llamarlo con `unawaited` despues de guardar localmente.
  Future<void> enqueueRemoteUpsert<TModel extends OfflineFirstWithRestModel>(
    TModel model,
  ) async {
    try {
      await remoteProvider.upsert<TModel>(
        model,
        repository: this,
      );
    } on Object catch (error) {
      logger.warning('#upsert remote sync enqueue failure: $error');
    }
  }

  /// Lee modelos solo desde SQLite, sin hidratar desde backend.
  Future<List<TModel>> getLocal<TModel extends OfflineFirstWithRestModel>() {
    return get<TModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );
  }
}

/// Contexto restringido para escribir modelos Brick en una transaccion local.
class AppBrickTransaction {
  AppBrickTransaction._({
    required AppBrickRepository repository,
    required Transaction transaction,
    required List<Future<void> Function()> afterCommit,
  }) : _repository = repository,
       _transaction = transaction,
       _afterCommit = afterCommit;

  final AppBrickRepository _repository;
  final Transaction _transaction;
  final List<Future<void> Function()> _afterCommit;

  /// Inserta o actualiza [model] usando el adapter generado por Brick.
  Future<TModel> upsert<TModel extends OfflineFirstWithRestModel>(
    TModel model,
  ) async {
    final adapter = _repository.sqliteProvider.modelDictionary.adapterFor[TModel]!;
    await adapter.beforeSave(
      model,
      provider: _repository.sqliteProvider,
      repository: _repository,
    );
    await model.beforeSave(
      provider: _repository.sqliteProvider,
      repository: _repository,
    );
    final data = await adapter.toSqlite(
      model,
      provider: _repository.sqliteProvider,
      repository: _repository,
    );
    final existingPrimaryKey = await adapter.primaryKeyByUniqueColumns(
      model,
      _transaction,
    );
    final primaryKey = existingPrimaryKey ?? model.primaryKey;
    if (model.isNewRecord && existingPrimaryKey == null) {
      model.primaryKey = await _transaction.insert(adapter.tableName, data);
    } else {
      await _transaction.update(
        adapter.tableName,
        data,
        where: '_brick_id = ?',
        whereArgs: [primaryKey],
      );
      model.primaryKey = primaryKey;
    }
    await adapter.afterSave(
      model,
      provider: _repository.sqliteProvider,
      repository: _repository,
    );
    await model.afterSave(
      provider: _repository.sqliteProvider,
      repository: _repository,
    );
    _afterCommit.add(() async {
      _repository.memoryCacheProvider.upsert<TModel>(model);
      await _repository.notifySubscriptionsWithLocalData<TModel>();
    });
    return model;
  }
}
