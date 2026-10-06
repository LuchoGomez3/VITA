import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Acceso local a lotes sin encolar requests remotos en la Fase 2.
abstract class LotBrickStore {
  /// Inserta o actualiza el lote solamente en SQLite.
  Future<BrickLotModel> upsertLocalLot(BrickLotModel lot);

  /// Lista los lotes locales vigentes del establecimiento.
  Future<List<BrickLotModel>> getLocalLots(String establishmentId);

  /// Busca un lote local vigente por UUID.
  Future<BrickLotModel?> getLocalLot(String lotId);

  /// Descarga cambios remotos cuando la integración está habilitada.
  Future<void> pullRemoteLots(String establishmentId);

  /// Envía los lotes pendientes del establecimiento.
  Future<void> pushPendingLots(String establishmentId);
}

/// Implementación Brick de persistencia durable local.
class BrickLotStore implements LotBrickStore {
  BrickLotStore._(this._repository, {required bool enableRemoteSync}) : _enableRemoteSync = enableRemoteSync {
    _syncSubscription = _repository.syncResults.listen(applyLotSyncResult);
  }

  static BrickLotStore? _instance;
  final AppBrickRepository _repository;
  final bool _enableRemoteSync;
  late final StreamSubscription<BackendSyncResult> _syncSubscription;

  /// Instancia configurada durante el bootstrap.
  static BrickLotStore get instance => _instance ?? (throw StateError('BrickLotStore has not been initialized yet.'));

  /// Registra el repositorio Brick compartido.
  static void configure(
    AppBrickRepository repository, {
    bool enableRemoteSync = false,
  }) {
    _instance ??= BrickLotStore._(
      repository,
      enableRemoteSync: enableRemoteSync,
    );
  }

  @override
  Future<BrickLotModel> upsertLocalLot(BrickLotModel lot) async {
    if (lot.primaryKey == null) {
      final stored = await _repository.getLocal<BrickLotModel>();
      final existing = _latestVersionWithId(stored, lot.localId);
      lot.primaryKey = existing?.primaryKey;
    }
    final saved = await _repository.upsertLocal(lot);
    if (_enableRemoteSync) {
      unawaited(_repository.enqueueRemoteUpsert<BrickLotModel>(saved));
    }
    return saved;
  }

  static BrickLotModel? _latestVersionWithId(
    Iterable<BrickLotModel> stored,
    String localId,
  ) {
    BrickLotModel? latest;
    for (final lot in stored.where((item) => item.localId == localId)) {
      if (latest == null || lot.updatedAt.isAfter(latest.updatedAt)) {
        latest = lot;
      }
    }
    return latest;
  }

  @override
  Future<List<BrickLotModel>> getLocalLots(String establishmentId) async {
    final stored = await _repository.getLocal<BrickLotModel>();
    return selectLocalLots(stored, establishmentId: establishmentId);
  }

  @override
  Future<BrickLotModel?> getLocalLot(String lotId) async {
    final stored = await _repository.getLocal<BrickLotModel>();
    final matches = stored.where((lot) => lot.localId == lotId).toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return matches.first.deletedAt == null ? matches.first : null;
  }

  @override
  Future<void> pullRemoteLots(String establishmentId) async {
    // La lectura remota mantiene disponible el catalogo offline aunque las
    // escrituras de lotes continuen protegidas por el feature flag.
    final remoteLots = await _repository.remoteProvider.get<BrickLotModel>(
      repository: _repository,
      query: Query(
        forProviders: [
          RestProviderQuery(
            request: BrickLotRequestTransformer.listByEstablishmentRequest(
              establishmentId,
            ),
          ),
        ],
      ),
    );
    final localLots = await _repository.getLocal<BrickLotModel>();
    final localById = {for (final lot in localLots) lot.localId: lot};
    for (final remote in remoteLots) {
      final local = localById[remote.localId];
      if (local != null && local.syncStatus != BrickLotSyncStatus.synchronized) {
        continue;
      }
      final synchronized = remote.copyWith(
        syncStatus: BrickLotSyncStatus.synchronized,
      )..primaryKey = local?.primaryKey;
      await _repository.upsertLocal<BrickLotModel>(synchronized);
    }
  }

