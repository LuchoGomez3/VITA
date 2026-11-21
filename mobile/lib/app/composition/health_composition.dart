import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/health_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/health/data/datasources/health_remote_data_source.dart';
import 'package:frontend_mayoral/features/health/data/repositories/health_repository_impl.dart';
import 'package:frontend_mayoral/features/health/data/services/health_sync_service.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_registration_cubit.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_result_cubit.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

HealthSyncService? _syncService;
http.Client? _syncClient;
bool _healthSessionActive = false;

/// Activa el envío sanitario cuando hay sesión e interfaz de red.
Future<void> requestHealthSync({bool refresh = true}) async {
  final tokens = SessionBackendAccessTokenProvider.instance;
  final generation = tokens.sessionGeneration;
  if (!_healthSessionActive || HealthBrickStore.instance == null || tokens.userId == null) return;
  List<ConnectivityResult> connectivity;
  try {
    connectivity = await Connectivity().checkConnectivity();
  } on PlatformException catch (error) {
    Logger('HealthSync').warning('Connectivity check failed (${error.code})');
    return;
  }
  if (!_healthSessionActive ||
      tokens.sessionGeneration != generation ||
      !connectivity.any((value) => value != ConnectivityResult.none)) {
    return;
  }
  final sync = _syncService ??= _createHealthSync();
  await sync.request(refresh: refresh);
}

HealthSyncService _createHealthSync() {
  final repository = createHealthRepository();
  final remote = HealthRemoteDataSource(
    baseUrl: AppConfig.current.backendBaseUrl,
    client: _syncClient ??= http.Client(),
    tokens: SessionBackendAccessTokenProvider.instance,
  );
  return HealthSyncService(
    repository: repository,
    remote: remote,
    resolveAnimal: HealthAnimalRegistrationRecovery(BrickAnimalStore.instance, remote, repository).call,
  );
}

/// Vuelve a evaluar dependencias al confirmar o corregir un alta local.
StreamSubscription<Type>? watchHealthAnimalDependencies() {
  if (HealthBrickStore.instance == null) return null;
  return AppBrickRepository.instance.localChanges
      .where((type) => type == BrickAnimalModel)
      .listen((_) => _requestPending());
}

/// Cancela los reintentos asociados a la sesión que se cerró.
void pauseHealthSync() => _syncService?.pause();

/// Habilita la sincronización solamente mientras la app tiene una cuenta activa.
void setHealthSessionActive({required bool active}) {
  _healthSessionActive = active;
  if (!active) pauseHealthSync();
}

/// Libera el cliente al cerrar la aplicación.
void disposeHealthSync() {
  _healthSessionActive = false;
  _syncService?.dispose();
  _syncClient?.close();
  _syncService = null;
  _syncClient = null;
}

void _requestPending() => unawaited(requestHealthSync(refresh: false));

/// Arma la capa de datos bajo la sesión autenticada actual.
HealthRepositoryImpl createHealthRepository({void Function()? onPending}) {
  final tokens = SessionBackendAccessTokenProvider.instance;
  return HealthRepositoryImpl(
    store: HealthBrickStore.instance!,
    animals: BrickAnimalStore.instance,
    memberships: const EstablishmentCatalog(secureStorage: FlutterSecureStorageService()),
    session: () => switch (tokens.userId) {
      final userId? => (userId: userId, generation: tokens.sessionGeneration),
      null => null,
    },
    onPending: onPending,
  );
}

/// Arma los casos de uso del historial en la ficha.
ReadHealthUseCase createHealthReader() => ReadHealthUseCase(createHealthRepository());

/// Arma el registro de ficha, lote o manga.
HealthRegistrationCubit createHealthRegistrationCubit() {
  final repository = createHealthRepository(onPending: _requestPending);
  return HealthRegistrationCubit(
    reader: ReadHealthUseCase(repository),
    register: RegisterHealthEventsUseCase(repository),
    establishments: repository.establishments,
  );
}

/// Arma la carga del primer resultado del estudio.
HealthResultCubit createHealthResultCubit() => HealthResultCubit(
  RecordHealthResultUseCase(createHealthRepository(onPending: _requestPending)),
);

/// Proyecta las operaciones pendientes de Sanidad al contrato de Sync.
Future<List<SyncQueueOperation>> readHealthSyncQueue() async {
  if (HealthBrickStore.instance == null) return const [];
  final operations = await createHealthRepository().visibleOperations();
  return [
    for (final operation in operations)
      if (operation.rejection == null && operation.primaryKey != null)
        SyncQueueOperation(
          queueId: -operation.primaryKey!,
          kind: operation.resultEventId == null ? SyncOperationKind.healthEvent : SyncOperationKind.healthResult,
          state: SyncOperationState.waiting,
          attempts: 0,
          queuedAt: operation.createdAt,
          lastAttemptAt: operation.createdAt,
        ),
  ];
}

/// Proyecta los rechazos de Sanidad visibles para la sesión de Sync.
Future<List<SyncRejectedRecord>> readHealthSyncRejections() async {
  if (HealthBrickStore.instance == null) return const [];
  final operations = await createHealthRepository().visibleOperations();
  return [
    for (final operation in operations)
      if (operation.rejection case final code?)
        SyncRejectedRecord(
          localId: operation.localId,
          kind: operation.resultEventId == null ? SyncOperationKind.healthEvent : SyncOperationKind.healthResult,
          recordedAt: operation.createdAt,
          errorCode: code,
        ),
  ];
}
