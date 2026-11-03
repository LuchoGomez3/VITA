import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';

part 'lot_boundary.freezed.dart';

/// Perímetro de un lote representado por vértices geográficos ordenados.
///
/// El primer punto no se repite al final. Cerrar el anillo es responsabilidad
/// de los adaptadores que necesiten otro formato, como GeoJSON/Turf.
@freezed
sealed class LotBoundary with _$LotBoundary {
  /// Crea un perímetro a partir de sus vértices en orden de recorrido.
  const factory LotBoundary({
    @Default(<LocalPoint>[]) List<LocalPoint> vertices,
  }) = _LotBoundary;
}
