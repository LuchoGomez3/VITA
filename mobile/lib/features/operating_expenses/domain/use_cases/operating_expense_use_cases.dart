import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/repositories/operating_expense_repository.dart';

/// Valida y registra un egreso preservando el resultado de sincronizacion.
class CreateOperatingExpenseUseCase {
  /// Crea el caso de uso.
  const CreateOperatingExpenseUseCase(this._repository);
  final OperatingExpenseRepository _repository;

  /// Ejecuta validaciones defensivas antes de persistir.
  Future<Result<OperatingExpense>> call({
    required OperatingExpense expense,
    required List<OperatingExpenseCategory> categories,
    required DateTime today,
  }) {
    final error = validate(expense: expense, categories: categories, today: today);
    if (error != null) {
      return Future.value(
        Result.failure(
          DomainException(
            message: error.name,
            code: DomainErrorCode.validation,
            reason: error,
          ),
        ),
      );
    }
    return _repository.createExpense(expense);
  }

  /// Devuelve el primer error respetando el orden visual del formulario.
  OperatingExpenseValidationError? validate({
    required OperatingExpense expense,
    required List<OperatingExpenseCategory> categories,
    required DateTime today,
  }) {
    if (expense.amountCents <= 0) return OperatingExpenseValidationError.invalidAmount;
    if (expense.category.trim().isEmpty) return OperatingExpenseValidationError.requiredCategory;
    final matches = categories.any((item) => item.value == expense.category && item.type == expense.type);
    if (!matches) return OperatingExpenseValidationError.incompatibleCategory;
    if (expense.supply.trim().isEmpty) return OperatingExpenseValidationError.requiredSupply;
    final selected = DateTime(expense.date.year, expense.date.month, expense.date.day);
    final maximum = DateTime(today.year, today.month, today.day);
    if (selected.isAfter(maximum)) return OperatingExpenseValidationError.futureDate;
    return null;
  }
}

/// Expone el historial local y su actualizacion remota manteniendo los filtros.
class GetOperatingExpenseHistoryUseCase {
  /// Crea el caso de uso.
  const GetOperatingExpenseHistoryUseCase(this._repository);

  final OperatingExpenseRepository _repository;

  /// Obtiene primero la fuente persistida en SQLite.
  Future<Result<OperatingExpenseHistory>> local(
    String establishmentId,
    OperatingExpenseFilters filters,
  ) => _repository.getLocalHistory(establishmentId: establishmentId, filters: filters);

  /// Consulta backend y reconcilia el resultado con SQLite.
  Future<Result<OperatingExpenseHistory>> refresh(
    String establishmentId,
    OperatingExpenseFilters filters,
  ) => _repository.refreshHistory(establishmentId: establishmentId, filters: filters);
}

/// Obtiene el catalogo completo, incluidas categorias centrales personalizadas.
class RefreshOperatingExpenseCatalogUseCase {
  /// Crea el caso de uso.
  const RefreshOperatingExpenseCatalogUseCase(this._repository);

  final OperatingExpenseRepository _repository;

  /// Actualiza y devuelve las categorias disponibles para el establecimiento.
  Future<Result<List<OperatingExpenseCategory>>> call(String establishmentId) =>
      _repository.refreshCategories(establishmentId: establishmentId);
}

/// Solicita el archivo CSV exactamente para el filtro activo.
class ExportOperatingExpensesUseCase {
  /// Crea el caso de uso.
  const ExportOperatingExpensesUseCase(this._repository);

  final OperatingExpenseRepository _repository;

  /// Descarga el archivo central.
  Future<Result<OperatingExpenseExport>> call(
    String establishmentId,
    OperatingExpenseFilters filters,
  ) => _repository.exportHistory(establishmentId: establishmentId, filters: filters);
}

/// Expone operaciones de catalogo sin filtrar detalles de persistencia.
class OperatingExpenseCatalogUseCase {
  /// Crea el caso de uso.
  const OperatingExpenseCatalogUseCase(this._repository);
  final OperatingExpenseRepository _repository;

  /// Lee categorias locales.
  Future<Result<List<OperatingExpenseCategory>>> getCategories(String establishmentId, OperatingExpenseType type) =>
      _repository.getCategories(establishmentId: establishmentId, type: type);

  /// Crea una categoria propia.
  Future<Result<OperatingExpenseCategory>> createCategory(
    String establishmentId,
    OperatingExpenseType type,
    String name,
  ) {
    if (name.trim().isEmpty) {
      const error = OperatingExpenseValidationError.requiredCategoryName;
      return Future.value(
        const Result.failure(
          DomainException(
            message: 'requiredCategoryName',
            code: DomainErrorCode.validation,
            reason: error,
          ),
        ),
      );
    }
    return _repository.createCategory(
      establishmentId: establishmentId,
      type: type,
      name: name,
    );
  }
}
