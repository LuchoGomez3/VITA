import 'package:frontend_mayoral/features/field/domain/entities/local_coordinate_space.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:latlong2/latlong.dart';

/// Adapta las coordenadas locales al sistema visual limitado de flutter_map.
///
/// Los valores [LatLng] producidos no representan ubicaciones geográficas y
/// nunca deben persistirse. El dominio conserva su lienzo cartesiano 0..1000.
abstract final class LocalCanvasProjection {
  /// Ancho técnico del viewport usado por el CRS simple de flutter_map.
  static const viewportWidth = 100.0;

  /// Alto técnico menor a 90 para respetar las restricciones de flutter_map.
  static const viewportHeight = 80.0;

  /// Proyecta un punto de dominio al viewport.
  static LatLng toViewport(LocalPoint point) => LatLng(
    point.y / LocalCoordinateSpace.extent * viewportHeight,
    point.x / LocalCoordinateSpace.extent * viewportWidth,
  );

  /// Recupera el punto cartesiano desde una interacción en el viewport.
  static LocalPoint fromViewport(LatLng point) => LocalPoint(
    x: (point.longitude / viewportWidth * LocalCoordinateSpace.extent).clamp(
      0,
      LocalCoordinateSpace.extent,
    ),
    y: (point.latitude / viewportHeight * LocalCoordinateSpace.extent).clamp(
      0,
      LocalCoordinateSpace.extent,
    ),
  );
}
