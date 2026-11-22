import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/lot_forage_period.model.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:logging/logging.dart';

/// Contrato de persistencia y sincronización del historial de recursos.
abstract class LotForagePeriodBrickStore {
  /// Guarda el período en SQLite y encola su envío.
  Future<BrickLotForagePeriodModel> save(BrickLotForagePeriodModel period);

  /// Períodos guardados en el celular para [establishmentId], sin los borrados.
  /// Con [lotId] devuelve solo los de ese lote.
  Future<List<BrickLotForagePeriodModel>> getLocalPeriods(
    String establishmentId, {
    String? lotId,
  });

  /// Descarga el historial remoto del establecimiento.
  Future<void> pullRemotePeriods(String establishmentId);

  /// Reenvía los períodos locales pendientes del establecimiento.
  Future<void> pushPendingPeriods(String establishmentId);
}

/// Persistencia offline-first del historial de recursos forrajeros.
class BrickLotForagePeriodStore implements LotForagePeriodBrickStore {
  BrickLotForagePeriodStore._(this._repository, this._lotStore) {
    _syncSubscription = _repository.syncResults.listen(applyPeriodSyncResult);
  }

  static BrickLotForagePeriodStore? _instance;

  final AppBrickRepository _repository;
  final LotBrickStore _lotStore;
  late final StreamSubscription<BackendSyncResult> _syncSubscription;
  static final _logger = Logger('BrickLotForagePeriodStore');

  /// Instancia configurada durante el bootstrap.
  static BrickLotForagePeriodStore get instance =>
      _instance ?? (throw StateError('BrickLotForagePeriodStore no fue inicializado.'));

  /// Configura el store una sola vez.
  static void configure(AppBrickRepository repository, {required LotBrickStore lotStore}) {
    _instance ??= BrickLotForagePeriodStore._(repository, lotStore);
  }

  @override
  Future<BrickLotForagePeriodModel> save(BrickLotForagePeriodModel period) async {
    if (period.primaryKey == null) {
      final stored = await _repository.getLocal<BrickLotForagePeriodModel>();
      period.primaryKey = _latestById(stored)[period.localId]?.primaryKey;
    }
    final saved = await _repository.upsertLocal(period);
    unawaited(_repository.enqueueRemoteUpsert<BrickLotForagePeriodModel>(saved));
    return saved;
  }

  @override
  Future<List<BrickLotForagePeriodModel>> getLocalPeriods(
    String establishmentId, {
    String? lotId,
  }) async {
    final stored = await _repository.getLocal<BrickLotForagePeriodModel>();
    return [
      for (final period in _latestById(
        stored.where((item) => item.establishmentId == establishmentId),
      ).values)
        if (period.deletedAt == null && (lotId == null || period.lotId == lotId)) period,
    ]..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  @override
  Future<void> pullRemotePeriods(String establishmentId) async {
    final remotePeriods = await _repository.remoteProvider.get<BrickLotForagePeriodModel>(
      repository: _repository,
      query: Query(
        forProviders: [
          RestProviderQuery(
            request: BrickLotForagePeriodRequestTransformer.listByEstablishmentRequest(establishmentId),
          ),
        ],
      ),
    );
    final localById = _latestById(await _repository.getLocal<BrickLotForagePeriodModel>());
    for (final remote in remotePeriods) {
      final local = localById[remote.localId];
      // Lo pendiente o rechazado en el celular no se pisa: todavía no llegó.
      if (local != null && local.syncStatus != BrickLotForagePeriodSyncStatus.synchronized) {
        continue;
      }
      remote.primaryKey = local?.primaryKey;
      await _repository.upsertLocal(
        remote.copyWith(syncStatus: BrickLotForagePeriodSyncStatus.synchronized, syncErrorCode: null),
      );
    }
  }

  @override
  Future<void> pushPendingPeriods(String establishmentId) async {
    final periods = await _repository.getLocal<BrickLotForagePeriodModel>();
    final pending = periods.where(
      (period) =>
          period.establishmentId == establishmentId && period.syncStatus == BrickLotForagePeriodSyncStatus.pending,
    );
    for (final period in pending) {
      await _repository.enqueueRemoteUpsert<BrickLotForagePeriodModel>(period);
    }
  }

  /// Marca el período como confirmado o rechazado y refresca el lote, cuyo
  /// recurso vigente recalcula backend.
  Future<void> applyPeriodSyncResult(BackendSyncResult result) async {
    if (!BrickLotForagePeriodRequestTransformer.matchesPeriodResource(result.resourcePath)) {
      return;
    }
    final local = _latestById(await _repository.getLocal<BrickLotForagePeriodModel>())[result.localId];
    if (local == null) return;

    var reconciled = local.copyWith(
      syncStatus: result.synchronized
          ? BrickLotForagePeriodSyncStatus.synchronized
          : BrickLotForagePeriodSyncStatus.rejected,
      syncErrorCode: result.errorCode,
    );
    final responseData = result.responseData;
    if (result.synchronized && responseData != null) {
      final authoritative = await _repository.modelFromRemoteData<BrickLotForagePeriodModel>(responseData);
      authoritative.primaryKey = local.primaryKey;
      reconciled = authoritative.copyWith(
        syncStatus: BrickLotForagePeriodSyncStatus.synchronized,
        syncErrorCode: null,
      );
    }
    await _repository.upsertLocal(reconciled);
    if (!result.synchronized) return;
    try {
      await _lotStore.pullRemoteLots(reconciled.establishmentId);
    } on Object catch (error, stackTrace) {
      _logger.warning('No se pudo refrescar el recurso vigente del lote.', error, stackTrace);
    }
  }

  /// Libera la escucha del canal global de sincronización.
  Future<void> dispose() => _syncSubscription.cancel();

  /// Puede haber más de una fila por período (la local y la confirmada por el
  /// servidor): queda la más reciente.
  static Map<String, BrickLotForagePeriodModel> _latestById(
    Iterable<BrickLotForagePeriodModel> stored,
  ) {
    final latest = <String, BrickLotForagePeriodModel>{};
    for (final period in stored) {
      final current = latest[period.localId];
      if (current == null || period.updatedAt.isAfter(current.updatedAt)) {
        latest[period.localId] = period;
      }
    }
    return latest;
  }
}
