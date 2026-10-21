import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';

/// Último pesaje válido de cada animal, por id local.
Map<String, BrickPesajeModel> latestWeighingByAnimal(Iterable<BrickPesajeModel> weighings) {
  final latest = <String, BrickPesajeModel>{};
  for (final weighing in weighings) {
    if (weighing.weightKg <= 0) {
      continue;
    }
    final current = latest[weighing.animalId];
    if (current == null || weighing.date.isAfter(current.date)) {
      latest[weighing.animalId] = weighing;
    }
  }
  return latest;
}

/// Último peso conocido de [animal]: el pesaje más reciente o, si es
/// anterior, el peso inicial del alta. Es la misma serie que usa el tablero
/// de Inicio.
({double? weightKg, DateTime? date}) latestKnownWeight(BrickAnimalModel animal, BrickPesajeModel? lastWeighing) {
  final initialWeight = animal.initialWeight;
  final hasInitialWeight = initialWeight != null && initialWeight > 0;
  final useWeighing = lastWeighing != null && (!hasInitialWeight || !lastWeighing.date.isBefore(animal.weighingDate));
  if (useWeighing) {
    return (weightKg: lastWeighing.weightKg, date: lastWeighing.date);
  }
  return hasInitialWeight ? (weightKg: initialWeight, date: animal.weighingDate) : (weightKg: null, date: null);
}
