import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Acceso offline-first a egresos operativos.
abstract class OperatingExpenseBrickStore {
  /// Guarda localmente y espera brevemente la confirmacion del backend.
  Future<BrickOperatingExpenseModel> upsertExpense(
    BrickOperatingExpenseModel expense, {
    Duration remoteWaitTimeout = const Duration(seconds: 10),
  });

  /// Lista egresos locales vigentes, deduplicados por UUID.
  Future<List<BrickOperatingExpenseModel>> getLocalExpenses(String establishmentId);

  /// Descarga y reconcilia cambios centrales incluyendo tombstones.
  Future<void> pullRemoteExpenses(String establishmentId);
}

/// Implementacion Brick que garantiza categoria antes que egreso dependiente.
class BrickOperatingExpenseStore implements OperatingExpenseBrickStore {
  BrickOperatingExpenseStore._(this._repository, this._categoryStore) {
    _subscription = _repository.syncResults.listen(_applySyncResult);
  }

  static BrickOperatingExpenseStore? _instance;
  final AppBrickRepository _repository;
  final BrickOperatingExpenseCategoryStore _categoryStore;
  late final StreamSubscription<BackendSyncResult> _subscription;

  /// Instancia configurada por el bootstrap.
  static BrickOperatingExpenseStore get instance =>
      _instance ?? (throw StateError('BrickOperatingExpenseStore has not been initialized yet.'));

  /// Registra el store y su dependencia de categorias.
  static void configure(
    AppBrickRepository repository,
    BrickOperatingExpenseCategoryStore categoryStore,
  ) {
    _instance ??= BrickOperatingExpenseStore._(repository, categoryStore);
  }

  @override
  Future<BrickOperatingExpenseModel> upsertExpense(
    BrickOperatingExpenseModel expense, {
    Duration remoteWaitTimeout = const Duration(seconds: 10),
  }) async {
    final syncResult = Completer<BackendSyncResult?>();
    final resultSubscription = _repository.syncResults
        .where(
          (result) =>
              result.localId == expense.localId &&
              result.resourcePath.endsWith(BrickOperatingExpenseRequestTransformer.expensesPath),
        )
        .listen((result) {
          if (!syncResult.isCompleted) syncResult.complete(result);
        });
    try {
      final saved = await _repository.upsertLocal(expense);
      if (await _dependencyIsSynchronized(saved)) {
        unawaited(_repository.enqueueRemoteUpsert(saved));
      }
      final result = await syncResult.future.timeout(
        remoteWaitTimeout,
        onTimeout: () => null,
      );
      if (result == null) return saved;
      return saved.copyWith(
        syncStatus: result.synchronized
            ? BrickOperatingExpenseSyncStatus.synchronized
            : BrickOperatingExpenseSyncStatus.rejected,
        syncErrorCode: result.errorCode,
      );
    } finally {
      await resultSubscription.cancel();
    }
  }

  Future<bool> _dependencyIsSynchronized(BrickOperatingExpenseModel expense) async {
    final categoryId = expense.customCategoryId;
    if (categoryId == null) return true;
    final category = await _categoryStore.getById(categoryId);
    return category?.syncStatus == BrickOperatingExpenseCategorySyncStatus.synchronized;
  }

  @override
  Future<List<BrickOperatingExpenseModel>> getLocalExpenses(String establishmentId) async {
    final stored = await _repository.getLocal<BrickOperatingExpenseModel>();
    final byId = <String, BrickOperatingExpenseModel>{};
    for (final expense in stored.where((item) => item.establishmentId == establishmentId)) {
      final current = byId[expense.localId];
      if (current == null || _prefer(expense, current)) byId[expense.localId] = expense;
    }
    return byId.values.where((expense) => expense.deletedAt == null).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool _prefer(BrickOperatingExpenseModel candidate, BrickOperatingExpenseModel current) {
    if (candidate.syncStatus != BrickOperatingExpenseSyncStatus.synchronized &&
        current.syncStatus == BrickOperatingExpenseSyncStatus.synchronized) {
      return true;
    }
    return candidate.updatedAt.isAfter(current.updatedAt);
  }

  @override
  Future<void> pullRemoteExpenses(String establishmentId) async {
    final remote = await _repository.remoteProvider.get<BrickOperatingExpenseModel>(
      repository: _repository,
      query: Query(
        forProviders: [
          RestProviderQuery(
            request: BrickOperatingExpenseRequestTransformer.listByEstablishmentRequest(establishmentId),
          ),
        ],
      ),
    );
    final local = await _repository.getLocal<BrickOperatingExpenseModel>();
    final localById = {for (final item in local) item.localId: item};
    for (final expense in remote) {
      final existing = localById[expense.localId];
      if (existing != null && existing.syncStatus != BrickOperatingExpenseSyncStatus.synchronized) continue;
      await _repository.upsertLocal(
        expense.copyWith(
          syncStatus: BrickOperatingExpenseSyncStatus.synchronized,
        )..primaryKey = existing?.primaryKey,
      );
    }
  }

  Future<void> _applySyncResult(BackendSyncResult result) async {
    if (result.resourcePath.endsWith(
          BrickOperatingExpenseCategoryRequestTransformer.categoriesPath,
        ) &&
        result.synchronized) {
      await _enqueueExpensesWaitingFor(result.localId);
      return;
    }
    if (!result.resourcePath.endsWith(BrickOperatingExpenseRequestTransformer.expensesPath)) return;
    final stored = await _repository.getLocal<BrickOperatingExpenseModel>();
    for (final expense in stored) {
      if (expense.localId != result.localId) continue;
      await _repository.upsertLocal(
        expense.copyWith(
          syncStatus: result.synchronized
              ? BrickOperatingExpenseSyncStatus.synchronized
              : BrickOperatingExpenseSyncStatus.rejected,
          syncErrorCode: result.errorCode,
        ),
      );
      return;
    }
  }

  Future<void> _enqueueExpensesWaitingFor(String categoryId) async {
    final stored = await _repository.getLocal<BrickOperatingExpenseModel>();
    for (final expense in stored.where(
      (item) => item.customCategoryId == categoryId && item.syncStatus == BrickOperatingExpenseSyncStatus.pending,
    )) {
      unawaited(_repository.enqueueRemoteUpsert(expense));
    }
  }

  /// Libera la escucha del canal global de sincronizacion.
  Future<void> dispose() => _subscription.cancel();
}
