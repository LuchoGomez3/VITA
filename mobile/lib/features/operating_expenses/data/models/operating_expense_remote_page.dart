import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';

/// Respuesta remota tipada antes de reconciliarla con SQLite.
class OperatingExpenseRemotePage {
  /// Crea una pagina con total central exacto y modelos sincronizados.
  const OperatingExpenseRemotePage({
    required this.expenses,
    required this.totalCents,
  });

  /// Registros devueltos por el backend, incluidos tombstones solicitados.
  final List<BrickOperatingExpenseModel> expenses;

  /// Total consolidado informado por `meta.total_egresos`.
  final int totalCents;
}

/// Tipo y categorias devueltos por el catalogo central.
class OperatingExpenseRemoteCatalogType {
  /// Crea un grupo del catalogo.
  const OperatingExpenseRemoteCatalogType({
    required this.type,
    required this.categories,
  });

  /// Clasificacion contable del grupo.
  final OperatingExpenseType type;

  /// Categorias base y personalizadas del backend.
  final List<OperatingExpenseCategory> categories;
}
