import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/field_raster_geometry.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Configuración del fondo offline para el campo de demostración y San Nicolás.
abstract final class FieldSatelliteMap {
  /// Imagen empaquetada: no descarga tiles ni necesita conexión.
  static const assetPath = 'assets/images/field_maps/campo.png';

  /// Escala, rotación y origen que acompañan a la imagen exportada desde QGIS.
  static const worldFilePath = 'assets/images/field_maps/campo.pgw';

  /// Selección temporal; la demo comparte este campo sintético en sus lotes.
  static bool supportsEstablishment(String? name, {bool demoMode = AppConfig.demoMode}) =>
      demoMode || name?.trim().toLowerCase().replaceAll('á', 'a') == 'san nicolas';

  /// Carga los assets una sola vez para reutilizar su geometría en cada visor.
  static final Future<FieldRasterGeometry> geometry = _loadGeometry();

  /// Geometría disponible para abrir otros visores sin repetir la espera.
  static FieldRasterGeometry? get loadedGeometry => _loadedGeometry;

  static FieldRasterGeometry? _loadedGeometry;

  static Future<FieldRasterGeometry> _loadGeometry() async {
    final image = await rootBundle.load(assetPath);
    final worldFile = await rootBundle.loadString(worldFilePath);
    // La cabecera IHDR del PNG guarda ancho y alto: leerla evita decodificar
    // toda la imagen sólo para conocer su tamaño y mantiene ambos assets unidos.
    final geometry = FieldRasterGeometry.fromWorldFile(
      worldFile,
      width: image.getUint32(16),
      height: image.getUint32(20),
    );
    _loadedGeometry = geometry;
    return geometry;
  }
}

/// Espera la geometría para que el mapa nazca con el encuadre correcto.
class FieldRasterBuilder extends StatelessWidget {
  /// Mantiene el visor esquemático cuando el establecimiento no tiene raster.
  const FieldRasterBuilder({required this.showSatelliteMap, required this.builder, super.key});

  /// Indica si este visor debe cargar el fondo offline.
  final bool showSatelliteMap;

  /// Compone el mapa con geometría, o sin ella para el lienzo esquemático.
  final Widget Function(BuildContext, FieldRasterGeometry?) builder;

  @override
  Widget build(BuildContext context) {
    if (!showSatelliteMap) return builder(context, null);
    final loadedGeometry = FieldSatelliteMap.loadedGeometry;
    if (loadedGeometry != null) return builder(context, loadedGeometry);
    return FutureBuilder<FieldRasterGeometry>(
      future: FieldSatelliteMap.geometry,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text(FieldStrings.satelliteMapLoadError));
        final geometry = snapshot.data;
        if (geometry == null) return const Center(child: CircularProgressIndicator());
        return builder(context, geometry);
      },
    );
  }
}

/// Imagen rotada bajo los polígonos; deja pasar los gestos del mapa y del editor.
class FieldSatelliteLayer extends StatelessWidget {
  /// Recibe la geometría ya cargada antes de inicializar la cámara del mapa.
  const FieldSatelliteLayer({required this.geometry, super.key});

  /// Posición calculada desde los archivos PNG y PGW empaquetados.
  final FieldRasterGeometry geometry;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: OverlayImageLayer(
      overlayImages: [
        RotatedOverlayImage(
          topLeftCorner: geometry.topLeft,
          bottomLeftCorner: geometry.bottomLeft,
          bottomRightCorner: geometry.bottomRight,
          imageProvider: const AssetImage(FieldSatelliteMap.assetPath),
        ),
      ],
    ),
  );
}
