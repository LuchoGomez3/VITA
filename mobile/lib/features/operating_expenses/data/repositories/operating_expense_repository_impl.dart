import 'dart:io';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/datasources/operating_expense_remote_data_source.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/mappers/operating_expense_brick_mapper.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/catalogs/operating_expense_category_catalog.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/repositories/operating_expense_repository.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

/// Implementa egresos con SQLite como respaldo y confirmacion REST acotada.
class OperatingExpenseRepositoryImpl implements OperatingExpenseRepository {
  /// Crea el repositorio con stores inyectables para probarlo sin plataforma.
  OperatingExpenseRepositoryImpl({
    required OperatingExpenseBrickStore expenseStore,
    required OperatingExpenseCategoryBrickStore categoryStore,
    OperatingExpenseRemoteDataSource? remoteDataSource,
    DateTime Function()? now,
    String Function()? createId,
  }) : _expenseStore = expenseStore,
       _categoryStore = categoryStore,
       _remoteDataSource = remoteDataSource,
       _now = now ?? DateTime.now,
       _createId = createId ?? generateUuidV4;

  final OperatingExpenseBrickStore _expenseStore;
  final OperatingExpenseCategoryBrickStore _categoryStore;
  final OperatingExpenseRemoteDataSource? _remoteDataSource;
  final DateTime Function() _now;
  final String Function() _createId;
  static final Logger _logger = Logger('OperatingExpenseRepository');

