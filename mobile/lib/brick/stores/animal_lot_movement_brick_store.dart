import 'dart:async';
import 'dart:convert';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Contrato de persistencia y sincronización de movimientos entre lotes.
abstract class AnimalLotMovementBrickStore {
  /// Guarda un movimiento y encola su sincronización.
  Future<BrickAnimalLotMovementModel> save(
    BrickAnimalLotMovementModel movement,
  );

  /// Guarda atómicamente los animales actualizados y el movimiento.
  Future<BrickAnimalLotMovementModel> saveWithAnimals({
    required List<BrickAnimalModel> animals,
    required BrickAnimalLotMovementModel movement,
  });

  /// Descarga el historial remoto del establecimiento.
  Future<void> pullRemoteMovements(String establishmentId);

  /// Envía los movimientos locales pendientes del establecimiento.
  Future<void> pushPendingMovements(String establishmentId);
}

/// Persistencia offline-first de movimientos entre lotes.
class BrickAnimalLotMovementStore implements AnimalLotMovementBrickStore {
  BrickAnimalLotMovementStore._(this._repository) {
    _syncSubscription = _repository.syncResults.listen(applyMovementSyncResult);
  }

  static BrickAnimalLotMovementStore? _instance;

  final AppBrickRepository _repository;
  late final StreamSubscription<BackendSyncResult> _syncSubscription;

  /// Instancia configurada durante el bootstrap.
  static BrickAnimalLotMovementStore get instance {
    final store = _instance;
    if (store == null) {
      throw StateError('BrickAnimalLotMovementStore no fue inicializado.');
    }
    return store;
  }

  /// Configura el store una sola vez.
  static void configure(AppBrickRepository repository) {
    _instance ??= BrickAnimalLotMovementStore._(repository);
  }

  /// Guarda primero en SQLite y encola el POST remoto.
  @override
  Future<BrickAnimalLotMovementModel> save(
    BrickAnimalLotMovementModel movement,
  ) async {
    final saved = await _repository.upsertLocal(movement);
    unawaited(_repository.enqueueRemoteUpsert(saved));
    return saved;
  }

  /// Actualiza animales y registra su movimiento en una sola transaccion.
  @override
  Future<BrickAnimalLotMovementModel> saveWithAnimals({
    required List<BrickAnimalModel> animals,
    required BrickAnimalLotMovementModel movement,
  }) async {
    final saved = await _repository.runLocalTransaction((transaction) async {
      for (final animal in animals) {
        await transaction.upsert<BrickAnimalModel>(animal);
      }
      return transaction.upsert<BrickAnimalLotMovementModel>(movement);
    });
    unawaited(_repository.enqueueRemoteUpsert(saved));
    return saved;
  }

  /// Descarga el historial remoto del establecimiento.
  @override
  Future<void> pullRemoteMovements(String establishmentId) async {
    final remoteMovements = await _repository.remoteProvider.get<BrickAnimalLotMovementModel>(
      repository: _repository,
      query: Query(
        forProviders: [
          RestProviderQuery(
            request: BrickAnimalLotMovementRequestTransformer.listByEstablishmentRequest(
              establishmentId,
            ),
          ),
        ],
      ),
    );
    final localMovements = await _repository.getLocal<BrickAnimalLotMovementModel>();
    final localById = {for (final movement in localMovements) movement.localId: movement};
    for (final remote in remoteMovements) {
      final local = localById[remote.localId];
      if (local != null && local.syncStatus != BrickAnimalLotMovementSyncStatus.synchronized) {
        continue;
      }
      remote.primaryKey = local?.primaryKey;
      await _repository.upsertLocal(
        remote.copyWith(
          syncStatus: BrickAnimalLotMovementSyncStatus.synchronized,
          syncErrorCode: null,
        ),
      );
    }
  }

  @override
  Future<void> pushPendingMovements(String establishmentId) async {
    final movements = await _repository.getLocal<BrickAnimalLotMovementModel>();
    final pending = movements.where(
      (movement) =>
          movement.establishmentId == establishmentId &&
          movement.syncStatus == BrickAnimalLotMovementSyncStatus.pending,
    );
    for (final movement in pending) {
      await _repository.enqueueRemoteUpsert<BrickAnimalLotMovementModel>(
        movement,
      );
    }
  }

  /// Aplica la confirmación o el rechazo del movimiento y de sus animales.
  Future<void> applyMovementSyncResult(BackendSyncResult result) async {
    if (!BrickAnimalLotMovementRequestTransformer.matchesMovementResource(
      result.resourcePath,
    )) {
      return;
    }
    final movements = await _repository.getLocal<BrickAnimalLotMovementModel>();
    BrickAnimalLotMovementModel? local;
    for (final movement in movements) {
      if (movement.localId == result.localId) {
        local = movement;
        break;
      }
    }
    if (local == null) return;

    var reconciled = local.copyWith(
      syncStatus: result.synchronized
          ? BrickAnimalLotMovementSyncStatus.synchronized
          : BrickAnimalLotMovementSyncStatus.rejected,
      syncErrorCode: result.errorCode,
    );
    final responseData = result.responseData;
    if (result.synchronized && responseData != null) {
      final authoritative = await _repository.modelFromRemoteData<BrickAnimalLotMovementModel>(
        responseData,
      );
      authoritative.primaryKey = local.primaryKey;
      reconciled = authoritative.copyWith(
        syncStatus: BrickAnimalLotMovementSyncStatus.synchronized,
        syncErrorCode: null,
      );
    }
    await _repository.upsertLocal(reconciled);
    await _applyResultToAnimals(reconciled, result);
  }

  Future<void> _applyResultToAnimals(
    BrickAnimalLotMovementModel movement,
    BackendSyncResult result,
  ) async {
    final animalIds = (jsonDecode(movement.animalIdsJson) as List<dynamic>).cast<String>().toSet();
    final animals = await _repository.getLocal<BrickAnimalModel>();
    for (final animal in animals) {
      final belongsToMovement =
          animalIds.contains(animal.localId) &&
          animal.lotId == movement.destinationLotId &&
          animal.updatedAt.isAtSameMomentAs(movement.updatedAt);
      if (!belongsToMovement) continue;
      await _repository.upsertLocal(
        animal.copyWith(
          syncStatus: result.synchronized ? BrickAnimalSyncStatus.synchronized : BrickAnimalSyncStatus.rejected,
          syncErrorCode: result.errorCode,
        ),
      );
    }
  }

  /// Libera la escucha del canal global de sincronización.
  Future<void> dispose() => _syncSubscription.cancel();
}
