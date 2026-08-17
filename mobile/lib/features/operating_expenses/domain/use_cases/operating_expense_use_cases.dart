import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/repositories/operating_expense_repository.dart';

/// Mensajes funcionales cuya redaccion forma parte de los criterios.
class OperatingExpenseValidationMessages {
  const OperatingExpenseValidationMessages._();
  static const invalidAmount = 'El monto ingresado debe ser un valor mayor a cero';
  static const futureDate = 'No se pueden registrar egresos con fecha futura';
  static const requiredSupply = 'El insumo es obligatorio';
  static const requiredCategory = 'La categoría es obligatoria';
  static const incompatibleCategory = 'La categoría no corresponde al tipo de egreso seleccionado';
}

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
    if (error != null) return Future.value(Result.failure(DomainException(message: error)));
    return _repository.createExpense(expense);
  }

  /// Devuelve el primer error respetando el orden visual del formulario.
  String? validate({
    required OperatingExpense expense,
    required List<OperatingExpenseCategory> categories,
    required DateTime today,
  }) {
    if (expense.amountCents <= 0) return OperatingExpenseValidationMessages.invalidAmount;
    if (expense.category.trim().isEmpty) return OperatingExpenseValidationMessages.requiredCategory;
    final matches = categories.any((item) => item.value == expense.category && item.type == expense.type);
    if (!matches) return OperatingExpenseValidationMessages.incompatibleCategory;
    if (expense.supply.trim().isEmpty) return OperatingExpenseValidationMessages.requiredSupply;
    final selected = DateTime(expense.date.year, expense.date.month, expense.date.day);
    final maximum = DateTime(today.year, today.month, today.day);
    if (selected.isAfter(maximum)) return OperatingExpenseValidationMessages.futureDate;
    return null;
  }
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
  ) => _repository.createCategory(establishmentId: establishmentId, type: type, name: name);
}
