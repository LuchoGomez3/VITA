import 'dart:math' as math;

import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard_source.dart';

/// Aplica las reglas productivas del tablero sobre una fotografia local.
class HomeDashboardCalculator {
  /// Crea el servicio de dominio sin dependencias de infraestructura.
  const HomeDashboardCalculator();

  /// Calcula los indicadores para [now].
  HomeDashboard calculate(HomeDashboardSource source, DateTime now) {
    final activeAnimals = source.animals
        .where(
          (animal) => animal.deletedAt == null && animal.productiveStatus.isInProductiveStock,
        )
        .toList();
    final weighingsByAnimal = _groupWeighingsByAnimal(source.weighings);
    final currentWeights = <String, double>{};
    final dailyGains = <double>[];

    for (final animal in activeAnimals) {
      final observations = _weightObservations(
        animal,
        weighingsByAnimal[animal.id] ?? const [],
      );
      if (observations.isNotEmpty) {
        currentWeights[animal.id] = observations.last.weightKg;
      }
      final dailyGain = _dailyGain(observations);
      if (dailyGain != null) dailyGains.add(dailyGain);
    }

    return HomeDashboard(
      activeAnimals: activeAnimals.length,
      monthlyAdditions: source.animals.where((animal) => _isSameMonth(animal.createdAt, now)).length,
      monthlyRemovals: source.animals
          .where(
            (animal) =>
                animal.productiveStatus.isProductiveRemoval && _isSameMonth(animal.productiveStatusChangedAt, now),
          )
          .length,
      knownLiveWeightKg: currentWeights.values.fold(
        0,
        (total, weight) => total + weight,
      ),
      animalsWithCurrentWeight: currentWeights.length,
      averageDailyGainKg: dailyGains.isEmpty ? null : dailyGains.reduce((a, b) => a + b) / dailyGains.length,
      animalsWithDailyGain: dailyGains.length,
      categories: _categoryMetrics(
        activeAnimals,
        source.categoryNamesById,
      ),
      lots: _lotMetrics(activeAnimals, currentWeights),
      operatingExpensesCents: source.operatingExpensesCents,
    );
  }

  Map<String, List<HomeDashboardWeighing>> _groupWeighingsByAnimal(
    List<HomeDashboardWeighing> weighings,
  ) {
    final grouped = <String, List<HomeDashboardWeighing>>{};
    for (final weighing in weighings) {
      grouped.putIfAbsent(weighing.animalId, () => []).add(weighing);
    }
    return grouped;
  }

  List<_WeightObservation> _weightObservations(
    HomeDashboardAnimal animal,
    List<HomeDashboardWeighing> weighings,
  ) {
    final observations = <_WeightObservation>[];
    final initialWeight = animal.initialWeightKg;
    if (initialWeight != null && initialWeight > 0) {
      observations.add(
        _WeightObservation(
          date: animal.initialWeighingDate,
          weightKg: initialWeight,
        ),
      );
    }
    observations
      ..addAll(
        weighings
            .where((weighing) => weighing.weightKg > 0)
            .map(
              (weighing) => _WeightObservation(
                date: weighing.date,
                weightKg: weighing.weightKg,
              ),
            ),
      )
      ..sort((a, b) => a.date.compareTo(b.date));
    return observations;
  }

  double? _dailyGain(List<_WeightObservation> observations) {
    if (observations.length < 2) return null;
    final previous = observations[observations.length - 2];
    final current = observations.last;
    final elapsedDays = current.date.difference(previous.date).inMinutes / Duration.minutesPerDay;
    if (elapsedDays <= 0) return null;
    return (current.weightKg - previous.weightKg) / elapsedDays;
  }

  List<CategoryInventoryMetric> _categoryMetrics(
    List<HomeDashboardAnimal> animals,
    Map<String, String> categoryNamesById,
  ) {
    final counts = <String?, int>{};
    for (final animal in animals) {
      final name = _categoryName(animal, categoryNamesById);
      counts.update(name, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts.entries
        .map(
          (entry) => CategoryInventoryMetric(
            name: entry.key,
            animals: entry.value,
            percentage: animals.isEmpty ? 0 : entry.value / animals.length,
          ),
        )
        .toList()
      ..sort((a, b) {
        final countComparison = b.animals.compareTo(a.animals);
        return countComparison != 0 ? countComparison : _sortNullableNames(a.name, b.name);
      });
  }

  String? _categoryName(
    HomeDashboardAnimal animal,
    Map<String, String> categoryNamesById,
  ) {
    final storedName = categoryNamesById[animal.categoryId]?.trim();
    if (storedName != null && storedName.isNotEmpty) return storedName;
    final localName = animal.categoryName.trim();
    return localName.isEmpty ? null : localName;
  }

  List<LotWeightMetric> _lotMetrics(
    List<HomeDashboardAnimal> animals,
    Map<String, double> currentWeights,
  ) {
    final animalsByLot = <String?, List<HomeDashboardAnimal>>{};
    for (final animal in animals) {
      final trimmedLotName = animal.lotName.trim();
      final name = trimmedLotName.isEmpty ? null : trimmedLotName;
      animalsByLot.putIfAbsent(name, () => []).add(animal);
    }

    return animalsByLot.entries.map((entry) {
      final weights = entry.value.map((animal) => currentWeights[animal.id]).whereType<double>().toList();
      final average = weights.isEmpty ? 0.0 : weights.reduce((a, b) => a + b) / weights.length;
      final variance = weights.isEmpty
          ? 0.0
          : weights.map((weight) => math.pow(weight - average, 2)).reduce((a, b) => a + b) / weights.length;
      return LotWeightMetric(
        name: entry.key,
        animals: entry.value.length,
        animalsWithWeight: weights.length,
        averageWeightKg: average,
        weightStandardDeviationKg: math.sqrt(variance),
      );
    }).toList()..sort((a, b) => _sortNullableNames(a.name, b.name));
  }

  bool _isSameMonth(DateTime? value, DateTime reference) =>
      value != null && value.year == reference.year && value.month == reference.month;

  int _sortNullableNames(String? left, String? right) => (left ?? '').compareTo(right ?? '');
}

class _WeightObservation {
  const _WeightObservation({required this.date, required this.weightKg});

  final DateTime date;
  final double weightKg;
}
