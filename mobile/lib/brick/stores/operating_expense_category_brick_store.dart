import 'dart:async';

import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Acceso offline-first a categorias personalizadas de egresos.
abstract class OperatingExpenseCategoryBrickStore {
  /// Persiste y encola una categoria creada por el usuario.
  Future<BrickOperatingExpenseCategoryModel> upsertCategory(BrickOperatingExpenseCategoryModel category);

  /// Lista solamente categorias vigentes del establecimiento y tipo indicados.
  Future<List<BrickOperatingExpenseCategoryModel>> getLocalCategories({
    required String establishmentId,
    required String type,
  });

  /// Busca una categoria por UUID local.
  Future<BrickOperatingExpenseCategoryModel?> getById(String id);

  /// Guarda categorias de catalogo central sin encolarlas como altas locales.
  Future<void> cacheRemoteCategories(Iterable<BrickOperatingExpenseCategoryModel> categories);
}

/// Implementacion Brick para categorias de egresos.
class BrickOperatingExpenseCategoryStore implements OperatingExpenseCategoryBrickStore {
  BrickOperatingExpenseCategoryStore._(this._repository) {
    _subscription = _repository.syncResults.listen(_applySyncResult);
  }

  static BrickOperatingExpenseCategoryStore? _instance;
  final AppBrickRepository _repository;
  late final StreamSubscription<BackendSyncResult> _subscription;

  /// Instancia configurada por el bootstrap.
  static BrickOperatingExpenseCategoryStore get instance =>
      _instance ?? (throw StateError('BrickOperatingExpenseCategoryStore has not been initialized yet.'));

  /// Registra el store sobre el repositorio compartido.
  static void configure(AppBrickRepository repository) {
    _instance ??= BrickOperatingExpenseCategoryStore._(repository);
  }

  @override
  Future<BrickOperatingExpenseCategoryModel> upsertCategory(
    BrickOperatingExpenseCategoryModel category,
  ) async {
    final saved = await _repository.upsertLocal(category);
    unawaited(_repository.enqueueRemoteUpsert(saved));
    return saved;
  }

  @override
  Future<List<BrickOperatingExpenseCategoryModel>> getLocalCategories({
    required String establishmentId,
    required String type,
  }) async {
    final stored = await _repository.getLocal<BrickOperatingExpenseCategoryModel>();
    final byId = _latestById(stored);
    return byId.values
        .where(
          (category) =>
              category.establishmentId == establishmentId && category.type == type && category.deletedAt == null,
        )
        .toList();
  }

  @override
  Future<BrickOperatingExpenseCategoryModel?> getById(String id) async {
    final stored = await _repository.getLocal<BrickOperatingExpenseCategoryModel>();
    return selectLatestById(stored, id);
  }

  /// Selecciona por UUID la version con `updatedAt` mas reciente.
  static BrickOperatingExpenseCategoryModel? selectLatestById(
    Iterable<BrickOperatingExpenseCategoryModel> stored,
    String id,
  ) => _latestById(stored)[id];

  @override
  Future<void> cacheRemoteCategories(Iterable<BrickOperatingExpenseCategoryModel> categories) async {
    final stored = await _repository.getLocal<BrickOperatingExpenseCategoryModel>();
    final byId = _latestById(stored);
    for (final category in categories) {
      final current = byId[category.localId];
      if (current != null && current.updatedAt.isAfter(category.updatedAt)) continue;
      final reconciled = category.copyWith(
        syncStatus: BrickOperatingExpenseCategorySyncStatus.synchronized,
      )..primaryKey = current?.primaryKey;
      await _repository.upsertLocal(reconciled);
      byId[category.localId] = reconciled;
    }
  }

  static Map<String, BrickOperatingExpenseCategoryModel> _latestById(
    Iterable<BrickOperatingExpenseCategoryModel> stored,
  ) {
    final byId = <String, BrickOperatingExpenseCategoryModel>{};
    for (final category in stored) {
      final current = byId[category.localId];
      if (current == null || category.updatedAt.isAfter(current.updatedAt)) {
        byId[category.localId] = category;
      }
    }
    return byId;
  }

  Future<void> _applySyncResult(BackendSyncResult result) async {
    if (!result.resourcePath.endsWith(
      BrickOperatingExpenseCategoryRequestTransformer.categoriesPath,
    )) {
      return;
    }
    final category = await getById(result.localId);
    if (category == null) return;
    await _repository.upsertLocal(
      category.copyWith(
        syncStatus: result.synchronized
            ? BrickOperatingExpenseCategorySyncStatus.synchronized
            : BrickOperatingExpenseCategorySyncStatus.rejected,
        syncErrorCode: result.errorCode,
      ),
    );
  }

  /// Libera la escucha del canal global de sincronizacion.
  Future<void> dispose() => _subscription.cancel();
}