  @override
  Future<Result<OperatingExpense>> createExpense(OperatingExpense expense) async {
    try {
      final saved = await _expenseStore.upsertExpense(OperatingExpenseBrickMapper.toBrick(expense));
      return Result.success(OperatingExpenseBrickMapper.fromBrick(saved));
    } on DatabaseException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.saveExpense, error, stackTrace);
    } on OfflineFirstException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.saveExpense, error, stackTrace);
    } on RestException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.saveExpense, error, stackTrace);
    } on FileSystemException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.saveExpense, error, stackTrace);
    }
  }

  @override
  Future<Result<OperatingExpenseCategory>> createCategory({
    required String establishmentId,
    required OperatingExpenseType type,
    required String name,
  }) async {
    try {
      final normalizedName = _normalize(name);
      final stored = await _categoryStore.getLocalCategories(
        establishmentId: establishmentId,
        type: type.value,
      );
      final storedDuplicate = stored.where((item) => _normalize(item.name) == normalizedName).firstOrNull;
      if (storedDuplicate != null) {
        // Un 4xx elimina la request de la cola de Brick y deja la copia local
        // rechazada. Al volver a agregar la misma categoría se reutiliza su UUID
        // y se encola nuevamente con el contrato corregido, sin duplicarla.
        final category = storedDuplicate.syncStatus == BrickOperatingExpenseCategorySyncStatus.rejected
            ? await _categoryStore.upsertCategory(
                storedDuplicate.copyWith(
                  syncStatus: BrickOperatingExpenseCategorySyncStatus.pending,
                ),
              )
            : storedDuplicate;
        return Result.success(_categoryFromBrick(category, type));
      }
      final predefinedDuplicate = OperatingExpenseCategoryCatalog.forType(
        type,
      ).where((item) => _normalize(item.label) == normalizedName).firstOrNull;
      if (predefinedDuplicate != null) {
        return Result.success(predefinedDuplicate);
      }
      final timestamp = _now().toUtc();
      final model = BrickOperatingExpenseCategoryModel(
        localId: _createId(),
        establishmentId: establishmentId,
        type: type.value,
        name: name.trim(),
        value: normalizedName.replaceAll(' ', '_'),
        createdAt: timestamp,
        updatedAt: timestamp,
      );
      final saved = await _categoryStore.upsertCategory(model);
      return Result.success(_categoryFromBrick(saved, type));
    } on DatabaseException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.saveCategory, error, stackTrace);
    } on OfflineFirstException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.saveCategory, error, stackTrace);
    } on RestException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.saveCategory, error, stackTrace);
    } on FileSystemException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.saveCategory, error, stackTrace);
    }
  }

  @override
  Future<Result<List<OperatingExpenseCategory>>> getCategories({
    required String establishmentId,
    required OperatingExpenseType type,
  }) async {
    try {
      return Result.success(await _allCategories(establishmentId, type));
    } on DatabaseException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.loadCategories, error, stackTrace);
    } on OfflineFirstException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.loadCategories, error, stackTrace);
    } on RestException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.loadCategories, error, stackTrace);
    } on FileSystemException catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.loadCategories, error, stackTrace);
    }
  }

  @override
  Future<Result<OperatingExpenseHistory>> getLocalHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) async {
    try {
      final expenses = await _filteredLocalExpenses(establishmentId, filters);
      return Result.success(_localHistory(expenses));
    } on Object catch (error, stackTrace) {
      return _historyFailure(OperatingExpensePersistenceError.loadHistory, error, stackTrace);
    }
  }

  @override
  Future<Result<OperatingExpenseHistory>> refreshHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) async {
    final remoteDataSource = _remoteDataSource;
    if (remoteDataSource == null) {
      return const Result.failure(DomainException(message: 'Remote data source is not configured.'));
    }
    try {
      final page = await remoteDataSource.getExpenses(establishmentId, filters);
      await _expenseStore.reconcileRemoteExpenses(page.expenses);
      final visible = await _filteredLocalExpenses(establishmentId, filters);
      final remoteById = {for (final item in page.expenses) item.localId: item};
      final pending = visible.where((item) => item.syncStatus != OperatingExpenseSyncStatus.synchronized).toList();
      final pendingAdjustment = pending.fold(0, (sum, item) {
        final remote = remoteById[item.id];
        final replacedRemoteAmount = remote == null || remote.deletedAt != null
            ? 0
            : OperatingExpenseBrickMapper.decimalToCents(remote.amount);
        return sum + item.amountCents - replacedRemoteAmount;
      });
      return Result.success(
        OperatingExpenseHistory(
          expenses: visible,
          totalCents: page.totalCents + pendingAdjustment,
          cachedWithoutConnection: false,
          pendingCount: pending.length,
          totalIncludesPending: pending.isNotEmpty,
        ),
      );
    } on DomainException catch (error) {
      return Result.failure(error);
    } on Object catch (error, stackTrace) {
      return _historyFailure(OperatingExpensePersistenceError.refreshHistory, error, stackTrace);
    }
  }

  @override
  Future<Result<List<OperatingExpenseCategory>>> refreshCategories({required String establishmentId}) async {
    final remoteDataSource = _remoteDataSource;
    if (remoteDataSource == null) {
      return const Result.failure(DomainException(message: 'Remote data source is not configured.'));
    }
    try {
      final groups = await remoteDataSource.getCatalog(establishmentId);
      final timestamp = _now().toUtc();
      final remoteModels = groups.expand(
        (group) => group.categories
            .where((item) => item.custom)
            .map(
              (item) => BrickOperatingExpenseCategoryModel(
                localId: item.id ?? 'catalog:${group.type.value}:${item.value}:$establishmentId',
                establishmentId: establishmentId,
                type: group.type.value,
                name: item.label,
                value: item.value,
                createdAt: timestamp,
                updatedAt: timestamp,
                syncStatus: BrickOperatingExpenseCategorySyncStatus.synchronized,
              ),
            ),
      );
      await _categoryStore.cacheRemoteCategories(remoteModels);
      final local = await Future.wait(
        OperatingExpenseType.values.map((type) => _allCategories(establishmentId, type)),
      );
      return Result.success(
        _mergeCatalog([...groups.expand((group) => group.categories), ...local.expand((items) => items)]),
      );
    } on DomainException catch (error) {
      return Result.failure(error);
    } on Object catch (error, stackTrace) {
      return _persistenceFailure(OperatingExpensePersistenceError.loadCategories, _asException(error), stackTrace);
    }
  }

  @override
  Future<Result<OperatingExpenseExport>> exportHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) async {
    final remoteDataSource = _remoteDataSource;
    if (remoteDataSource == null) {
      return const Result.failure(DomainException(message: 'Remote data source is not configured.'));
    }
    try {
      return Result.success(await remoteDataSource.export(establishmentId, filters));
    } on DomainException catch (error) {
      return Result.failure(error);
    } on Object catch (error, stackTrace) {
      return _historyFailure(OperatingExpensePersistenceError.exportFailed, error, stackTrace);
    }
  }

  Future<List<OperatingExpense>> _filteredLocalExpenses(
    String establishmentId,
    OperatingExpenseFilters filters,
  ) async {
    final stored = await _expenseStore.getLocalExpenses(establishmentId);
    final categories = await Future.wait(
      OperatingExpenseType.values.map((type) => _allCategories(establishmentId, type)),
    );
    final labels = {
      for (final item in categories.expand((items) => items)) '${item.type.value}:${item.value}': item.label,
    };
    final mapped =
        stored
            .map(OperatingExpenseBrickMapper.fromBrick)
            .where((expense) {
              final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
              final from = filters.from;
              final to = filters.to;
              return (from == null || !date.isBefore(from)) &&
                  (to == null || !date.isAfter(to)) &&
                  (filters.type == null || expense.type == filters.type) &&
                  (filters.category == null || expense.category == filters.category);
            })
            .map(
              (expense) => expense.copyWith(categoryLabel: labels['${expense.type.value}:${expense.category}']),
            )
            .toList()
          ..sort((left, right) => right.date.compareTo(left.date));
    return mapped;
  }

  OperatingExpenseHistory _localHistory(List<OperatingExpense> expenses) {
    final pendingCount = expenses.where((item) => item.syncStatus != OperatingExpenseSyncStatus.synchronized).length;
    return OperatingExpenseHistory(
      expenses: expenses,
      totalCents: expenses.fold(0, (sum, item) => sum + item.amountCents),
      cachedWithoutConnection: true,
      pendingCount: pendingCount,
      totalIncludesPending: pendingCount > 0,
    );
  }

  List<OperatingExpenseCategory> _mergeCatalog(Iterable<OperatingExpenseCategory> remote) {
    final byKey = <String, OperatingExpenseCategory>{
      for (final item in OperatingExpenseCategoryCatalog.values) '${item.type.value}:${item.value}': item,
    };
    for (final item in remote) {
      byKey['${item.type.value}:${item.value}'] = item;
    }
    return byKey.values.toList(growable: false);
  }

  Result<T> _historyFailure<T>(
    OperatingExpensePersistenceError reason,
    Object error,
    StackTrace stackTrace,
  ) => _persistenceFailure(reason, _asException(error), stackTrace);

  Exception _asException(Object error) => error is Exception ? error : Exception(error.toString());

  Future<List<OperatingExpenseCategory>> _allCategories(String establishmentId, OperatingExpenseType type) async {
    final predefined = OperatingExpenseCategoryCatalog.forType(type);
    final custom = await _categoryStore.getLocalCategories(establishmentId: establishmentId, type: type.value);
    return [...predefined, ...custom.map((item) => _categoryFromBrick(item, type))];
  }

  OperatingExpenseCategory _categoryFromBrick(BrickOperatingExpenseCategoryModel model, OperatingExpenseType type) =>
      OperatingExpenseCategory(value: model.value, label: model.name, type: type, custom: true, id: model.localId);

  Result<T> _persistenceFailure<T>(
    OperatingExpensePersistenceError reason,
    Exception error,
    StackTrace stackTrace,
  ) {
    _logger.severe('Expected local persistence failure: ${reason.name}', error, stackTrace);
    return Result.failure(
      DomainException(
        message: reason.name,
        code: DomainErrorCode.offline,
        reason: reason,
      ),
    );
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[áàäâ]'), 'a')
      .replaceAll(RegExp('[éèëê]'), 'e')
      .replaceAll(RegExp('[íìïî]'), 'i')
      .replaceAll(RegExp('[óòöô]'), 'o')
      .replaceAll(RegExp('[úùüû]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp('[^a-z0-9]+'), ' ')
      .trim();
}
