import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/errors/movement_failure.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/strings/animal_movement_strings.dart';

void main() {
  test('cada motivo funcional tiene un mensaje de presentación', () {
    final cases = <MovementFailure, String>{
      const MovementFailure.animalUnavailable(): AnimalMovementStrings.animalUnavailable,
      const MovementFailure.tagRequired(): AnimalMovementStrings.tagRequired,
      const MovementFailure.tagNotFound('123'): AnimalMovementStrings.tagNotFound('123'),
      const MovementFailure.ambiguousTag('123'): AnimalMovementStrings.ambiguousTag('123'),
      const MovementFailure.differentEstablishment(): AnimalMovementStrings.differentEstablishment,
      const MovementFailure.alreadySelected('001'): AnimalMovementStrings.alreadySelected('001'),
      const MovementFailure.animalsRequired(): AnimalMovementStrings.animalsRequired,
      const MovementFailure.reasonRequired(): AnimalMovementStrings.reasonRequired,
      const MovementFailure.destinationRequired(): AnimalMovementStrings.chooseDestination,
      const MovementFailure.allAlreadyThere(): AnimalMovementStrings.allAlreadyThere,
      const MovementFailure.localRead(MovementReadTarget.animal): AnimalMovementStrings.animalReadError,
      const MovementFailure.localRead(MovementReadTarget.tag): AnimalMovementStrings.tagReadError,
      const MovementFailure.localRead(MovementReadTarget.destinations): AnimalMovementStrings.destinationsReadError,
      const MovementFailure.localRead(MovementReadTarget.history): AnimalMovementStrings.historyReadError,
    };

    for (final MapEntry(key: reason, value: message) in cases.entries) {
      final error = movementException(reason);
      expect(AnimalMovementStrings.errorMessage(error), message, reason: '$reason');
      expect(error.message, 'animal_movement_failure');
    }
  });

  test('el resultado parcial conserva cantidad y causa sin exponer el mensaje técnico', () {
    const cause = DomainException(message: 'sqlite_driver_error', code: DomainErrorCode.offline);
    final error = movementException(const MovementFailure.partial(1, cause), code: cause.code);

    final message = AnimalMovementStrings.errorMessage(error);

    expect(message, AnimalMovementStrings.partialFailure(1, AnimalMovementStrings.saveError));
    expect(message, isNot(contains(cause.message)));
    expect((error.reason! as MovementPartialFailure).cause, cause);
  });

  test('los errores heredados se traducen por código y no por su texto', () {
    expect(
      AnimalMovementStrings.errorMessage(
        const DomainException(message: 'internal_conflict', code: DomainErrorCode.conflict),
      ),
      AnimalMovementStrings.movementConflict,
    );
    expect(
      AnimalMovementStrings.errorMessage(const DomainException(message: 'unknown_technical_error')),
      AnimalMovementStrings.saveError,
    );
    expect(
      AnimalMovementStrings.errorMessage(
        const DomainException(message: 'invalid_destination', code: DomainErrorCode.validation),
      ),
      AnimalMovementStrings.destinationUnavailable,
    );
  });
}
