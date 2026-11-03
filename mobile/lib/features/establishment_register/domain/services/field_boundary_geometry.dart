import 'dart:math' as math;

import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';

/// Cálculos sobre el polígono geográfico que delimita el campo.
///
/// Son funciones puras, sin dependencias de mapas: funcionan igual sin
/// conexión y se prueban sin dispositivo.
abstract final class FieldBoundaryGeometry {
  /// Radio medio de la Tierra, en metros (el mismo que usa Turf `area()`).
  ///
  /// Para un área sobre la esfera es más fiel que el radio ecuatorial WGS84,
  /// que la inflaría un 0,2 %.
  static const _earthRadiusMeters = 6371008.8;

  static const _squareMetersPerHectare = 10000.0;

  /// Superficie encerrada por [points], en hectáreas.
  ///
  /// Usa el área sobre la esfera de Chamberlain y Duquette (la de Turf
  /// `area()`). El polígono se cierra solo: no hace falta repetir el primer
  /// vértice. Con menos de 3 vértices devuelve 0.
  static double areaHectares(List<BoundaryPoint> points) {
    if (points.length < 3) {
      return 0;
    }

    var total = 0.0;
    for (var i = 0; i < points.length; i++) {
      final previous = points[i];
      final current = points[(i + 1) % points.length];
      final next = points[(i + 2) % points.length];
      total += (_radians(next.longitud) - _radians(previous.longitud)) * math.sin(_radians(current.latitud));
    }

    final squareMeters = (total * _earthRadiusMeters * _earthRadiusMeters / 2).abs();
    return squareMeters / _squareMetersPerHectare;
  }

  /// Indica si dos lados no consecutivos del polígono se cruzan.
  ///
  /// Trabaja en el plano lat/long: para el tamaño de un campo la distorsión
  /// no cambia si dos lados se cruzan o no. Incluye el lado que cierra el
  /// polígono (del último vértice al primero).
  static bool selfIntersects(List<BoundaryPoint> points) {
    final count = points.length;
    if (count < 4) {
      return false;
    }

    for (var i = 0; i < count; i++) {
      final a1 = points[i];
      final a2 = points[(i + 1) % count];
      for (var j = i + 1; j < count; j++) {
        final sharesVertex = j == i + 1 || (i == 0 && j == count - 1);
        if (sharesVertex) {
          continue;
        }
        final b1 = points[j];
        final b2 = points[(j + 1) % count];
        if (_segmentsIntersect(a1, a2, b1, b2)) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _segmentsIntersect(
    BoundaryPoint p1,
    BoundaryPoint p2,
    BoundaryPoint q1,
    BoundaryPoint q2,
  ) {
    final d1 = _orientation(q1, q2, p1);
    final d2 = _orientation(q1, q2, p2);
    final d3 = _orientation(p1, p2, q1);
    final d4 = _orientation(p1, p2, q2);

    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
      return true;
    }

    return (d1 == 0 && _onSegment(q1, q2, p1)) ||
        (d2 == 0 && _onSegment(q1, q2, p2)) ||
        (d3 == 0 && _onSegment(p1, p2, q1)) ||
        (d4 == 0 && _onSegment(p1, p2, q2));
  }

  /// Producto cruz de (b - a) × (c - a), con x = longitud e y = latitud.
  static double _orientation(BoundaryPoint a, BoundaryPoint b, BoundaryPoint c) {
    return (b.longitud - a.longitud) * (c.latitud - a.latitud) - (b.latitud - a.latitud) * (c.longitud - a.longitud);
  }

  /// Indica si [point], ya colineal con el segmento, cae dentro de él.
  static bool _onSegment(BoundaryPoint start, BoundaryPoint end, BoundaryPoint point) {
    return point.longitud >= math.min(start.longitud, end.longitud) &&
        point.longitud <= math.max(start.longitud, end.longitud) &&
        point.latitud >= math.min(start.latitud, end.latitud) &&
        point.latitud <= math.max(start.latitud, end.latitud);
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
