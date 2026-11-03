import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_repository.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';

/// Elimina lógicamente un lote sin animales y libera su área local.
class DeleteLotUseCase {
  /// Crea el caso de uso con dependencias offline.
  DeleteLotUseCase({
    required LotRepository lotRepository,
    required LotAnimalRepository animalRepository,
    DateTime Function()? now,
  }) : _lotRepository = lotRepository,
       _animalRepository = animalRepository,
       _now = now ?? DateTime.now;

  final LotRepository _lotRepository;
  final LotAnimalRepository _animalRepository;
  final DateTime Function() _now;

  /// Persiste un tombstone cuando el lote está vacío.
  Future<Result<Lot>> call(String lotId) async {
    final lotResult = await _lotRepository.getLot(lotId);
    if (lotResult case Failure<Lot>(:final error)) {
      return Result.failure(error);
    }
    final lot = (lotResult as Success<Lot>).data;
    final animalsResult = await _animalRepository.getAnimals(
      establishmentId: lot.establishmentId,
      lotId: lot.id,
    );
    if (animalsResult case Failure<List<LotAnimalSummary>>(:final error)) {
      return Result.failure(error);
    }
    if ((animalsResult as Success<List<LotAnimalSummary>>).data.isNotEmpty) {
      return const Result.failure(
        DomainException(
          message: 'Mové los animales antes de eliminar el lote.',
          code: DomainErrorCode.conflict,
        ),
      );
    }
    final timestamp = _now().toUtc();
    return _lotRepository.saveLot(
      lot.copyWith(updatedAt: timestamp, deletedAt: timestamp),
    );
  }
}
