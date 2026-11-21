import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:frontend_mayoral/app/composition/health_composition.dart';
import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/operating_expenses/operating_expenses_composition.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/brick_rejected_records_reader.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/connectivity_status.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/initial_data_sync_repository_impl.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/sync_history_recorder.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/sync_queue_repository_impl.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/sync_rejections_repository_impl.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/services/offline_sync_coordinator.dart';
import 'package:frontend_mayoral/features/sync/domain/use_cases/prepare_initial_data_sync_use_case.dart';
import 'package:frontend_mayoral/features/sync/presentation/cubit/sync_queue_cubit.dart';
import 'package:http/http.dart' as http;

OfflineSyncCoordinator? _offlineSyncCoordinator;

/// Devuelve el coordinador compartido de sincronizacion de la sesion activa.
OfflineSyncCoordinator createOfflineSyncCoordinator() {
  final existing = _offlineSyncCoordinator;
  if (existing != null) return existing;

  final client = http.Client();
  return _offlineSyncCoordinator = OfflineSyncCoordinator(
    prepareInitialDataSyncUseCase: createPrepareInitialDataSyncUseCase(
      client: client,
    ),
    onClose: client.close,
    sessionIdentity: () => SessionBackendAccessTokenProvider.instance.sessionGeneration,
  );
}

/// Libera el coordinador global al cerrar la aplicacion.
Future<void> disposeOfflineSyncCoordinator() async {
  final coordinator = _offlineSyncCoordinator;
  _offlineSyncCoordinator = null;
  await coordinator?.dispose();
}

/// Crea el caso de uso que prepara los datos offline posteriores al login.
///
/// La composicion queda dentro de `features/sync` para que auth no conozca los
/// stores Brick ni el detalle de que tablas se hidratan durante el bootstrap.
PrepareInitialDataSyncUseCase createPrepareInitialDataSyncUseCase({
  required http.Client client,
}) {
  final operatingExpenseSync = createOperatingExpenseInitialSyncService(
    client: client,
  );
  return PrepareInitialDataSyncUseCase(
    InitialDataSyncRepositoryImpl(
      secureStorage: const FlutterSecureStorageService(),
      establishmentRemoteDataSource: EstablishmentRemoteDataSource(
        backendBaseUrl: AppConfig.current.backendBaseUrl,
        tokenProvider: SessionBackendAccessTokenProvider.instance,
        client: client,
      ),
      animalStore: BrickAnimalStore.instance,
      categoryStore: BrickCategoriaStore.instance,
      lotStore: BrickLotStore.instance,
      weighingStore: BrickPesajeStore.instance,
      movementStore: BrickAnimalLotMovementStore.instance,
      syncOperatingExpenseData: operatingExpenseSync.call,
      onPrepared: () => unawaited(requestHealthSync()),
      sessionIdentity: () => SessionBackendAccessTokenProvider.instance.sessionGeneration,
      persistSessionData: SessionBackendAccessTokenProvider.instance.persistSessionData,
    ),
  );
}

SyncHistoryRecorder? _syncHistoryRecorder;

SyncHistoryRecorder get _historyRecorder =>
    _syncHistoryRecorder ??= SyncHistoryRecorder(results: AppBrickRepository.instance.syncResults);

/// Empieza a recordar los envíos que acepta el backend.
///
/// Se llama al arrancar la app, después de configurar Brick: así la pantalla
/// de sincronización muestra también lo que se envió mientras estaba cerrada.
void startSyncHistoryRecorder() => _historyRecorder.start();

/// Crea el cubit que muestra en vivo la cantidad de operaciones pendientes.
///
/// Pensado para indicadores (la nube de los encabezados): solo lee la cola
/// SQLite de Brick, así que funciona sin conexión.
SyncQueueCubit createSyncQueueCubit() => _createCubit(includeActivity: false);

/// Crea el cubit de la pantalla de sincronización: la cola, los registros
/// rechazados y lo enviado en esta sesión.
SyncQueueCubit createSyncStatusCubit() => _createCubit(includeActivity: true);

SyncQueueCubit _createCubit({required bool includeActivity}) {
  final brick = AppBrickRepository.instance;
  Stream<void> changes() => _mergeVoid([brick.localChanges, brick.syncResults]);
  return SyncQueueCubit(
    repository: SyncQueueRepositoryImpl(
      readQueue: brick.queuedRequests,
      changes: changes(),
      readAdditionalOperations: readHealthSyncQueue,
    ),
    connectivityChanges: connectivityStatus(
      check: Connectivity().checkConnectivity,
      changes: Connectivity().onConnectivityChanged,
    ),
    synchronizeNow: () async => await createOfflineSyncCoordinator().synchronize() is Success,
    rejections: includeActivity
        ? SyncRejectionsRepositoryImpl(readRejected: () => _readRejectedWithHealth(brick), changes: changes())
        : null,
    history: includeActivity ? _historyRecorder : null,
  );
}

Future<List<SyncRejectedRecord>> _readRejectedWithHealth(AppBrickRepository brick) async => [
  ...await BrickRejectedRecordsReader(brick).read(),
  ...await readHealthSyncRejections(),
]..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));

/// Une varios streams en avisos sin payload; se cancela al cancelar el último.
Stream<void> _mergeVoid(List<Stream<Object?>> sources) {
  late final StreamController<void> controller;
  final subscriptions = <StreamSubscription<Object?>>[];
  controller = StreamController<void>(
    onListen: () {
      for (final source in sources) {
        subscriptions.add(source.listen((_) => controller.add(null)));
      }
    },
    onCancel: () => Future.wait(subscriptions.map((subscription) => subscription.cancel())),
  );
  return controller.stream;
}
