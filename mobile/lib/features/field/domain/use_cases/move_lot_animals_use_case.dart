import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_movement_repository.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';

/// Valida y registra un movimiento local entre lotes.
class MoveLotAnimalsUseCase {
  /// Crea el caso de uso con reloj e identificador inyectables.
  const MoveLotAnimalsUseCase({
    required LotRepository lotRepository,
    required LotAnimalMovementRepository movementRepository,
    required String Function() createId,
    DateTime Function()? now,
  }) : _lotRepository = lotRepository,
       _movementRepository = movementRepository,
       _createId = createId,
       _now = now;

  final LotRepository _lotRepository;
  final LotAnimalMovementRepository _movementRepository;
  final String Function() _createId;
  final DateTime Function()? _now;

  /// Mueve [animalIds] desde [sourceLotId] hacia [destinationLotId].
  Future<Result<LotAnimalMovement>> call({
    required String establishmentId,
    required String sourceLotId,
    required String destinationLotId,
    required List<String> animalIds,
    required DateTime occurredAt,
    required String reason,
    String? responsibleId,
  }) async {
    final normalizedIds = animalIds.toSet().toList(growable: false);
    if (normalizedIds.isEmpty || reason.trim().isEmpty) {
      return const Result.failure(
        DomainException(
          message: 'Seleccioná animales e ingresá el motivo del movimiento.',
          code: DomainErrorCode.validation,
        ),
      );
    }
    if (sourceLotId == destinationLotId) {
      return const Result.failure(
        DomainException(
          message: 'El lote de destino debe ser distinto al lote actual.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    final destinationResult = await _lotRepository.getLot(destinationLotId);
    switch (destinationResult) {
      case Failure(:final error):
        return Result.failure(error);
      case Success(:final data):
        if (data.establishmentId != establishmentId || data.status != LotStatus.active) {
          return const Result.failure(
            DomainException(
              message: 'El lote de destino no está activo o no pertenece al establecimiento.',
              code: DomainErrorCode.validation,
            ),
          );
        }
    }

    final timestamp = (_now?.call() ?? DateTime.now()).toUtc();
    return _movementRepository.moveAnimals(
      LotAnimalMovement(
        id: _createId(),
        establishmentId: establishmentId,
        sourceLotId: sourceLotId,
        destinationLotId: destinationLotId,
        animalIds: normalizedIds,
        occurredAt: occurredAt.toUtc(),
        reason: reason.trim(),
        responsibleId: responsibleId,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );
  }
}
