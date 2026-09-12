import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';

part 'operating_expense_history.freezed.dart';

/// Atajos de fecha disponibles en el historial financiero.
enum OperatingExpensePeriod { currentMonth, lastQuarter, custom, allHistory }

/// Filtros combinables del historial y la exportacion CSV.
@freezed
sealed class OperatingExpenseFilters with _$OperatingExpenseFilters {
  /// Crea filtros ya resueltos a fechas concretas para conservarlos al refrescar.
  const factory OperatingExpenseFilters({
    required OperatingExpensePeriod period,
    DateTime? from,
    DateTime? to,
    OperatingExpenseType? type,
    String? category,
  }) = _OperatingExpenseFilters;

  const OperatingExpenseFilters._();

  /// Filtro inicial: desde el primer dia del mes actual hasta hoy.
  factory OperatingExpenseFilters.initial(DateTime today) => OperatingExpenseFilters(
    period: OperatingExpensePeriod.currentMonth,
    from: DateTime(today.year, today.month),
    to: DateTime(today.year, today.month, today.day),
  );

  /// Indica si hay una clasificacion adicional al periodo inicial.
  bool get hasClassificationFilter => type != null || category != null;
}

/// Resultado consolidado que la UI puede mostrar aun cuando falle la red.
@freezed
sealed class OperatingExpenseHistory with _$OperatingExpenseHistory {
  /// Crea el historial visible y su total exacto en centavos.
  const factory OperatingExpenseHistory({
    required List<OperatingExpense> expenses,
    required int totalCents,
    required bool cachedWithoutConnection,
    @Default(0) int pendingCount,
    @Default(false) bool totalIncludesPending,
  }) = _OperatingExpenseHistory;
}

/// CSV generado por el backend con los filtros vigentes.
@freezed
sealed class OperatingExpenseExport with _$OperatingExpenseExport {
  /// Crea un archivo listo para compartir o guardar mediante la plataforma.
  const factory OperatingExpenseExport({
    required Uint8List bytes,
    required String filename,
    required String mediaType,
  }) = _OperatingExpenseExport;
}
