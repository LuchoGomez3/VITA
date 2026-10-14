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

  static const _duplicateErrorCode = 'categoria_egreso_duplicada';

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
    return selectLocalCategories(
      stored,
      establishmentId: establishmentId,
      type: type,
    );
  }

  /// Deduplica el catálogo por su identidad funcional y preserva UUIDs reales.
  static List<BrickOperatingExpenseCategoryModel> selectLocalCategories(
    Iterable<BrickOperatingExpenseCategoryModel> stored, {
    required String establishmentId,
    required String type,
  }) {
    final byId = _latestById(stored);
    final byIdentity = <String, BrickOperatingExpenseCategoryModel>{};
    for (final category in byId.values.where(
      (item) => item.establishmentId == establishmentId && item.type == type && item.deletedAt == null,
    )) {
      final key = _identity(category);
      final current = byIdentity[key];
      if (current == null || _preferNaturalIdentity(category, current)) {
        byIdentity[key] = category;
      }
    }
    return byIdentity.values.toList();
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

  /// Considera confirmada una categoría cuyo valor ya existe en el backend.
  static bool isConfirmed(BackendSyncResult result) => result.synchronized || result.errorCode == _duplicateErrorCode;

  @override
  Future<void> cacheRemoteCategories(Iterable<BrickOperatingExpenseCategoryModel> categories) async {
    final stored = await _repository.getLocal<BrickOperatingExpenseCategoryModel>();
    final byId = _latestById(stored);
    final byIdentity = <String, BrickOperatingExpenseCategoryModel>{};
    for (final category in byId.values.where((item) => item.deletedAt == null)) {
      final key = _identity(category);
      final current = byIdentity[key];
      if (current == null || _preferNaturalIdentity(category, current)) {
        byIdentity[key] = category;
      }
    }
    for (final category in categories) {
      final identity = _identity(category);
      final matching = byIdentity[identity];
      if (matching != null && matching.localId != category.localId) {
        final confirmed = matching.copyWith(
          syncStatus: BrickOperatingExpenseCategorySyncStatus.synchronized,
        );
        await _repository.upsertLocal(confirmed);
        byId[confirmed.localId] = confirmed;
        byIdentity[identity] = confirmed;
        continue;
      }
      final current = byId[category.localId];
      if (current != null && current.updatedAt.isAfter(category.updatedAt)) continue;
      final reconciled = category.copyWith(
        syncStatus: BrickOperatingExpenseCategorySyncStatus.synchronized,
      )..primaryKey = current?.primaryKey;
      await _repository.upsertLocal(reconciled);
      byId[category.localId] = reconciled;
      byIdentity[identity] = reconciled;
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

  static String _identity(BrickOperatingExpenseCategoryModel category) =>
      '${category.establishmentId}:${category.type}:${category.value}';

  static bool _preferNaturalIdentity(
    BrickOperatingExpenseCategoryModel candidate,
    BrickOperatingExpenseCategoryModel current,
  ) {
    final candidateIsSynthetic = candidate.localId.startsWith('catalog:');
    final currentIsSynthetic = current.localId.startsWith('catalog:');
    if (candidateIsSynthetic != currentIsSynthetic) return !candidateIsSynthetic;
    return candidate.updatedAt.isAfter(current.updatedAt);
  }

  Future<void> _applySyncResult(BackendSyncResult result) async {
    if (!result.resourcePath.endsWith(
      BrickOperatingExpenseCategoryRequestTransformer.categoriesPath,
    )) {
      return;
    }
    final category = await getById(result.localId);
    if (category == null) return;
    final confirmed = isConfirmed(result);
    await _repository.upsertLocal(
      category.copyWith(
        syncStatus: confirmed
            ? BrickOperatingExpenseCategorySyncStatus.synchronized
            : BrickOperatingExpenseCategorySyncStatus.rejected,
        syncErrorCode: confirmed ? null : result.errorCode,
      ),
    );
  }

  /// Libera la escucha del canal global de sincronizacion.
  Future<void> dispose() => _subscription.cancel();
}
