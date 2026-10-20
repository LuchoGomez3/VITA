import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/satellite_imagery.dart';
import 'package:latlong2/latlong.dart';

/// Mapa fijo con el punto de referencia del establecimiento y, si se dibujó,
/// el contorno del campo (pasos 3 y revisión).
///
/// Muestra la imagen satelital alrededor del punto leído del GPS. Con un
/// polígono, encuadra el campo entero. Sin conexión queda el fondo neutro con
/// el pin y el contorno: la imagen es solo para verificarlo a simple vista.
class LocationMapPreview extends StatelessWidget {
  /// Crea la vista previa centrada en [latitud] y [longitud].
  const LocationMapPreview({
    required this.latitud,
    required this.longitud,
    super.key,
    this.boundary = const [],
    this.height = 200,
    this.showSatelliteImagery = true,
  });

  /// Contorno del campo. Con 3+ vértices se dibuja y el mapa lo encuadra.
  final List<BoundaryPoint> boundary;

  /// Latitud del punto de referencia, en grados.
  final double latitud;

  /// Longitud del punto de referencia, en grados.
  final double longitud;

  /// Alto de la vista previa.
  final double height;

  /// Si se piden tiles satelitales. Los tests lo apagan para no usar la red.
  final bool showSatelliteImagery;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(latitud, longitud);
    final boundaryPoints = [for (final point in boundary) LatLng(point.latitud, point.longitud)];
    final hasBoundary = boundaryPoints.length >= 3;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: height,
        decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
        child: FlutterMap(
          // Sin MapController propio: si cambia el punto o el contorno (por
          // ejemplo, se vuelve a editar el paso 4), el mapa se recrea y encuadra
          // de nuevo.
          key: ValueKey(Object.hashAll([center, ...boundaryPoints])),
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
            initialCameraFit: hasBoundary
                ? CameraFit.coordinates(
                    coordinates: [...boundaryPoints, center],
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    maxZoom: 17,
                  )
                : null,
            maxZoom: satelliteMaxZoom,
            backgroundColor: AppColors.backgroundSecondary,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            if (showSatelliteImagery) satelliteTileLayer(),
            if (hasBoundary)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: boundaryPoints,
                    color: AppColors.primary.withValues(alpha: 0.25),
                    borderColor: AppColors.primary,
                    borderStrokeWidth: 3,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 32,
                  height: 32,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on, size: 32, color: AppColors.error),
                ),
              ],
            ),
            if (showSatelliteImagery) const SatelliteAttribution(),
          ],
        ),
      ),
    );
  }
}
