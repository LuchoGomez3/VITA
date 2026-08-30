import 'dart:convert';

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_movement_repository.dart';
import 'package:logging/logging.dart';

/// Aplica el traslado en SQLite y conserva un registro auditable.
class LotAnimalMovementRepositoryImpl implements LotAnimalMovementRepository {
  /// Crea el repositorio con stores compartidos, sin depender de otra feature.
  const LotAnimalMovementRepositoryImpl({
    required AnimalBrickStore animalStore,
    required LotBrickStore lotStore,
    required BrickAnimalLotMovementStore movementStore,
  }) : _animalStore = animalStore,
       _lotStore = lotStore,
       _movementStore = movementStore;

  final AnimalBrickStore _animalStore;
  final LotBrickStore _lotStore;
  final BrickAnimalLotMovementStore _movementStore;
  static final _logger = Logger('LotAnimalMovementRepository');

  @override
  Future<Result<LotAnimalMovement>> moveAnimals(
    LotAnimalMovement movement,
  ) async {
    final originals = <BrickAnimalModel>[];
    try {
      final destination = await _lotStore.getLocalLot(movement.destinationLotId);
      if (destination == null) {
        return const Result.failure(
          DomainException(
            message: 'El lote de destino no está disponible en el dispositivo.',
            code: DomainErrorCode.notFound,
          ),
        );
      }
      final animals = await _animalStore.getLocalAnimals();
      final selected = animals.where(
        (animal) => movement.animalIds.contains(animal.localId),
      );
      if (selected.length != movement.animalIds.length ||
          selected.any(
            (animal) =>
                animal.deletedAt != null ||
                animal.establishmentId != movement.establishmentId ||
                animal.lotId != movement.sourceLotId,
          )) {
        return const Result.failure(
          DomainException(
            message: 'Uno de los animales ya no pertenece al lote de origen.',
            code: DomainErrorCode.conflict,
          ),
        );
      }

      originals.addAll(selected);
      for (final animal in originals) {
        await _animalStore.cacheAnimal(
          animal.copyWith(
            lotId: destination.localId,
            lotName: destination.name,
            updatedAt: movement.updatedAt,
            syncStatus: BrickAnimalSyncStatus.pending,
            syncErrorCode: null,
          ),
        );
      }
      await _movementStore.save(
        BrickAnimalLotMovementModel(
          localId: movement.id,
          establishmentId: movement.establishmentId,
          sourceLotId: movement.sourceLotId,
          destinationLotId: movement.destinationLotId,
          animalIdsJson: jsonEncode(movement.animalIds),
          occurredAt: movement.occurredAt,
          reason: movement.reason,
          responsibleId: movement.responsibleId,
          createdAt: movement.createdAt,
          updatedAt: movement.updatedAt,
          deletedAt: movement.deletedAt,
        ),
      );
      return Result.success(movement);
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudo completar el movimiento local.', error, stackTrace);
      for (final animal in originals) {
        try {
          await _animalStore.cacheAnimal(animal);
        } on Object catch (rollbackError, rollbackStackTrace) {
          _logger.severe(
            'No se pudo revertir un animal del movimiento.',
            rollbackError,
            rollbackStackTrace,
          );
        }
      }
      return const Result.failure(
        DomainException(
          message: 'No se pudo guardar el movimiento en el dispositivo.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }
}
