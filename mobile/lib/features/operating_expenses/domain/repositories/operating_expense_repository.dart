import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';

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

  /// Lee SQLite y aplica los filtros sin depender de conectividad.
  Future<Result<OperatingExpenseHistory>> getLocalHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  });

  /// Actualiza el cache central y combina los pendientes locales sin duplicar.
  Future<Result<OperatingExpenseHistory>> refreshHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  });

  /// Reconcilia el catalogo central con el catalogo base y local.
  Future<Result<List<OperatingExpenseCategory>>> refreshCategories({
    required String establishmentId,
  });

  /// Descarga el CSV generado centralmente con los filtros exactos.
  Future<Result<OperatingExpenseExport>> exportHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  });
}
