import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/feeding_record.model.dart';
import 'package:frontend_mayoral/brick/models/food.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Contrato de persistencia y sincronización de los registros de alimentación.
abstract class FeedingRecordBrickStore {
  /// Guarda el registro y, si se dio de alta en el mismo formulario, el
  /// alimento nuevo, en una sola transacción local. Después encola ambos (el
  /// alimento primero: el registro lo referencia).
  Future<BrickFeedingRecordModel> save(BrickFeedingRecordModel record, {BrickFoodModel? newFood});

  /// Registros vigentes del establecimiento.
  Future<List<BrickFeedingRecordModel>> getLocalRecords(String establishmentId);

  /// Descarga los registros remotos del establecimiento.
  Future<void> pullRemoteRecords(String establishmentId);

  /// Reenvía los registros locales pendientes del establecimiento.
  Future<void> pushPendingRecords(String establishmentId);
}

/// Persistencia offline-first de los registros de alimentación.
class BrickFeedingRecordStore implements FeedingRecordBrickStore {
  BrickFeedingRecordStore._(this._repository) {
    _syncSubscription = _repository.syncResults.listen(applyRecordSyncResult);
  }

  static BrickFeedingRecordStore? _instance;

  final AppBrickRepository _repository;
  late final StreamSubscription<BackendSyncResult> _syncSubscription;

  /// Instancia configurada durante el bootstrap.
  static BrickFeedingRecordStore get instance =>
      _instance ?? (throw StateError('BrickFeedingRecordStore no fue inicializado.'));

  /// Configura el store una sola vez.
  static void configure(AppBrickRepository repository) {
    _instance ??= BrickFeedingRecordStore._(repository);
  }

  @override
  Future<BrickFeedingRecordModel> save(BrickFeedingRecordModel record, {BrickFoodModel? newFood}) async {
    record.primaryKey ??= _latestById(
      await _repository.getLocal<BrickFeedingRecordModel>(),
    )[record.localId]?.primaryKey;
    final (savedFood, savedRecord) = await _repository.runLocalTransaction((transaction) async {
      final food = newFood == null ? null : await transaction.upsert<BrickFoodModel>(newFood);
      final saved = await transaction.upsert<BrickFeedingRecordModel>(record);
      return (food, saved);
    });
    if (savedFood != null) {
      await _repository.enqueueRemoteUpsert<BrickFoodModel>(savedFood);
    }
    unawaited(_repository.enqueueRemoteUpsert<BrickFeedingRecordModel>(savedRecord));
    return savedRecord;
  }

  @override
  Future<List<BrickFeedingRecordModel>> getLocalRecords(String establishmentId) async {
    final stored = await _repository.getLocal<BrickFeedingRecordModel>();
    return [
      for (final record in _latestById(stored.where((item) => item.establishmentId == establishmentId)).values)
        if (record.deletedAt == null) record,
    ];
  }

  @override
  Future<void> pullRemoteRecords(String establishmentId) async {
    final remoteRecords = await _repository.remoteProvider.get<BrickFeedingRecordModel>(
      repository: _repository,
      query: Query(
        forProviders: [
          RestProviderQuery(
            request: BrickFeedingRecordRequestTransformer.listByEstablishmentRequest(establishmentId),
          ),
        ],
      ),
    );
    final localById = _latestById(await _repository.getLocal<BrickFeedingRecordModel>());
    for (final remote in remoteRecords) {
      final local = localById[remote.localId];
      if (local != null && local.syncStatus != BrickFeedingRecordSyncStatus.synchronized) continue;
      remote.primaryKey = local?.primaryKey;
      await _repository.upsertLocal(
        remote.copyWith(syncStatus: BrickFeedingRecordSyncStatus.synchronized, syncErrorCode: null),
      );
    }
  }

  @override
  Future<void> pushPendingRecords(String establishmentId) async {
    final records = await _repository.getLocal<BrickFeedingRecordModel>();
    for (final record in records.where(
      (record) =>
          record.establishmentId == establishmentId && record.syncStatus == BrickFeedingRecordSyncStatus.pending,
    )) {
      await _repository.enqueueRemoteUpsert<BrickFeedingRecordModel>(record);
    }
  }

  /// Marca el registro como confirmado o rechazado.
  Future<void> applyRecordSyncResult(BackendSyncResult result) async {
    if (!BrickFeedingRecordRequestTransformer.matchesRecordResource(result.resourcePath)) return;
    final local = _latestById(await _repository.getLocal<BrickFeedingRecordModel>())[result.localId];
    if (local == null) return;
    var reconciled = local.copyWith(
      syncStatus: result.synchronized
          ? BrickFeedingRecordSyncStatus.synchronized
          : BrickFeedingRecordSyncStatus.rejected,
      syncErrorCode: result.errorCode,
    );
    final responseData = result.responseData;
    if (result.synchronized && responseData != null) {
      final authoritative = await _repository.modelFromRemoteData<BrickFeedingRecordModel>(responseData);
      authoritative.primaryKey = local.primaryKey;
      reconciled = authoritative.copyWith(syncStatus: BrickFeedingRecordSyncStatus.synchronized, syncErrorCode: null);
    }
    await _repository.upsertLocal(reconciled);
  }

  /// Libera la escucha del canal global de sincronización.
  Future<void> dispose() => _syncSubscription.cancel();

  static Map<String, BrickFeedingRecordModel> _latestById(Iterable<BrickFeedingRecordModel> stored) {
    final latest = <String, BrickFeedingRecordModel>{};
    for (final record in stored) {
      final current = latest[record.localId];
      if (current == null || record.updatedAt.isAfter(current.updatedAt)) latest[record.localId] = record;
    }
    return latest;
  }
}
