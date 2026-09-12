import 'package:freezed_annotation/freezed_annotation.dart';

part 'lot_animal_movement.freezed.dart';

/// Registro de dominio de un traslado entre dos lotes del mismo establecimiento.
@freezed
sealed class LotAnimalMovement with _$LotAnimalMovement {
  /// Crea un movimiento local auditable.
  const factory LotAnimalMovement({
    required String id,
    required String establishmentId,
    required String sourceLotId,
    required String destinationLotId,
    required List<String> animalIds,
    required DateTime occurredAt,
    required String reason,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? responsibleId,
    DateTime? deletedAt,
  }) = _LotAnimalMovement;
}
