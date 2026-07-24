import 'dart:convert';
import 'dart:math' as math;

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';

/// Calcula KPIs de Inicio a partir de animales y pesajes guardados en SQLite.
class HomeDashboardRepositoryImpl implements HomeDashboardRepository {
  /// Crea el repositorio con los stores offline-first necesarios.
  HomeDashboardRepositoryImpl({
    required AnimalBrickStore animalStore,
    required CategoriaBrickStore categoryStore,
    required PesajeBrickStore pesajeStore,
    required SecureStorageService secureStorage,
    DateTime Function()? now,
  }) : _animalStore = animalStore,
       _categoryStore = categoryStore,
       _pesajeStore = pesajeStore,
       _secureStorage = secureStorage,
       _now = now ?? DateTime.now;

  final AnimalBrickStore _animalStore;
  final CategoriaBrickStore _categoryStore;
  final PesajeBrickStore _pesajeStore;
  final SecureStorageService _secureStorage;
  final DateTime Function() _now;

  @override
  Future<Result<HomeDashboard>> getDashboard({
    Set<String>? establishmentIds,
  }) async {
    try {
      final storedAnimals = await _animalStore.getLocalAnimals();
      final animals = establishmentIds == null
          ? storedAnimals
          : storedAnimals
                .where(
                  (animal) =>
                      establishmentIds.contains(animal.establishmentId),
                )
                .toList();
      final weighings = await _pesajeStore.getLocalPesajes();
      final categories = await _getCategoriesForAnimals(animals);
      return Result.success(
        _calculateDashboard(animals, weighings, categories),
      );
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudieron calcular los indicadores productivos.',
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, String>>> getEstablishments() async {
    try {
      final encoded = await _secureStorage.read(
        SecureStorageKeys.establishmentCatalog,
      );
      if (encoded == null || encoded.isEmpty) {
        return const Result.success({});
      }

      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        throw const FormatException('Invalid establishment catalog.');
      }

      final establishments = <String, String>{};
      for (final item in decoded.whereType<Map<String, dynamic>>()) {
        final id = item['id'];
        final name = item['name'];
        if (id is String && name is String) {
          establishments[id] = name;
        }
      }
      return Result.success(establishments);
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudieron leer los establecimientos disponibles.',
        ),
      );
    }
  }

  HomeDashboard _calculateDashboard(
    List<BrickAnimalModel> animals,
    List<BrickPesajeModel> weighings,
    List<BrickCategoriaModel> categories,
  ) {
    // El tablero trabaja únicamente con animales vigentes. Las altas y bajas
    // mensuales sí se calculan sobre el historial completo para no perder los
    // movimientos que ocurrieron dentro del mes consultado.
    final now = _now();
    final activeAnimals = animals.where((animal) => animal.deletedAt == null).toList();
    final weighingsByAnimal = _groupWeighingsByAnimal(weighings);
    final currentWeights = <String, double>{};
    final dailyGains = <double>[];

    for (final animal in activeAnimals) {
      final observations = _weightObservations(
        animal,
        weighingsByAnimal[animal.localId] ?? const [],
      );
      if (observations.isNotEmpty) {
        currentWeights[animal.localId] = observations.last.weightKg;
      }
      final dailyGain = _dailyGain(observations);
      if (dailyGain != null) {
        dailyGains.add(dailyGain);
      }
    }

    return HomeDashboard(
      activeAnimals: activeAnimals.length,
      monthlyAdditions: animals.where((animal) => _isSameMonth(animal.createdAt, now)).length,
      monthlyRemovals: animals.where((animal) => _isSameMonth(animal.deletedAt, now)).length,
      knownLiveWeightKg: currentWeights.values.fold(0, (total, weight) => total + weight),
      animalsWithCurrentWeight: currentWeights.length,
      averageDailyGainKg: dailyGains.isEmpty ? null : dailyGains.reduce((a, b) => a + b) / dailyGains.length,
      animalsWithDailyGain: dailyGains.length,
      categories: _categoryMetrics(activeAnimals, categories),
      lots: _lotMetrics(activeAnimals, currentWeights),
    );
  }

  Map<String, List<BrickPesajeModel>> _groupWeighingsByAnimal(
    List<BrickPesajeModel> weighings,
  ) {
    final grouped = <String, List<BrickPesajeModel>>{};
    for (final weighing in weighings) {
      grouped.putIfAbsent(weighing.animalId, () => []).add(weighing);
    }
    return grouped;
  }

  List<_WeightObservation> _weightObservations(
    BrickAnimalModel animal,
    List<BrickPesajeModel> weighings,
  ) {
    // El peso inicial forma parte de la misma serie temporal que los pesajes
    // posteriores. Ordenar la serie permite elegir de forma segura tanto el
    // peso vigente como las dos últimas mediciones usadas para calcular GPD.
    final observations = <_WeightObservation>[];
    final initialWeight = animal.initialWeight;
    if (initialWeight != null && initialWeight > 0) {
      observations.add(
        _WeightObservation(date: animal.weighingDate, weightKg: initialWeight),
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
    if (observations.length < 2) {
      return null;
    }

    final previous = observations[observations.length - 2];
    final current = observations.last;
    // Se usan minutos convertidos a días para conservar precisión cuando dos
    // mediciones no están separadas por una cantidad entera de jornadas.
    final elapsedDays = current.date.difference(previous.date).inMinutes / Duration.minutesPerDay;
    if (elapsedDays <= 0) {
      return null;
    }

    return (current.weightKg - previous.weightKg) / elapsedDays;
  }

  List<CategoryInventoryMetric> _categoryMetrics(
    List<BrickAnimalModel> animals,
    List<BrickCategoriaModel> categories,
  ) {
    final categoryNamesById = {
      for (final category in categories) category.localId: category.name,
    };
    final counts = <String, int>{};
    for (final animal in animals) {
      final name = _categoryName(animal, categoryNamesById);
      counts.update(name, (count) => count + 1, ifAbsent: () => 1);
    }

    final metrics =
        counts.entries
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
            return countComparison != 0 ? countComparison : a.name.compareTo(b.name);
          });
    return metrics;
  }

  Future<List<BrickCategoriaModel>> _getCategoriesForAnimals(
    List<BrickAnimalModel> animals,
  ) async {
    final establishmentIds = animals
        .map((animal) => animal.establishmentId)
        .toSet();
    final categoriesByEstablishment = await Future.wait(
      establishmentIds.map(_categoryStore.getLocalCategorias),
    );

    return categoriesByEstablishment.expand((categories) => categories).toList();
  }

  String _categoryName(
    BrickAnimalModel animal,
    Map<String, String> categoryNamesById,
  ) {
    final storedName = categoryNamesById[animal.categoryId]?.trim();
    if (storedName != null && storedName.isNotEmpty) {
      return storedName;
    }

    final localName = animal.categoryName.trim();
    return localName.isEmpty ? 'Sin categoría' : localName;
  }

  List<LotWeightMetric> _lotMetrics(
    List<BrickAnimalModel> animals,
    Map<String, double> currentWeights,
  ) {
    final animalsByLot = <String, List<BrickAnimalModel>>{};
    for (final animal in animals) {
      final name = animal.lotName.trim().isEmpty ? 'Sin lote' : animal.lotName.trim();
      animalsByLot.putIfAbsent(name, () => []).add(animal);
    }

    final metrics = animalsByLot.entries.map((entry) {
      final weights = entry.value.map((animal) => currentWeights[animal.localId]).whereType<double>().toList();
      final average = weights.isEmpty ? 0.0 : weights.reduce((a, b) => a + b) / weights.length;
      // La desviación estándar poblacional expresa qué tan uniforme es el
      // lote completo: un valor bajo indica pesos cercanos al promedio.
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
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
    return metrics;
  }

  bool _isSameMonth(DateTime? value, DateTime reference) {
    return value != null && value.year == reference.year && value.month == reference.month;
  }
}

class _WeightObservation {
  const _WeightObservation({required this.date, required this.weightKg});

  final DateTime date;
  final double weightKg;
}