  @override
  Future<void> pushPendingLots(String establishmentId) async {
    if (!_enableRemoteSync) return;
    final lots = await _repository.getLocal<BrickLotModel>();
    final pending = lots.where(
      (lot) => lot.establishmentId == establishmentId && lot.syncStatus == BrickLotSyncStatus.pending,
    );
    for (final lot in pending) {
      await _repository.enqueueRemoteUpsert<BrickLotModel>(lot);
    }
  }

  /// Descarga destinos activos aunque la edición remota de lotes siga apagada.
  /// Los lotes confirmados que dejaron de aparecer se retiran de los destinos;
  /// los borradores locales se conservan para que el usuario vea su estado.
  Future<void> pullActiveLots(String establishmentId) async {
    final remote = await _repository.remoteProvider.get<BrickLotModel>(
      repository: _repository,
      query: Query(
        forProviders: [RestProviderQuery(request: BrickLotRequestTransformer.activeLotsRequest(establishmentId))],
      ),
    );
    await _repository.runLocalTransaction((transaction) async {
      final local = await transaction.getLocal<BrickLotModel>();
      final ids = remote.map((lot) => lot.localId).toSet();
      for (final lot in local.where(
        (lot) =>
            lot.establishmentId == establishmentId &&
            lot.syncStatus == BrickLotSyncStatus.synchronized &&
            !ids.contains(lot.localId),
      )) {
        await transaction.upsert(lot.copyWith(statusCode: 'inactivo'));
      }
      for (final lot in remote) {
        final existing = local.where((item) => item.localId == lot.localId).firstOrNull;
        if (existing != null && existing.syncStatus != BrickLotSyncStatus.synchronized) continue;
        lot.primaryKey = existing?.primaryKey;
        await transaction.upsert(lot.copyWith(syncStatus: BrickLotSyncStatus.synchronized));
      }
    });
  }

  /// Aplica confirmaciones o rechazos publicados por el cliente HTTP.
  Future<void> applyLotSyncResult(BackendSyncResult result) async {
    // TODO(field-sync): mapear los códigos autoritativos de nombre duplicado,
    // geometría inválida y superposición al flujo de reconciliación mobile.
    if (!BrickLotRequestTransformer.matchesLotResource(result.resourcePath)) {
      return;
    }
    final lots = await _repository.getLocal<BrickLotModel>();
    for (final lot in lots) {
      if (lot.localId != result.localId) continue;
      final responseData = result.responseData;
      if (result.synchronized && responseData != null) {
        final authoritative = await _repository.modelFromRemoteData<BrickLotModel>(responseData);
        authoritative.primaryKey = lot.primaryKey;
        await _repository.upsertLocal<BrickLotModel>(
          authoritative.copyWith(
            syncStatus: BrickLotSyncStatus.synchronized,
            syncErrorCode: null,
          ),
        );
      } else {
        await _repository.upsertLocal<BrickLotModel>(
          lot.copyWith(
            syncStatus: result.synchronized ? BrickLotSyncStatus.synchronized : BrickLotSyncStatus.rejected,
            syncErrorCode: result.errorCode,
          ),
        );
      }
      return;
    }
  }

  /// Libera la escucha de resultados en tests o apagado de infraestructura.
  Future<void> dispose() => _syncSubscription.cancel();

  /// Deduplica por UUID, filtra tombstones y conserva aislamiento tenant.
  static List<BrickLotModel> selectLocalLots(
    Iterable<BrickLotModel> stored, {
    required String establishmentId,
  }) {
    final byId = <String, BrickLotModel>{};
    for (final lot in stored.where((item) => item.establishmentId == establishmentId)) {
      final current = byId[lot.localId];
      if (current == null || lot.updatedAt.isAfter(current.updatedAt)) {
        byId[lot.localId] = lot;
      }
    }
    return byId.values.where((lot) => lot.deletedAt == null).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
