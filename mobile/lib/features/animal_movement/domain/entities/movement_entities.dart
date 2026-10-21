import 'package:meta/meta.dart';

/// Animal que se puede mover: está activo, no fue borrado y está en un potrero.
@immutable
class MovementAnimal {
  /// Crea el animal.
  const MovementAnimal({
    required this.id,
    required this.establishmentId,
    required this.visualTag,
    required this.rfidTagNumber,
    required this.breed,
    required this.categoryName,
    required this.lotId,
    required this.lotName,
  });

  /// Id local (UUID de cliente).
  final String id;

  /// Establecimiento al que pertenece.
  final String establishmentId;

  /// Caravana visual.
  final String visualTag;

  /// RFID de 15 dígitos.
  final String rfidTagNumber;

  /// Raza.
  final String breed;

  /// Categoría (vacía si no se conoce).
  final String categoryName;

  /// Potrero actual.
  final String lotId;

  /// Nombre del potrero actual (vacío si no se conoce).
  final String lotName;

  @override
  bool operator ==(Object other) => other is MovementAnimal && other.id == id && other.lotId == lotId;

  @override
  int get hashCode => Object.hash(id, lotId);
}

/// Potrero al que se pueden mover animales.
@immutable
class MovementDestination {
  /// Crea el potrero.
  const MovementDestination({required this.id, required this.name, required this.animalCount});

  /// Id del lote.
  final String id;

  /// Nombre visible.
  final String name;

  /// Animales que tiene ahora.
  final int animalCount;

  @override
  bool operator ==(Object other) =>
      other is MovementDestination && other.id == id && other.name == name && other.animalCount == animalCount;

  @override
  int get hashCode => Object.hash(id, name, animalCount);
}

/// Un paso del historial de potreros de un animal.
@immutable
class MovementHistoryEntry {
  /// Crea la entrada.
  const MovementHistoryEntry({
    required this.movementId,
    required this.fromLotName,
    required this.toLotName,
    required this.occurredAt,
    required this.reason,
    required this.isPending,
  });

  /// Id del movimiento.
  final String movementId;

  /// Potrero de origen; `null` en la primera asignación.
  final String? fromLotName;

  /// Potrero de destino.
  final String toLotName;

  /// Cuándo se movió.
  final DateTime occurredAt;

  /// Motivo cargado.
  final String reason;

  /// Si todavía no llegó al servidor.
  final bool isPending;
}

/// Resultado de registrar un movimiento de varios animales.
@immutable
class GroupMovementSummary {
  /// Crea el resumen.
  const GroupMovementSummary({required this.movedCount, required this.alreadyThereCount});

  /// Animales que cambiaron de potrero.
  final int movedCount;

  /// Animales que ya estaban en el potrero de destino (no se tocan).
  final int alreadyThereCount;
}
