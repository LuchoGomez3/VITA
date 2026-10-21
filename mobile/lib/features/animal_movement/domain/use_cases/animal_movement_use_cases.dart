import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';

/// Historial de potreros de un animal.
class GetAnimalMovementHistoryUseCase {
  /// Crea el caso de uso.
  const GetAnimalMovementHistoryUseCase(this._repository);

  final AnimalMovementRepository _repository;

  /// Devuelve el historial de [animalId].
  Future<Result<List<MovementHistoryEntry>>> call(String animalId) => _repository.getHistory(animalId);
}

/// Carga los animales con los que se abre "Mover animales" (uno desde la ficha
/// o varios desde el lector de caravanas) y los potreros de su campo.
class PrepareGroupMovementUseCase {
  /// Crea el caso de uso.
  const PrepareGroupMovementUseCase(this._repository);

  final AnimalMovementRepository _repository;

  /// Devuelve los animales iniciales y los destinos posibles. Tienen que ser
  /// todos del mismo establecimiento: un potrero es de un solo campo.
  Future<Result<({List<MovementAnimal> animals, List<MovementDestination> destinations})>> call(
    List<String> animalIds,
  ) async {
    final animals = <MovementAnimal>[];
    for (final animalId in animalIds.toSet()) {
      final animalResult = await _repository.getAnimal(animalId);
      if (animalResult is Failure<MovementAnimal?>) {
        return Result.failure(animalResult.error);
      }
      final animal = (animalResult as Success<MovementAnimal?>).data;
      if (animal == null) {
        return const Result.failure(
          DomainException(
            message: 'Uno de los animales no se puede mover: no está activo o no tiene potrero.',
            code: DomainErrorCode.validation,
          ),
        );
      }
      animals.add(animal);
    }
    if (animals.isEmpty) {
      return const Result.failure(
        DomainException(message: 'Agregá al menos un animal.', code: DomainErrorCode.validation),
      );
    }
    if (animals.any((animal) => animal.establishmentId != animals.first.establishmentId)) {
      return const Result.failure(
        DomainException(
          message: 'Los animales son de establecimientos distintos: los potreros son de un solo campo.',
          code: DomainErrorCode.validation,
        ),
      );
    }
    final destinations = await _repository.getDestinations(animals.first.establishmentId);
    return switch (destinations) {
      Success(:final data) => Result.success((animals: animals, destinations: data)),
      Failure(:final error) => Result.failure(error),
      _ => const Result.failure(DomainException(message: 'No se pudieron leer los potreros.')),
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
    required String establishmentId,
    required Set<String> selectedIds,
  }) async {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) {
      return const Result.failure(
        DomainException(message: 'Leé o escribí una caravana.', code: DomainErrorCode.validation),
      );
    }
    final found = await _repository.findAnimalByTag(trimmed);
    if (found is Failure<MovementAnimal?>) {
      return Result.failure(found.error);
    }
    final animal = (found as Success<MovementAnimal?>).data;
    if (animal == null) {
      return Result.failure(
        DomainException(
          message: 'No hay ningún animal activo con la caravana $trimmed en el celular.',
          code: DomainErrorCode.notFound,
        ),
      );
    }
    if (animal.establishmentId != establishmentId) {
      return const Result.failure(
        DomainException(
          message: 'Ese animal es de otro establecimiento: los potreros son de un solo campo.',
          code: DomainErrorCode.validation,
        ),
      );
    }
    if (selectedIds.contains(animal.id)) {
      return Result.failure(
        DomainException(
          message: 'La caravana ${animal.visualTag} ya está en la lista.',
          code: DomainErrorCode.conflict,
        ),
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
      return const Result.failure(
        DomainException(message: 'Agregá al menos un animal.', code: DomainErrorCode.validation),
      );
    }
    if (reason.trim().isEmpty) {
      return const Result.failure(
        DomainException(message: 'Ingresá el motivo del movimiento.', code: DomainErrorCode.validation),
      );
    }

    final bySourceLot = <String, List<String>>{};
    var alreadyThere = 0;
    for (final animal in animals) {
      if (animal.lotId == destinationLotId) {
        alreadyThere++;
        continue;
      }
      bySourceLot.putIfAbsent(animal.lotId, () => []).add(animal.id);
    }
    if (bySourceLot.isEmpty) {
      return const Result.failure(
        DomainException(
          message: 'Todos los animales ya están en ese potrero.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    var moved = 0;
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
          moved == 0
              ? result.error
              : DomainException(
                  message:
                      'Se movieron $moved animales, pero el resto no: ${result.error.message} '
                      'Revisá la lista y volvé a intentar con los que faltan.',
                  code: result.error.code,
                ),
        );
      }
      moved += animalIds.length;
    }
    return Result.success(GroupMovementSummary(movedCount: moved, alreadyThereCount: alreadyThere));
  }
}
