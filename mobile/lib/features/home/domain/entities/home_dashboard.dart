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
    double? averageDailyGainKg,
  }) = _HomeDashboard;
}

/// Distribucion del inventario activo para una categoria productiva.
@freezed
sealed class CategoryInventoryMetric with _$CategoryInventoryMetric {
  /// Crea la participacion de una categoria dentro del stock.
  const factory CategoryInventoryMetric({
    required String name,
    required int animals,
    required double percentage,
  }) = _CategoryInventoryMetric;
}

/// Peso actual y dispersion de los animales pertenecientes a un lote.
@freezed
sealed class LotWeightMetric with _$LotWeightMetric {
  /// Crea los indicadores de peso calculados para un lote.
  const factory LotWeightMetric({
    required String name,
    required int animals,
    required int animalsWithWeight,
    required double averageWeightKg,
    required double weightStandardDeviationKg,
  }) = _LotWeightMetric;
}
