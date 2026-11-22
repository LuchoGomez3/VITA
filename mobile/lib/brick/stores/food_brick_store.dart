import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/food.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Contrato de persistencia y sincronización del catálogo de alimentos.
abstract class FoodBrickStore {
  /// Alimentos vigentes del establecimiento más los del catálogo global.
  Future<List<BrickFoodModel>> getLocalFoods(String establishmentId);

  /// Descarga el catálogo remoto del establecimiento.
  Future<void> pullRemoteFoods(String establishmentId);

  /// Reenvía los alimentos locales pendientes del establecimiento.
  Future<void> pushPendingFoods(String establishmentId);
}

/// Persistencia offline-first del catálogo de alimentos.
class BrickFoodStore implements FoodBrickStore {
  BrickFoodStore._(this._repository) {
    _syncSubscription = _repository.syncResults.listen(applyFoodSyncResult);
  }

  static BrickFoodStore? _instance;

  final AppBrickRepository _repository;
  late final StreamSubscription<BackendSyncResult> _syncSubscription;

  /// Instancia configurada durante el bootstrap.
  static BrickFoodStore get instance => _instance ?? (throw StateError('BrickFoodStore no fue inicializado.'));

  /// Configura el store una sola vez.
  static void configure(AppBrickRepository repository) {
    _instance ??= BrickFoodStore._(repository);
  }

  @override
  Future<List<BrickFoodModel>> getLocalFoods(String establishmentId) async {
    final stored = await _repository.getLocal<BrickFoodModel>();
    return [
      for (final food in latestById(stored).values)
        if (food.deletedAt == null && (food.establishmentId == null || food.establishmentId == establishmentId)) food,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<void> pullRemoteFoods(String establishmentId) async {
    final remoteFoods = await _repository.remoteProvider.get<BrickFoodModel>(
      repository: _repository,
      query: Query(
        forProviders: [
          RestProviderQuery(request: BrickFoodRequestTransformer.listByEstablishmentRequest(establishmentId)),
        ],
      ),
    );
    final localById = latestById(await _repository.getLocal<BrickFoodModel>());
    for (final remote in remoteFoods) {
      final local = localById[remote.localId];
      if (local != null && local.syncStatus != BrickFoodSyncStatus.synchronized) continue;
      remote.primaryKey = local?.primaryKey;
      await _repository.upsertLocal(remote.copyWith(syncStatus: BrickFoodSyncStatus.synchronized, syncErrorCode: null));
    }
  }

  @override
  Future<void> pushPendingFoods(String establishmentId) async {
    final foods = await _repository.getLocal<BrickFoodModel>();
    for (final food in foods.where(
      (food) => food.establishmentId == establishmentId && food.syncStatus == BrickFoodSyncStatus.pending,
    )) {
      await _repository.enqueueRemoteUpsert<BrickFoodModel>(food);
    }
  }

  /// Marca el alimento como confirmado o rechazado.
  Future<void> applyFoodSyncResult(BackendSyncResult result) async {
    if (!BrickFoodRequestTransformer.matchesFoodResource(result.resourcePath)) return;
    final local = latestById(await _repository.getLocal<BrickFoodModel>())[result.localId];
    if (local == null) return;
    await _repository.upsertLocal(
      local.copyWith(
        syncStatus: result.synchronized ? BrickFoodSyncStatus.synchronized : BrickFoodSyncStatus.rejected,
        syncErrorCode: result.errorCode,
      ),
    );
  }

  /// Libera la escucha del canal global de sincronización.
  Future<void> dispose() => _syncSubscription.cancel();

  /// La versión más reciente de cada alimento (puede haber una local y una
  /// confirmada por el servidor).
  static Map<String, BrickFoodModel> latestById(Iterable<BrickFoodModel> stored) {
    final latest = <String, BrickFoodModel>{};
    for (final food in stored) {
      final current = latest[food.localId];
      if (current == null || food.updatedAt.isAfter(current.updatedAt)) latest[food.localId] = food;
    }
    return latest;
  }
}
