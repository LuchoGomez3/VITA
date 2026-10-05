import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/local_canvas_projection.dart';
import 'package:latlong2/latlong.dart';

/// Fondo offline del campo exportado desde QGIS, limitado a San Nicolás.
abstract final class FieldSatelliteMap {
  /// Imagen empaquetada: no descarga tiles ni necesita conexión.
  static const assetPath = 'assets/images/field_maps/campo.png';

  /// Selección temporal por nombre hasta contar con configuración por UUID.
  /// Acepta la variante sin tilde, pero nunca coincidencias parciales.
  static bool supportsEstablishment(String? name) => name?.trim().toLowerCase().replaceAll('á', 'a') == 'san nicolas';

  /// Conserva la proporción original sin modificar las coordenadas de los lotes.
  /// El PGW se conserva para una futura migración geográfica; este CRS es local.
  static final bounds = LatLngBounds(
    const LatLng((LocalCanvasProjection.viewportHeight - 100 * 2846 / 5052) / 2, 0),
    const LatLng((LocalCanvasProjection.viewportHeight + 100 * 2846 / 5052) / 2, 100),
  );
}

/// Imagen bajo los polígonos; deja pasar los gestos del mapa y del editor.
class FieldSatelliteLayer extends StatelessWidget {
  /// Crea la capa compartida por visor y dibujo de lotes.
  const FieldSatelliteLayer({super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: OverlayImageLayer(
      overlayImages: [
        OverlayImage(
          bounds: FieldSatelliteMap.bounds,
          imageProvider: const AssetImage(FieldSatelliteMap.assetPath),
        ),
      ],
    ),
  );
}
