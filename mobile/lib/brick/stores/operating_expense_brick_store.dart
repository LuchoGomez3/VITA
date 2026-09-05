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
  /// Guarda localmente y encola la sincronizacion sin esperar al backend.
  Future<BrickOperatingExpenseModel> upsertExpense(BrickOperatingExpenseModel expense);

  /// Lista egresos locales vigentes, deduplicados por UUID.
  ///
  /// Un [establishmentId] nulo incluye todos los establecimientos disponibles.
  Future<List<BrickOperatingExpenseModel>> getLocalExpenses(String? establishmentId);

  /// Descarga y reconcilia cambios centrales incluyendo tombstones.
  Future<void> pullRemoteExpenses(String establishmentId);

  /// Reconcilia una respuesta ya descargada usando UUID y last-write-wins.
  Future<void> reconcileRemoteExpenses(Iterable<BrickOperatingExpenseModel> expenses);
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
  Future<BrickOperatingExpenseModel> upsertExpense(BrickOperatingExpenseModel expense) async {
    final saved = await _repository.upsertLocal(expense);
    if (await _dependencyIsSynchronized(saved)) {
      // La copia local ya esta disponible. La red nunca bloquea la confirmacion
      // del alta y el listener aplica luego el resultado definitivo del backend.
      unawaited(_repository.enqueueRemoteUpsert(saved));
    }
    return saved;
  }

  Future<bool> _dependencyIsSynchronized(BrickOperatingExpenseModel expense) async {
    final categoryId = expense.customCategoryId;
    if (categoryId == null) return true;
    final category = await _categoryStore.getById(categoryId);
    return category?.syncStatus == BrickOperatingExpenseCategorySyncStatus.synchronized;
  }

  @override
  Future<List<BrickOperatingExpenseModel>> getLocalExpenses(String? establishmentId) async {
    final stored = await _repository.getLocal<BrickOperatingExpenseModel>();
    return selectLocalExpenses(stored, establishmentId: establishmentId);
  }

  /// Selecciona la version vigente de cada egreso para el alcance solicitado.
  static List<BrickOperatingExpenseModel> selectLocalExpenses(
    Iterable<BrickOperatingExpenseModel> stored, {
    required String? establishmentId,
  }) {
    final byId = <String, BrickOperatingExpenseModel>{};
    final scoped = establishmentId == null ? stored : stored.where((item) => item.establishmentId == establishmentId);
    for (final expense in scoped) {
      final current = byId[expense.localId];
      if (current == null || _prefer(expense, current)) byId[expense.localId] = expense;
    }
    return byId.values.where((expense) => expense.deletedAt == null).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  static bool _prefer(BrickOperatingExpenseModel candidate, BrickOperatingExpenseModel current) {
    final updatedComparison = candidate.updatedAt.compareTo(current.updatedAt);
    if (updatedComparison != 0) return updatedComparison > 0;
    return candidate.syncStatus != BrickOperatingExpenseSyncStatus.synchronized &&
        current.syncStatus == BrickOperatingExpenseSyncStatus.synchronized;
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
    await reconcileRemoteExpenses(remote);
  }

  @override
  Future<void> reconcileRemoteExpenses(Iterable<BrickOperatingExpenseModel> expenses) async {
    final stored = await _repository.getLocal<BrickOperatingExpenseModel>();
    final localById = <String, BrickOperatingExpenseModel>{};
    for (final item in stored) {
      final current = localById[item.localId];
      if (current == null || _prefer(item, current)) localById[item.localId] = item;
    }
    for (final remote in expenses) {
      final local = localById[remote.localId];
      if (local != null && local.updatedAt.isAfter(remote.updatedAt)) continue;
      final reconciled = remote.copyWith(syncStatus: BrickOperatingExpenseSyncStatus.synchronized)
        ..primaryKey = local?.primaryKey;
      await _repository.upsertLocal(reconciled);
      localById[remote.localId] = reconciled;
    }
  }

  Future<void> _applySyncResult(BackendSyncResult result) async {
    if (result.resourcePath.endsWith(
      BrickOperatingExpenseCategoryRequestTransformer.categoriesPath,
    )) {
      if (BrickOperatingExpenseCategoryStore.isConfirmed(result)) {
        await _enqueueExpensesWaitingFor(result.localId);
      } else {
        await _rejectExpensesWaitingFor(
          result.localId,
          result.errorCode,
        );
      }
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

  Future<void> _rejectExpensesWaitingFor(
    String categoryId,
    String? errorCode,
  ) async {
    final stored = await _repository.getLocal<BrickOperatingExpenseModel>();
    for (final expense in stored.where(
      (item) => item.customCategoryId == categoryId && item.syncStatus == BrickOperatingExpenseSyncStatus.pending,
    )) {
      await _repository.upsertLocal(
        rejectExpenseForCategory(
          expense: expense,
          categoryId: categoryId,
          errorCode: errorCode,
        ),
      );
    }
  }

  /// Propaga el rechazo de una categoria al egreso que depende de ella.
  ///
  /// Se mantiene como transformacion pura para verificar que el estado y el
  /// codigo funcional se conserven antes de escribir la copia en SQLite.
  static BrickOperatingExpenseModel rejectExpenseForCategory({
    required BrickOperatingExpenseModel expense,
    required String categoryId,
    required String? errorCode,
  }) {
    if (expense.customCategoryId != categoryId || expense.syncStatus != BrickOperatingExpenseSyncStatus.pending) {
      return expense;
    }
    return expense.copyWith(
      syncStatus: BrickOperatingExpenseSyncStatus.rejected,
      syncErrorCode: errorCode,
    );
  }

  /// Libera la escucha del canal global de sincronizacion.
  Future<void> dispose() => _subscription.cancel();
}
