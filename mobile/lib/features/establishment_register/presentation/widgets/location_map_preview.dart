import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/satellite_imagery.dart';
import 'package:latlong2/latlong.dart';

/// Mapa fijo con el punto de referencia del establecimiento (paso 3).
///
/// Muestra la imagen satelital alrededor del punto leído del GPS. Sin
/// conexión queda el fondo neutro con el pin: el punto ya está confirmado
/// igual, la imagen es solo para verificarlo a simple vista.
class LocationMapPreview extends StatelessWidget {
  /// Crea la vista previa centrada en [latitud] y [longitud].
  const LocationMapPreview({
    required this.latitud,
    required this.longitud,
    super.key,
    this.height = 200,
    this.showSatelliteImagery = true,
  });

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: height,
        decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
        child: FlutterMap(
          // Sin MapController propio: una lectura nueva del GPS recrea el
          // mapa centrado en el punto nuevo.
          key: ValueKey(center),
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
            maxZoom: satelliteMaxZoom,
            backgroundColor: AppColors.backgroundSecondary,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            if (showSatelliteImagery) satelliteTileLayer(),
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
