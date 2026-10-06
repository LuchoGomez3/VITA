import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/local_canvas_projection.dart';
import 'package:latlong2/latlong.dart';

/// Transformación afín del world file: escala, rotación y centro del primer píxel.
///
/// El orden PGW es A, D, B, E, C, F. Sus coordenadas pertenecen al proyecto
/// de origen; sin conocer su CRS no se pueden interpretar como latitud/longitud.
class RasterWorldFile {
  /// Construye una transformación validando las seis líneas del PGW.
  factory RasterWorldFile.parse(String text) {
    final values = text.trim().split(RegExp(r'\s+')).map(double.parse).toList();
    if (values.length != 6 ||
        values.any((value) => !value.isFinite) ||
        values[0] * values[3] - values[2] * values[1] == 0) {
      throw const FormatException('Invalid world file affine transformation.');
    }
    return RasterWorldFile._(values[0], values[1], values[2], values[3], values[4], values[5]);
  }

  const RasterWorldFile._(this.columnX, this.columnY, this.rowX, this.rowY, this.originX, this.originY);

  /// Desplazamiento horizontal del proyecto por cada columna de píxeles.
  final double columnX;

  /// Desplazamiento vertical del proyecto por cada columna de píxeles.
  final double columnY;

  /// Desplazamiento horizontal del proyecto por cada fila de píxeles.
  final double rowX;

  /// Desplazamiento vertical del proyecto por cada fila de píxeles.
  final double rowY;

  /// Coordenada horizontal del centro del primer píxel.
  final double originX;

  /// Coordenada vertical del centro del primer píxel.
  final double originY;

  /// Convierte columnas y filas a coordenadas del proyecto, incluida la rotación.
  math.Point<double> pixelToProject(double column, double row) => math.Point(
    columnX * column + rowX * row + originX,
    columnY * column + rowY * row + originY,
  );
}

/// Ubica el raster en el lienzo local conservando su escala relativa y rotación.
class FieldRasterGeometry {
  /// Usa dimensiones reales del PNG y metadatos PGW, sin asumir un EPSG.
  factory FieldRasterGeometry.fromWorldFile(String text, {required int width, required int height}) {
    final world = RasterWorldFile.parse(text);
    final projectedWidth = world.columnX.abs() * width + world.rowX.abs() * height;
    final projectedHeight = world.columnY.abs() * width + world.rowY.abs() * height;
    final scale = math.min(
      LocalCanvasProjection.viewportWidth / projectedWidth,
      LocalCanvasProjection.viewportHeight / projectedHeight,
    );
    final center = world.pixelToProject((width - 1) / 2, (height - 1) / 2);

    // Se traslada y escala todo el plano por igual: no se estira el PNG ni se
    // confunden las coordenadas originales, en metros, con coordenadas GPS.
    LatLng toViewport(double column, double row) {
      final point = world.pixelToProject(column, row);
      return LatLng(
        LocalCanvasProjection.viewportHeight / 2 + (point.y - center.y) * scale,
        LocalCanvasProjection.viewportWidth / 2 + (point.x - center.x) * scale,
      );
    }

    return FieldRasterGeometry._(
      worldFile: world,
      topLeft: toViewport(-0.5, -0.5),
      bottomLeft: toViewport(-0.5, height - 0.5),
      bottomRight: toViewport(width - 0.5, height - 0.5),
      coverBounds: _coverBounds(world, width, height, scale),
    );
  }

  const FieldRasterGeometry._({
    required this.worldFile,
    required this.topLeft,
    required this.bottomLeft,
    required this.bottomRight,
    required this.coverBounds,
  });

  /// Metadatos originales para convertir píxeles a coordenadas del proyecto.
  final RasterWorldFile worldFile;

  /// Esquina superior izquierda exterior; el PGW referencia centros de píxel.
  final LatLng topLeft;

  /// Esquina inferior izquierda necesaria para dibujar la imagen rotada.
  final LatLng bottomLeft;

  /// Esquina inferior derecha necesaria para dibujar la imagen rotada.
  final LatLng bottomRight;

  /// Rectángulo interior seguro para llenar el visor sin bordes vacíos.
  final LatLngBounds coverBounds;

  static LatLngBounds _coverBounds(RasterWorldFile world, int width, int height, double scale) {
    final halfWidth = math.sqrt(world.columnX * world.columnX + world.columnY * world.columnY) * width * scale / 2;
    final halfHeight = math.sqrt(world.rowX * world.rowX + world.rowY * world.rowY) * height * scale / 2;
    final determinant = (world.columnX * world.rowY - world.rowX * world.columnY).abs() * scale;
    // Aplicar la matriz inversa a las cuatro esquinas del visor permite hallar
    // cuánto reducir el rectángulo para que incluso su esquina más alejada
    // permanezca dentro del PNG rotado. La cámara recorta, sin deformar la foto.
    final columnExtent = (world.rowY.abs() * halfWidth + world.rowX.abs() * halfHeight) / determinant;
    final rowExtent = (world.columnY.abs() * halfWidth + world.columnX.abs() * halfHeight) / determinant;
    final factor = math.min(width / (2 * columnExtent), height / (2 * rowExtent));
    const centerX = LocalCanvasProjection.viewportWidth / 2;
    const centerY = LocalCanvasProjection.viewportHeight / 2;
    return LatLngBounds(
      LatLng(centerY - halfHeight * factor, centerX - halfWidth * factor),
      LatLng(centerY + halfHeight * factor, centerX + halfWidth * factor),
    );
  }
}
