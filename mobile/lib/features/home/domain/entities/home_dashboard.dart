import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_dashboard.freezed.dart';

/// Resumen productivo calculado con la informacion offline disponible.
@freezed
sealed class HomeDashboard with _$HomeDashboard {
  /// Crea el conjunto de indicadores visibles en Inicio.
  const factory HomeDashboard({
    required int activeAnimals,
    required int monthlyAdditions,
    required int monthlyRemovals,
    required double knownLiveWeightKg,
    required int animalsWithCurrentWeight,
    required int animalsWithDailyGain,
    required List<CategoryInventoryMetric> categories,
    required List<LotWeightMetric> lots,
    @Default(0) int operatingExpensesCents,

    /// Importe pactado de las ventas vigentes, incluidas las pendientes de cobro.
    @Default(0) int salesRevenueCents,
    double? averageDailyGainKg,
  }) = _HomeDashboard;

  const HomeDashboard._();

  /// Balance de operaciones registradas: ventas menos gastos, en centavos.
  ///
  /// No representa caja disponible: una venta pendiente ya integra el ingreso
  /// comercial, aunque todavía no se haya recibido su dinero.
  int get operatingBalanceCents => salesRevenueCents - operatingExpensesCents;
}

/// Distribucion del inventario activo para una categoria productiva.
@freezed
sealed class CategoryInventoryMetric with _$CategoryInventoryMetric {
  /// Crea la participacion de una categoria dentro del stock.
  const factory CategoryInventoryMetric({
    required String? name,
    required int animals,
    required double percentage,
  }) = _CategoryInventoryMetric;
}

/// Peso actual y dispersion de los animales pertenecientes a un lote.
@freezed
sealed class LotWeightMetric with _$LotWeightMetric {
  /// Crea los indicadores de peso calculados para un lote.
  const factory LotWeightMetric({
    required String? name,
    required int animals,
    required int animalsWithWeight,
    required double averageWeightKg,
    required double weightStandardDeviationKg,
  }) = _LotWeightMetric;
}
