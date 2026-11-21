import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/app/adapters/health_sync_activity.dart';
import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/auth/guarded_backend_request.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_registration_recovery.dart';
import 'package:frontend_mayoral/brick/stores/health_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/health/data/datasources/health_remote_data_source.dart';
import 'package:frontend_mayoral/features/health/data/repositories/health_repository_impl.dart';
import 'package:frontend_mayoral/features/health/data/services/health_sync_service.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_registration_cubit.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_result_cubit.dart';
import 'package:logging/logging.dart';

HealthSyncService? _syncService;
bool _healthSessionActive = false;
({int generation, Future<bool> result})? _healthRefresh;

/// Activa el envío sanitario cuando hay sesión e interfaz de red.
Future<bool> requestHealthSync({bool refresh = true}) {
  final tokens = SessionBackendAccessTokenProvider.instance;
  if (!_healthSessionActive || HealthBrickStore.instance == null || tokens.userId == null) return Future.value(false);
  final generation = tokens.sessionGeneration;
  if (!refresh) return _runHealthSync(generation, refresh: false);

  late final Future<bool> result;
  result = _runHealthSync(generation, refresh: true).whenComplete(() {
    if (identical(_healthRefresh?.result, result)) _healthRefresh = null;
  });
  _healthRefresh = (generation: generation, result: result);
  return result;
}

/// El botón de Sync espera la descarga iniciada por la preparación de datos.
Future<bool> synchronizeHealthNow() {
  if (HealthBrickStore.instance == null) return Future.value(true);
  final active = _healthRefresh;
  if (active != null && active.generation == SessionBackendAccessTokenProvider.instance.sessionGeneration) {
    return active.result;
  }
  return requestHealthSync();
}

/// Actualiza el catálogo del establecimiento que abrió el formulario.
Future<void> refreshHealthCatalog(String establishmentId) async {
  final tokens = SessionBackendAccessTokenProvider.instance;
  if (!_healthSessionActive || HealthBrickStore.instance == null || tokens.userId == null) return;
  final generation = tokens.sessionGeneration;
  final sync = await _onlineHealthSync(generation);
  if (sync == null || !_isCurrentHealthSession(generation)) return;
  await sync.refreshCatalog(establishmentId);
}

Future<bool> _runHealthSync(int generation, {required bool refresh}) async {
  final sync = await _onlineHealthSync(generation);
  if (sync == null || !_isCurrentHealthSession(generation)) return false;
  final succeeded = await sync.request(refresh: refresh);
  return succeeded && _isCurrentHealthSession(generation);
}

bool _isCurrentHealthSession(int generation) =>
    _healthSessionActive && SessionBackendAccessTokenProvider.instance.sessionGeneration == generation;

Future<HealthSyncService?> _onlineHealthSync(int generation) async {
  List<ConnectivityResult> connectivity;
  try {
    connectivity = await Connectivity().checkConnectivity();
  } on PlatformException catch (error) {
    Logger('HealthSync').warning('Connectivity check failed (${error.code})');
    return null;
  }
  if (!_isCurrentHealthSession(generation) || !connectivity.any((value) => value != ConnectivityResult.none)) {
    return null;
  }
  return _syncService ??= _createHealthSync();
}

HealthSyncService _createHealthSync() {
  final repository = createHealthRepository();
  final backend = GuardedBackendRequest(
    baseUrl: AppConfig.current.backendBaseUrl,
    send: AppBrickRepository.instance.sendGuardedBackendRequest,
  );
  final animalRegistration = AnimalRegistrationRecovery(BrickAnimalStore.instance, backend);
  return HealthSyncService(
    repository: repository,
    remote: HealthRemoteDataSource(backend),
    resolveAnimal: (id, establishmentId, session, guard) => animalRegistration(
      id: id,
      establishmentId: establishmentId,
      authorId: session.userId,
      guard: guard,
      requireSession: () => repository.requireSession(session),
    ),
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
void pauseHealthSync() {
  _healthRefresh = null;
  _syncService?.pause();
}

/// Habilita la sincronización solamente mientras la app tiene una cuenta activa.
void setHealthSessionActive({required bool active}) {
  _healthSessionActive = active;
  if (!active) pauseHealthSync();
}

/// Libera el coordinador al cerrar la aplicación.
void disposeHealthSync() {
  _healthSessionActive = false;
  _healthRefresh = null;
  _syncService?.dispose();
  _syncService = null;
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

/// Conecta Sync con la actividad local de Sanidad.
HealthSyncActivity createHealthSyncActivity() =>
    HealthSyncActivity(() => HealthBrickStore.instance == null ? null : createHealthRepository());
