import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_draft.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';
import 'package:frontend_mayoral/features/field/domain/services/lot_boundary_validator.dart';
import 'package:frontend_mayoral/features/field/domain/services/lot_overlap_validator.dart';

/// Convierte un borrador válido en un lote durable generado por el cliente.
class SaveLotUseCase {
  /// Crea el caso de uso con dependencias deterministas e inyectables.
  SaveLotUseCase({
    required LotRepository repository,
    required LotBoundaryValidator validator,
    required LotOverlapValidator overlapValidator,
    required String Function() createId,
    DateTime Function()? now,
  }) : _repository = repository,
       _validator = validator,
       _overlapValidator = overlapValidator,
       _createId = createId,
       _now = now ?? DateTime.now;

  final LotRepository _repository;
  final LotBoundaryValidator _validator;
  final LotOverlapValidator _overlapValidator;
  final String Function() _createId;
  final DateTime Function() _now;

  /// Valida nombre, geometría y unicidad local antes de escribir.
  Future<Result<Lot>> call({
    required String establishmentId,
    required LotDraft draft,
  }) async {
    final name = draft.name.trim();
    if (name.isEmpty ||
        draft.surfaceTenths <= 0 ||
        draft.hasWater == null ||
        !_validator.validate(draft.boundary).isValid) {
      return const Result.failure(
        DomainException(
          message: 'Revisá el nombre y la delimitación del lote.',
          code: DomainErrorCode.validation,
        ),
      );
    }
    final existingResult = await _repository.getLots(establishmentId);
    if (existingResult case Success<List<Lot>>(:final data)) {
      final normalized = name.toLowerCase();
      if (data.any((lot) => lot.name.trim().toLowerCase() == normalized)) {
        return const Result.failure(
          DomainException(
            message: 'Ya existe un lote con ese nombre.',
            code: DomainErrorCode.conflict,
          ),
        );
      }
      if (data.any(
        (lot) => _overlapValidator.hasPositiveAreaOverlap(
          draft.boundary,
          lot.boundary,
        ),
      )) {
        return const Result.failure(
          DomainException(
            message: 'La delimitación se superpone con otro lote.',
            code: DomainErrorCode.conflict,
          ),
        );
      }
    } else if (existingResult case Failure<List<Lot>>(:final error)) {
      return Result.failure(error);
    }
    final timestamp = _now().toUtc();
    return _repository.saveLot(
      Lot(
        id: _createId(),
        establishmentId: establishmentId,
        name: name,
        boundary: draft.boundary,
        surfaceTenths: draft.surfaceTenths,
        forageResourceCode: draft.forageResourceCode,
        hasWater: draft.hasWater!,
        status: draft.status,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );
  }
}
