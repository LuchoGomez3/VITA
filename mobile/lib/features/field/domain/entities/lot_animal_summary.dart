import 'package:freezed_annotation/freezed_annotation.dart';

part 'lot_animal_summary.freezed.dart';

/// Proyección local mínima de un animal asignado a un lote.
@freezed
sealed class LotAnimalSummary with _$LotAnimalSummary {
  /// Crea una fila apta para conteos y detalle de lote.
  const factory LotAnimalSummary({
    required String id,
    required String establishmentId,
    required String lotId,
    required String rfidTagNumber,
    required String visualTag,
    required String categoryName,
  }) = _LotAnimalSummary;
}
