import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary_validation.dart';

/// Contrato puro para validar la geometría de un lote en el dispositivo.
abstract interface class LotBoundaryValidator {
  /// Valida [boundary] y estima su superficie en metros cuadrados.
  LotBoundaryValidation validate(LotBoundary boundary);
}
