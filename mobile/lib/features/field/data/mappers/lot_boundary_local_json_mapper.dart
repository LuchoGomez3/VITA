import 'dart:convert';

import 'package:frontend_mayoral/features/field/domain/entities/local_coordinate_space.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';

/// Serializa polígonos en el sistema cartesiano interno, sin simular GeoJSON.
class LotBoundaryLocalJsonMapper {
  const LotBoundaryLocalJsonMapper._();

  /// Identificador versionado del sistema cartesiano persistido.
  static const coordinateSpace = 'establishment_canvas_v1';

  /// Versión del contrato de geometría esquemática.
  static const version = 1;

  /// Codifica el orden exacto de los vértices sin repetir el primero.
  static String encode(LotBoundary boundary) => jsonEncode({
    'type': 'LocalPolygon',
    'coordinate_space': coordinateSpace,
    'version': version,
    'extent': {
      'width': LocalCoordinateSpace.extent,
      'height': LocalCoordinateSpace.extent,
    },
    'vertices': [
      for (final point in boundary.vertices) {'x': point.x, 'y': point.y},
    ],
  });

  /// Recupera un perímetro y rechaza formatos o espacios incompatibles.
  static LotBoundary decode(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic> ||
        decoded['type'] != 'LocalPolygon' ||
        (decoded['coordinate_space'] ?? decoded['coordinateSpace']) != coordinateSpace) {
      throw const FormatException('Invalid local lot geometry.');
    }
    final rawVertices = decoded['vertices'];
    if (rawVertices is! List) {
      throw const FormatException('Missing local lot vertices.');
    }
    return LotBoundary(
      vertices: [
        for (final rawPoint in rawVertices) _decodePoint(rawPoint),
      ],
    );
  }

  static LocalPoint _decodePoint(Object? rawPoint) {
    if (rawPoint case {'x': final num x, 'y': final num y}) {
      return LocalPoint(x: x.toDouble(), y: y.toDouble());
    }
    if (rawPoint case [final num x, final num y]) {
      return LocalPoint(x: x.toDouble(), y: y.toDouble());
    }
    throw const FormatException('Invalid local lot vertex.');
  }
}
