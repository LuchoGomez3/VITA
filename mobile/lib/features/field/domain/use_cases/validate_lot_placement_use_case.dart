import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary_validation.dart';
import 'package:frontend_mayoral/features/field/domain/services/lot_boundary_validator.dart';
import 'package:frontend_mayoral/features/field/domain/services/lot_overlap_validator.dart';

/// Valida una delimitacion y su convivencia espacial con los lotes existentes.
class ValidateLotPlacementUseCase {
  /// Crea el caso de uso con las estrategias geometricas del dominio.
  const ValidateLotPlacementUseCase({
    required LotBoundaryValidator boundaryValidator,
    required LotOverlapValidator overlapValidator,
  }) : _boundaryValidator = boundaryValidator,
       _overlapValidator = overlapValidator;

  final LotBoundaryValidator _boundaryValidator;
  final LotOverlapValidator _overlapValidator;

  /// Devuelve todas las observaciones que impiden usar [boundary].
  LotBoundaryValidation call(
    LotBoundary boundary, {
    required List<Lot> existingLots,
  }) {
    final validation = _boundaryValidator.validate(boundary);
    if (!validation.isValid) return validation;

    final overlaps = existingLots.any(
      (lot) => _overlapValidator.hasPositiveAreaOverlap(
        boundary,
        lot.boundary,
      ),
    );
    if (!overlaps) return validation;

    return validation.copyWith(
      issues: const [LotBoundaryValidationIssue.overlapsExistingLot],
    );
  }
}
