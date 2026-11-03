import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';

/// Catalogo base disponible offline mientras no se descargue desde el backend.
class OperatingExpenseCategoryCatalog {
  const OperatingExpenseCategoryCatalog._();

  /// Categorias canonicas reconocidas por el dominio para cada tipo de egreso.
  static const values = <OperatingExpenseCategory>[
    OperatingExpenseCategory(
      value: 'sanidad',
      label: 'Sanidad',
      type: OperatingExpenseType.productionCost,
    ),
    OperatingExpenseCategory(
      value: 'alimentacion',
      label: 'Alimentación',
      type: OperatingExpenseType.productionCost,
    ),
    OperatingExpenseCategory(
      value: 'identificacion',
      label: 'Identificación',
      type: OperatingExpenseType.productionCost,
    ),
    OperatingExpenseCategory(
      value: 'combustible',
      label: 'Combustible',
      type: OperatingExpenseType.administrativeExpense,
    ),
    OperatingExpenseCategory(
      value: 'estructura',
      label: 'Estructura',
      type: OperatingExpenseType.administrativeExpense,
    ),
    OperatingExpenseCategory(
      value: 'honorarios',
      label: 'Honorarios',
      type: OperatingExpenseType.administrativeExpense,
    ),
  ];

  /// Devuelve las categorias base correspondientes al tipo solicitado.
  static Iterable<OperatingExpenseCategory> forType(
    OperatingExpenseType type,
  ) => values.where((category) => category.type == type);
}
