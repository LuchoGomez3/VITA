import 'package:freezed_annotation/freezed_annotation.dart';

part 'movement_entities.freezed.dart';

/// Animal activo con potrero que puede participar de un traslado.
@freezed
sealed class MovementAnimal with _$MovementAnimal {
  /// Conserva identidad, establecimiento y ubicación al preparar la selección.
  const factory MovementAnimal({
    required String id,
    required String establishmentId,
    required String visualTag,
    required String rfidTagNumber,
    required String breed,
    required String categoryName,
    required String lotId,
    required String lotName,
  }) = _MovementAnimal;
}

/// Potrero activo ofrecido como destino del traslado.
@freezed
sealed class MovementDestination with _$MovementDestination {
  /// Crea una opción con la cantidad local de animales.
  const factory MovementDestination({
    required String id,
    required String name,
    required int animalCount,
  }) = _MovementDestination;
}

/// Datos locales iniciales del movimiento, independientes de su presentación.
@freezed
sealed class GroupMovementPreparation with _$GroupMovementPreparation {
  /// Agrupa el animal inicial y los destinos de su establecimiento.
  const factory GroupMovementPreparation({
    required MovementAnimal animal,
    required List<MovementDestination> destinations,
  }) = _GroupMovementPreparation;
}

/// Un paso del historial de potreros de un animal.
@freezed
sealed class MovementHistoryEntry with _$MovementHistoryEntry {
  /// Crea la entrada; el origen es nulo en la primera asignación.
  const factory MovementHistoryEntry({
    required String movementId,
    required String? fromLotName,
    required String toLotName,
    required DateTime occurredAt,
    required String reason,
    required MovementSyncStatus syncStatus,

    /// Identifica la última llegada al potrero actual, sin inferirla del orden visible.
    @Default(false) bool isCurrent,
  }) = _MovementHistoryEntry;
}

/// Estado de confirmación del movimiento independiente de Brick.
enum MovementSyncStatus {
  /// Guardado localmente y pendiente de envío o reintento.
  pending,

  /// Confirmado por el servidor.
  synchronized,

  /// Rechazado definitivamente por una regla del servidor.
  rejected,
}

/// Resultado de registrar el traslado de una selección de animales.
@freezed
sealed class GroupMovementSummary with _$GroupMovementSummary {
  /// Distingue los trasladados de quienes ya estaban en el destino.
  const factory GroupMovementSummary({
    required int movedCount,
    required int alreadyThereCount,

    /// Destinos efectivamente usados, por UUID y nombre al registrar.
    @Default({}) Map<String, String> destinations,
  }) = _GroupMovementSummary;
}
