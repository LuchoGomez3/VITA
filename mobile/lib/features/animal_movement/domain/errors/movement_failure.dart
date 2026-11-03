import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';

part 'movement_failure.freezed.dart';

/// Recurso cuya lectura local falló, sin detalles de Brick o SQLite.
enum MovementReadTarget {
  /// Animal con el que se inicia el traslado.
  animal,

  /// Identificación por caravana visual o electrónica.
  tag,

  /// Potreros de destino del establecimiento.
  destinations,

  /// Historial de ubicaciones.
  history,
}

/// Motivos funcionales que presentación traduce a textos centralizados.
@freezed
sealed class MovementFailure with _$MovementFailure {
  /// El animal inicial no cumple las condiciones del traslado.
  const factory MovementFailure.animalUnavailable() = MovementAnimalUnavailable;

  /// No se recibió una identificación.
  const factory MovementFailure.tagRequired() = MovementTagRequired;

  /// El ingreso RFID no contiene exactamente quince números.
  const factory MovementFailure.invalidRfid() = MovementInvalidRfid;

  /// No existe una coincidencia local para la identificación.
  const factory MovementFailure.tagNotFound(String tag) = MovementTagNotFound;

  /// La identificación no permite elegir un único animal del establecimiento.
  const factory MovementFailure.ambiguousTag(String tag) = MovementAmbiguousTag;

  /// El animal identificado pertenece a otro establecimiento.
  const factory MovementFailure.differentEstablishment() = MovementDifferentEstablishment;

  /// La selección ya contiene al animal identificado.
  const factory MovementFailure.alreadySelected(String visualTag) = MovementAlreadySelected;

  /// La selección no contiene animales.
  const factory MovementFailure.animalsRequired() = MovementAnimalsRequired;

  /// Falta el motivo operativo.
  const factory MovementFailure.reasonRequired() = MovementReasonRequired;

  /// Falta elegir el potrero de destino.
  const factory MovementFailure.destinationRequired() = MovementDestinationRequired;

  /// La selección completa ya está en el destino.
  const factory MovementFailure.allAlreadyThere() = MovementAllAlreadyThere;

  /// Falló el acceso al recurso local indicado.
  const factory MovementFailure.localRead(MovementReadTarget target) = MovementLocalReadFailure;

  /// Algunos grupos fueron persistidos antes de fallar otro origen.
  const factory MovementFailure.partial(
    int movedCount,
    DomainException cause, {
    @Default([]) List<String> movedAnimalIds,
  }) = MovementPartialFailure;
}

/// Envuelve un motivo tipado sin incorporar lenguaje de producto al dominio.
DomainException movementException(
  MovementFailure reason, {
  DomainErrorCode code = DomainErrorCode.validation,
}) => DomainException(message: 'animal_movement_failure', code: code, reason: reason);
