import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/validators/rfid_validator.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_tag_kind.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/errors/movement_failure.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';

/// Carga los animales con los que se abre "Mover animales" (uno desde la ficha
/// o varios desde el lector de caravanas) y los potreros de su campo.
class PrepareGroupMovementUseCase {
  /// Crea el caso de uso.
  const PrepareGroupMovementUseCase(this._repository);

  final AnimalMovementRepository _repository;

  /// Devuelve los animales iniciales y los destinos posibles. Tienen que ser
  /// todos del mismo establecimiento: un potrero es de un solo campo.
  Future<Result<GroupMovementPreparation>> call(List<String> animalIds) async {
    final animals = <MovementAnimal>[];
    for (final animalId in animalIds.toSet()) {
      final animalResult = await _repository.getAnimal(animalId);
      if (animalResult is Failure<MovementAnimal?>) {
        return Result.failure(animalResult.error);
      }
      final animal = (animalResult as Success<MovementAnimal?>).data;
      if (animal == null) {
        return Result.failure(movementException(const MovementFailure.animalUnavailable()));
      }
      animals.add(animal);
    }
    if (animals.isEmpty) {
      return Result.failure(movementException(const MovementFailure.animalsRequired()));
    }
    final establishmentId = animals.first.establishmentId;
    if (animals.any((animal) => animal.establishmentId != establishmentId)) {
      return Result.failure(movementException(const MovementFailure.differentEstablishment()));
    }
    final destinations = await _repository.getDestinations(establishmentId);
    return switch (destinations) {
      Success(:final data) => Result.success(GroupMovementPreparation(animals: animals, destinations: data)),
      Failure(:final error) => Result.failure(error),
      _ => Result.failure(
        movementException(
          const MovementFailure.localRead(MovementReadTarget.destinations),
          code: DomainErrorCode.unknown,
        ),
      ),
    };
  }
}

/// Convierte una caravana leída (bastón o teclado) en un animal para la lista.
class ResolveMovementTagUseCase {
  /// Crea el caso de uso.
  const ResolveMovementTagUseCase(this._repository);

  final AnimalMovementRepository _repository;

  /// Valida que [tag] sea de un animal activo de [establishmentId] y que no
  /// esté ya en la lista ([selectedIds]).
  Future<Result<MovementAnimal>> call({
    required String tag,
    required MovementTagKind kind,
    required String establishmentId,
    required Set<String> selectedIds,
  }) async {
    final trimmed = kind == MovementTagKind.visual ? tag.trim() : tag;
    if (trimmed.isEmpty) {
      return Result.failure(movementException(const MovementFailure.tagRequired()));
    }
    if (kind == MovementTagKind.rfid && !RfidValidator.isValid(trimmed)) {
      return Result.failure(movementException(const MovementFailure.invalidRfid()));
    }
    final found = await _repository.findAnimalByTag(trimmed, establishmentId: establishmentId, kind: kind);
    if (found is Failure<MovementAnimal?>) {
      return Result.failure(found.error);
    }
    final animal = (found as Success<MovementAnimal?>).data;
    if (animal == null) {
      return Result.failure(
        movementException(MovementFailure.tagNotFound(trimmed), code: DomainErrorCode.notFound),
      );
    }
    if (animal.establishmentId != establishmentId) {
      return Result.failure(movementException(const MovementFailure.differentEstablishment()));
    }
    if (selectedIds.contains(animal.id)) {
      return Result.failure(
        movementException(MovementFailure.alreadySelected(animal.visualTag), code: DomainErrorCode.conflict),
      );
    }
    return Result.success(animal);
  }
}

/// Registra el movimiento de varios animales a un potrero.
///
/// Para el productor es un solo movimiento; el backend pide un lote de origen
/// por movimiento, así que si los animales vienen de potreros distintos se
/// guarda uno por cada potrero de origen, todos con la misma fecha y motivo.
class RegisterGroupMovementUseCase {
  /// Crea el caso de uso sobre el movimiento entre lotes existente.
  const RegisterGroupMovementUseCase(this._moveLotAnimals);

  final MoveLotAnimalsUseCase _moveLotAnimals;

  /// Mueve [animals] a [destinationLotId].
  Future<Result<GroupMovementSummary>> call({
    required String establishmentId,
    required List<MovementAnimal> animals,
    required String destinationLotId,
    required DateTime occurredAt,
    required String reason,
  }) async {
    if (animals.isEmpty) {
      return Result.failure(movementException(const MovementFailure.animalsRequired()));
    }
    if (reason.trim().isEmpty) {
      return Result.failure(movementException(const MovementFailure.reasonRequired()));
    }

    final bySourceLot = <String, List<String>>{};
    var alreadyThere = 0;
    final uniqueAnimals = {for (final animal in animals) animal.id: animal};
    for (final animal in uniqueAnimals.values) {
      if (animal.lotId == destinationLotId) {
        alreadyThere++;
        continue;
      }
      bySourceLot.putIfAbsent(animal.lotId, () => []).add(animal.id);
    }
    if (bySourceLot.isEmpty) {
      return Result.failure(movementException(const MovementFailure.allAlreadyThere()));
    }

    final movedIds = <String>[];
    for (final MapEntry(key: sourceLotId, value: animalIds) in bySourceLot.entries) {
      final result = await _moveLotAnimals(
        establishmentId: establishmentId,
        sourceLotId: sourceLotId,
        destinationLotId: destinationLotId,
        animalIds: animalIds,
        occurredAt: occurredAt,
        reason: reason,
      );
      if (result is Failure<LotAnimalMovement>) {
        return Result.failure(
          movedIds.isEmpty
              ? result.error
              : movementException(
                  MovementFailure.partial(movedIds.length, result.error, movedAnimalIds: movedIds),
                  code: result.error.code,
                ),
        );
      }
      movedIds.addAll(animalIds);
    }
    return Result.success(GroupMovementSummary(movedCount: movedIds.length, alreadyThereCount: alreadyThere));
  }
}
