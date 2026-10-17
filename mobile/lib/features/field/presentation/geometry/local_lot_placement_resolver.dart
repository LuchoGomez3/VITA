import 'dart:math' as math;

import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';

/// Resultado de ubicar un vértice respecto de los lotes existentes.
class LocalLotPlacement {
  /// Crea una ubicación permitida o bloqueada.
  const LocalLotPlacement({required this.point, required this.isBlocked});

  /// Punto original o ajustado al límite más cercano.
  final LocalPoint point;

  /// Indica que el toque quedó dentro de un lote existente.
  final bool isBlocked;
}

/// Ajusta puntos cercanos a límites y bloquea puntos dentro de otros lotes.
abstract final class LocalLotPlacementResolver {
  /// Resuelve [point] usando una tolerancia expresada en coordenadas locales.
  static LocalLotPlacement resolve({
    required LocalPoint point,
    required Iterable<Lot> existingLots,
    required double snapTolerance,
  }) {
    LocalPoint? closestPoint;
    var closestDistance = double.infinity;

    for (final lot in existingLots) {
      final vertices = lot.boundary.vertices;
      for (var index = 0; index < vertices.length; index++) {
        final candidate = _closestPointOnSegment(
          point,
          vertices[index],
          vertices[(index + 1) % vertices.length],
        );
        final distance = _distance(point, candidate);
        if (distance < closestDistance) {
          closestDistance = distance;
          closestPoint = candidate;
        }
      }
    }

    if (closestPoint != null && closestDistance <= snapTolerance) {
      return LocalLotPlacement(point: closestPoint, isBlocked: false);
    }

    final isInside = existingLots.any(
      (lot) => _isStrictlyInside(point, lot.boundary.vertices),
    );
    return LocalLotPlacement(point: point, isBlocked: isInside);
  }

  static LocalPoint _closestPointOnSegment(
    LocalPoint point,
    LocalPoint start,
    LocalPoint end,
  ) {
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final squaredLength = dx * dx + dy * dy;
    if (squaredLength == 0) return start;
    final factor = (((point.x - start.x) * dx + (point.y - start.y) * dy) / squaredLength).clamp(0.0, 1.0);
    return LocalPoint(x: start.x + factor * dx, y: start.y + factor * dy);
  }

  static bool _isStrictlyInside(
    LocalPoint point,
    List<LocalPoint> vertices,
  ) {
    if (vertices.length < 3) return false;
    var inside = false;
    for (var current = 0, previous = vertices.length - 1; current < vertices.length; previous = current++) {
      final a = vertices[current];
      final b = vertices[previous];
      final crossesRay =
          (a.y > point.y) != (b.y > point.y) && point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x;
      if (crossesRay) inside = !inside;
    }
    return inside;
  }

  static double _distance(LocalPoint first, LocalPoint second) => math.sqrt(
    math.pow(first.x - second.x, 2) + math.pow(first.y - second.y, 2),
  );
}
