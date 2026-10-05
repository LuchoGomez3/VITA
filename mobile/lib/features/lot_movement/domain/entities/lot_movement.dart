import 'package:freezed_annotation/freezed_annotation.dart';

part 'lot_movement.freezed.dart';

/// Estado de una operación, separado del estado productivo del animal.
enum MovementSyncStatus {
  /// Guardada en el dispositivo; espera confirmación del servidor.
  pending,

  /// Confirmada por el servidor.
  synchronized,

  /// Rechazada y conservada para revisión y reintento.
  rejected,
}

/// Animal seleccionable con su origen conocido en este dispositivo.
@freezed
sealed class MovementAnimal with _$MovementAnimal {
  /// Crea una opción sin tipos de infraestructura.
  const factory MovementAnimal({required String id, required String tag, required bool canMove, String? lotId}) =
      _MovementAnimal;
}

/// Destino activo perteneciente al establecimiento.
@freezed
sealed class MovementLot with _$MovementLot {
  /// Identidad y nombre necesarios para el selector y la confirmación.
  const factory MovementLot({required String id, required String name}) = _MovementLot;
}

/// Hecho histórico: su UUID y payload se conservan al reintentar.
@freezed
sealed class AnimalLotMovement with _$AnimalLotMovement {
  /// Crea una asignación inicial cuando sourceLotId es null, o un traslado.
  const factory AnimalLotMovement({
    required String id,
    required String establishmentId,
    required String destinationLotId,
    required List<String> animalIds,
    required DateTime occurredAt,
    required String reason,
    required DateTime createdAt,
    String? sourceLotId,
    @Default(MovementSyncStatus.pending) MovementSyncStatus syncStatus,
    String? syncErrorCode,
  }) = _AnimalLotMovement;
}

/// Catálogo y ubicaciones disponibles offline, más historial técnico visible.
@freezed
sealed class MovementContext with _$MovementContext {
  /// Conserva los lotes de origen aunque ya no estén activos para recibir animales.
  const factory MovementContext({
    required List<MovementAnimal> animals,
    required List<MovementLot> destinations,
    required List<MovementLot> origins,
    required List<AnimalLotMovement> history,
    @Default(false) bool usingCachedData,
  }) = _MovementContext;
}
