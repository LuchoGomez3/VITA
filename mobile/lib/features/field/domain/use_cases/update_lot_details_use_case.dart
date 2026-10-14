import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_repository.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';

/// Edita únicamente datos alfanuméricos y conserva la geometría creada.
class UpdateLotDetailsUseCase {
  /// Crea el caso de uso con las fuentes locales necesarias.
  UpdateLotDetailsUseCase({
    required LotRepository lotRepository,
    required LotAnimalRepository animalRepository,
    DateTime Function()? now,
  }) : _lotRepository = lotRepository,
       _animalRepository = animalRepository,
       _now = now ?? DateTime.now;

  final LotRepository _lotRepository;
  final LotAnimalRepository _animalRepository;
  final DateTime Function() _now;

  /// Valida y persiste los campos editables del lote.
  Future<Result<Lot>> call({
    required String lotId,
    required String name,
    required int surfaceTenths,
    required bool hasWater,
    required LotStatus status,
    String? forageResourceCode,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty || surfaceTenths <= 0 || status == LotStatus.unknown) {
      return const Result.failure(
        DomainException(
          message: 'Revisá los datos obligatorios del lote.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    final currentResult = await _lotRepository.getLot(lotId);
    if (currentResult case Failure<Lot>(:final error)) {
      return Result.failure(error);
    }
    final current = (currentResult as Success<Lot>).data;
    final lotsResult = await _lotRepository.getLots(current.establishmentId);
    if (lotsResult case Failure<List<Lot>>(:final error)) {
      return Result.failure(error);
    }
    final lots = (lotsResult as Success<List<Lot>>).data;
    if (lots.any(
      (lot) => lot.id != lotId && lot.name.trim().toLowerCase() == normalizedName.toLowerCase(),
    )) {
      return const Result.failure(
        DomainException(
          message: 'Ya existe un lote con ese nombre.',
          code: DomainErrorCode.conflict,
        ),
      );
    }

    if (status == LotStatus.inactive) {
      final animalsResult = await _animalRepository.getAnimals(
        establishmentId: current.establishmentId,
        lotId: current.id,
      );
      if (animalsResult case Failure<List<LotAnimalSummary>>(:final error)) {
        return Result.failure(error);
      }
      if ((animalsResult as Success<List<LotAnimalSummary>>).data.isNotEmpty) {
        return const Result.failure(
          DomainException(
            message: 'Mové los animales antes de inactivar el lote.',
            code: DomainErrorCode.conflict,
          ),
        );
      }
    }

    // TODO(field): incorporar un flujo explícito de corrección geométrica. Las
    // ediciones ordinarias no reciben ni alteran el perímetro original.
    return _lotRepository.saveLot(
      current.copyWith(
        name: normalizedName,
        surfaceTenths: surfaceTenths,
        forageResourceCode: forageResourceCode,
        hasWater: hasWater,
        status: status,
        updatedAt: _now().toUtc(),
      ),
    );
  }
}
