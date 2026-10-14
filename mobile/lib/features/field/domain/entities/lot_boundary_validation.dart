import 'package:freezed_annotation/freezed_annotation.dart';

part 'lot_boundary_validation.freezed.dart';

/// Problemas geométricos que el editor puede mostrar sin depender de textos.
enum LotBoundaryValidationIssue {
  /// Se necesitan al menos tres vértices distintos.
  insufficientVertices,

  /// Existe una coordenada no finita o fuera de WGS84.
  invalidCoordinate,

  /// Un mismo vértice aparece más de una vez.
  duplicateVertex,

  /// El perímetro no encierra una superficie significativa.
  zeroArea,

  /// Dos lados no adyacentes se cruzan.
  selfIntersection,

  /// El lote ocupa área positiva de otro lote no eliminado.
  overlapsExistingLot,
}

/// Resultado tipado de validar un perímetro de lote.
@freezed
sealed class LotBoundaryValidation with _$LotBoundaryValidation {
  /// Crea el resultado y su superficie geodésica estimada.
  const factory LotBoundaryValidation({
    required List<LotBoundaryValidationIssue> issues,
    required double estimatedAreaSquareUnits,
  }) = _LotBoundaryValidation;

  const LotBoundaryValidation._();

  /// Indica si el lote puede cerrarse y confirmarse.
  bool get isValid => issues.isEmpty;
}
