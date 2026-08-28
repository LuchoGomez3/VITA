import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary_validation.dart';
import 'package:frontend_mayoral/features/field/domain/services/lot_boundary_validator.dart';

/// Ejecuta la validación local del perímetro sin exponer su implementación.
class ValidateLotBoundaryUseCase {
  /// Crea el caso de uso con el validador seleccionado por composición.
  const ValidateLotBoundaryUseCase(this._validator);

  final LotBoundaryValidator _validator;

  /// Valida [boundary] y devuelve errores de dominio tipados.
  LotBoundaryValidation call(LotBoundary boundary) {
    return _validator.validate(boundary);
  }
}
