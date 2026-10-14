import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';

/// Contrato de dominio para detectar ocupación de área entre dos lotes.
abstract class LotOverlapValidator {
  /// Devuelve `true` cuando las geometrías comparten área positiva.
  ///
  /// Un contacto limitado a vértices o bordes debe devolver `false`.
  bool hasPositiveAreaOverlap(
    LotBoundary candidate,
    LotBoundary existing,
  );
}
