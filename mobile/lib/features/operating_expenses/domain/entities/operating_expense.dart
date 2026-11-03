import 'package:freezed_annotation/freezed_annotation.dart';

part 'operating_expense.freezed.dart';

/// Clasificacion contable admitida por el backend.
enum OperatingExpenseType {
  /// Costo directamente asociado a producir.
  productionCost('costo_produccion', 'Costo de Producción'),

  /// Gasto de administracion y estructura.
  administrativeExpense('gasto_administrativo', 'Gasto Administrativo');

  const OperatingExpenseType(this.value, this.label);

  /// Valor estable del contrato REST.
  final String value;

  /// Etiqueta visible.
  final String label;
}

/// Estado de sincronizacion expuesto al dominio.
enum OperatingExpenseSyncStatus { pending, synchronized, rejected }

/// Categoria seleccionable, predefinida o propia del establecimiento.
@freezed
sealed class OperatingExpenseCategory with _$OperatingExpenseCategory {
  /// Crea una opcion del catalogo.
  const factory OperatingExpenseCategory({
    required String value,
    required String label,
    required OperatingExpenseType type,
    @Default(false) bool custom,
    String? id,
  }) = _OperatingExpenseCategory;
}

/// Egreso operativo listo para presentar en formulario o historial.
@freezed
sealed class OperatingExpense with _$OperatingExpense {
  /// Crea el movimiento conservando el decimal como centavos enteros.
  const factory OperatingExpense({
    required String id,
    required String establishmentId,
    required int amountCents,
    required OperatingExpenseType type,
    required String category,
    required String supply,
    required DateTime date,
    required DateTime createdAt,
    required DateTime updatedAt,
    required OperatingExpenseSyncStatus syncStatus,
    String? categoryLabel,
    String? description,
    String? receiptNumber,
    String? loadedById,
    String? loadedByName,
    String? customCategoryId,
    String? syncErrorCode,
  }) = _OperatingExpense;
}
