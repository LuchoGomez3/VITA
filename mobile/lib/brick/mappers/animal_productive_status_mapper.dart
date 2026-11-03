import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';

/// Traduce el estado tecnico de Brick al concepto compartido de dominio.
extension BrickAnimalProductiveStatusMapper on BrickAnimalProductiveStatus {
  /// Convierte el valor persistido sin filtrar estados desconocidos.
  AnimalProductiveStatus toDomain() => switch (this) {
    BrickAnimalProductiveStatus.unknown => AnimalProductiveStatus.unknown,
    BrickAnimalProductiveStatus.active => AnimalProductiveStatus.active,
    BrickAnimalProductiveStatus.sold => AnimalProductiveStatus.sold,
    BrickAnimalProductiveStatus.dead => AnimalProductiveStatus.dead,
    BrickAnimalProductiveStatus.removed => AnimalProductiveStatus.removed,
  };
}
