import 'dart:convert';

import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';

/// Serializa polígonos en el sistema cartesiano interno, sin simular GeoJSON.
class LotBoundaryLocalJsonMapper {
  const LotBoundaryLocalJsonMapper._();

  /// Identificador versionado del sistema cartesiano persistido.
  static const coordinateSpace = 'establishment_canvas_v1';

  /// Ancho y alto canónicos del lienzo lógico.
  static const canvasExtent = 1000.0;

  /// Codifica el orden exacto de los vértices sin repetir el primero.
  static String encode(LotBoundary boundary) => jsonEncode({
    'type': 'LocalPolygon',
    'coordinateSpace': coordinateSpace,
    'extent': {'width': canvasExtent, 'height': canvasExtent},
    'vertices': [
      for (final point in boundary.vertices) [point.x, point.y],
    ],
  });

  /// Recupera un perímetro y rechaza formatos o espacios incompatibles.
  static LotBoundary decode(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic> ||
        decoded['type'] != 'LocalPolygon' ||
        decoded['coordinateSpace'] != coordinateSpace) {
      throw const FormatException('Invalid local lot geometry.');
    }
    final rawVertices = decoded['vertices'];
    if (rawVertices is! List) {
      throw const FormatException('Missing local lot vertices.');
    }
    return LotBoundary(
      vertices: [
        for (final rawPoint in rawVertices)
          if (rawPoint case [final num x, final num y])
            LocalPoint(x: x.toDouble(), y: y.toDouble())
          else
            throw const FormatException('Invalid local lot vertex.'),
      ],
    );
  }
}
