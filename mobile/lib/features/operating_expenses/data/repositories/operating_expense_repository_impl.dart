import 'dart:io';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/mappers/operating_expense_brick_mapper.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/catalogs/operating_expense_category_catalog.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
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
    DateTime Function()? now,
    String Function()? createId,
  }) : _expenseStore = expenseStore,
       _categoryStore = categoryStore,
       _now = now ?? DateTime.now,
       _createId = createId ?? generateUuidV4;

  final OperatingExpenseBrickStore _expenseStore;
  final OperatingExpenseCategoryBrickStore _categoryStore;
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
