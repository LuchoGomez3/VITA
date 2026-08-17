import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';

/// Contrato de dominio para egresos y sus categorias offline-first.
abstract class OperatingExpenseRepository {
  /// Guarda localmente y devuelve el estado alcanzado al esperar al backend.
  Future<Result<OperatingExpense>> createExpense(OperatingExpense expense);

  /// Crea una categoria propia, visible inmediatamente.
  Future<Result<OperatingExpenseCategory>> createCategory({
    required String establishmentId,
    required OperatingExpenseType type,
    required String name,
  });

  /// Obtiene el catalogo local correspondiente al contexto activo.
  Future<Result<List<OperatingExpenseCategory>>> getCategories({
    required String establishmentId,
    required OperatingExpenseType type,
  });
}
