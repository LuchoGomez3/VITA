import 'package:freezed_annotation/freezed_annotation.dart';

part 'boundary_point.freezed.dart';

/// Vértice del polígono que delimita el campo, en coordenadas WGS84.
///
/// A diferencia de la geometría esquemática de los lotes (ADR-0002), estos
/// puntos son geográficos reales: salen de tocar el mapa o del GPS al recorrer
/// el perímetro.
@freezed
sealed class BoundaryPoint with _$BoundaryPoint {
  /// Crea un vértice en la latitud y longitud indicadas, en grados.
  const factory BoundaryPoint({
    required double latitud,
    required double longitud,
  }) = _BoundaryPoint;
}
