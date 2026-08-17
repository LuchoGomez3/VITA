import 'dart:math';

import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/mappers/operating_expense_brick_mapper.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/repositories/operating_expense_repository.dart';

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
       _createId = createId ?? _uuidV4;

  final OperatingExpenseBrickStore _expenseStore;
  final OperatingExpenseCategoryBrickStore _categoryStore;
  final DateTime Function() _now;
  final String Function() _createId;

  static const Map<OperatingExpenseType, Map<String, String>> _predefined = {
    OperatingExpenseType.productionCost: {
      'sanidad': 'Sanidad',
      'alimentacion': 'Alimentación',
      'identificacion': 'Identificación',
    },
    OperatingExpenseType.administrativeExpense: {
      'combustible': 'Combustible',
      'estructura': 'Estructura',
      'honorarios': 'Honorarios',
    },
  };

  @override
  Future<Result<OperatingExpense>> createExpense(OperatingExpense expense) async {
    try {
      final saved = await _expenseStore.upsertExpense(OperatingExpenseBrickMapper.toBrick(expense));
      return Result.success(OperatingExpenseBrickMapper.fromBrick(saved));
    } on Object {
      return const Result.failure(DomainException(message: 'No se pudo guardar el egreso en el dispositivo.'));
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
      final predefinedDuplicate = _predefined[type]!.entries
          .where((item) => _normalize(item.value) == normalizedName)
          .firstOrNull;
      if (predefinedDuplicate != null) {
        return Result.success(
          OperatingExpenseCategory(
            value: predefinedDuplicate.key,
            label: predefinedDuplicate.value,
            type: type,
          ),
        );
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
    } on Object {
      return const Result.failure(DomainException(message: 'No se pudo guardar la categoría en el dispositivo.'));
    }
  }

  @override
  Future<Result<List<OperatingExpenseCategory>>> getCategories({
    required String establishmentId,
    required OperatingExpenseType type,
  }) async {
    try {
      return Result.success(await _allCategories(establishmentId, type));
    } on Object {
      return const Result.failure(DomainException(message: 'No se pudieron leer las categorías disponibles.'));
    }
  }

  Future<List<OperatingExpenseCategory>> _allCategories(String establishmentId, OperatingExpenseType type) async {
    final predefined = _predefined[type]!.entries.map(
      (entry) => OperatingExpenseCategory(
        value: entry.key,
        label: entry.value,
        type: type,
      ),
    );
    final custom = await _categoryStore.getLocalCategories(establishmentId: establishmentId, type: type.value);
    return [...predefined, ...custom.map((item) => _categoryFromBrick(item, type))];
  }

  OperatingExpenseCategory _categoryFromBrick(BrickOperatingExpenseCategoryModel model, OperatingExpenseType type) =>
      OperatingExpenseCategory(value: model.value, label: model.name, type: type, custom: true, id: model.localId);

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[áàäâ]'), 'a')
      .replaceAll(RegExp('[éèëê]'), 'e')
      .replaceAll(RegExp('[íìïî]'), 'i')
      .replaceAll(RegExp('[óòöô]'), 'o')
      .replaceAll(RegExp('[úùüû]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();

  static String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
