import 'package:meta/meta.dart';

/// Cómo se obtuvo el peso.
enum AnimalWeighingSource {
  /// Ingresado a mano.
  manual,

  /// Leído de una balanza Bluetooth.
  bluetoothScale,
}

/// Un pesaje de un animal, listo para guardar.
@immutable
class AnimalWeighing {
  /// Crea el pesaje.
  const AnimalWeighing({
    required this.id,
    required this.establishmentId,
    required this.animalId,
    required this.weightKg,
    required this.date,
    required this.source,
  });

  /// UUID generado en el celular (offline-first).
  final String id;

  /// Establecimiento del animal.
  final String establishmentId;

  /// Animal pesado.
  final String animalId;

  /// Peso en kilogramos.
  final double weightKg;

  /// Momento del pesaje.
  final DateTime date;

  /// Origen del peso.
  final AnimalWeighingSource source;
}
