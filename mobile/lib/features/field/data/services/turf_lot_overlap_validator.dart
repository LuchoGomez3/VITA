import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/services/lot_overlap_validator.dart';
import 'package:turf/turf.dart';

/// Implementa las relaciones topológicas de lotes mediante Turf.
///
/// Las posiciones representan el lienzo cartesiano local. No son GeoJSON
/// geográfico ni se persisten como coordenadas WGS84.
class TurfLotOverlapValidator implements LotOverlapValidator {
  /// Crea el adaptador sin estado.
  const TurfLotOverlapValidator();

  static const _topologyEpsilon = 1e-6;

  @override
  bool hasPositiveAreaOverlap(
    LotBoundary candidate,
    LotBoundary existing,
  ) {
    if (_sameBoundary(candidate, existing)) return true;
    if (_separatedBySharedBoundary(candidate, existing)) return false;
    final candidatePolygon = _toPolygon(candidate);
    final existingPolygon = _toPolygon(existing);

    if (booleanEqual(
      candidatePolygon,
      existingPolygon,
      direction: true,
      shiftedPolygon: true,
    )) {
      return true;
    }
    if (booleanWithin(candidatePolygon, existingPolygon) || booleanWithin(existingPolygon, candidatePolygon)) {
      return true;
    }
    return _hasPositiveAreaIntersection(candidate, existing);
  }

  bool _hasPositiveAreaIntersection(
    LotBoundary first,
    LotBoundary second,
  ) {
    final firstVertices = first.vertices;
    final secondVertices = second.vertices;
    for (var firstIndex = 0; firstIndex < firstVertices.length; firstIndex++) {
      final firstStart = firstVertices[firstIndex];
      final firstEnd = firstVertices[(firstIndex + 1) % firstVertices.length];
      for (var secondIndex = 0; secondIndex < secondVertices.length; secondIndex++) {
        if (_properlyIntersects(
          firstStart,
          firstEnd,
          secondVertices[secondIndex],
          secondVertices[(secondIndex + 1) % secondVertices.length],
        )) {
          return true;
        }
      }
    }

    return _samples(firstVertices).any(
          (point) => _isStrictlyInside(point, secondVertices),
        ) ||
        _samples(secondVertices).any(
          (point) => _isStrictlyInside(point, firstVertices),
        );
  }

  Iterable<LocalPoint> _samples(List<LocalPoint> vertices) sync* {
    for (var index = 0; index < vertices.length; index++) {
      final start = vertices[index];
      final end = vertices[(index + 1) % vertices.length];
      yield start;
      yield LocalPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2);
    }
  }

  bool _properlyIntersects(
    LocalPoint firstStart,
    LocalPoint firstEnd,
    LocalPoint secondStart,
    LocalPoint secondEnd,
  ) {
    final firstSideA = _cross(firstStart, firstEnd, secondStart);
    final firstSideB = _cross(firstStart, firstEnd, secondEnd);
    final secondSideA = _cross(secondStart, secondEnd, firstStart);
    final secondSideB = _cross(secondStart, secondEnd, firstEnd);
    return firstSideA * firstSideB < -_topologyEpsilon && secondSideA * secondSideB < -_topologyEpsilon;
  }

  bool _isStrictlyInside(LocalPoint point, List<LocalPoint> vertices) {
    if (vertices.any((vertex) => _samePoint(point, vertex))) return false;
    for (var index = 0; index < vertices.length; index++) {
      if (_distanceToSegment(
            point,
            vertices[index],
            vertices[(index + 1) % vertices.length],
          ) <=
          _topologyEpsilon * _topologyEpsilon) {
        return false;
      }
    }

    var inside = false;
    for (var current = 0, previous = vertices.length - 1; current < vertices.length; previous = current++) {
      final a = vertices[current];
      final b = vertices[previous];
      if ((a.y > point.y) != (b.y > point.y) && point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x) {
        inside = !inside;
      }
    }
    return inside;
  }

  double _distanceToSegment(
    LocalPoint point,
    LocalPoint start,
    LocalPoint end,
  ) {
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final squaredLength = dx * dx + dy * dy;
    if (squaredLength == 0) {
      final pointDx = point.x - start.x;
      final pointDy = point.y - start.y;
      return (pointDx * pointDx + pointDy * pointDy).abs();
    }
    final factor = (((point.x - start.x) * dx + (point.y - start.y) * dy) / squaredLength).clamp(0.0, 1.0);
    final closestX = start.x + factor * dx;
    final closestY = start.y + factor * dy;
    final distanceX = point.x - closestX;
    final distanceY = point.y - closestY;
    return (distanceX * distanceX + distanceY * distanceY).abs();
  }

  double _cross(LocalPoint start, LocalPoint end, LocalPoint point) =>
      (end.x - start.x) * (point.y - start.y) - (end.y - start.y) * (point.x - start.x);

  bool _samePoint(LocalPoint first, LocalPoint second) =>
      (first.x - second.x).abs() <= _topologyEpsilon && (first.y - second.y).abs() <= _topologyEpsilon;

  bool _separatedBySharedBoundary(
    LotBoundary candidate,
    LotBoundary existing,
  ) {
    final candidateVertices = candidate.vertices;
    final existingVertices = existing.vertices;
    for (var candidateIndex = 0; candidateIndex < candidateVertices.length; candidateIndex++) {
      final candidateStart = candidateVertices[candidateIndex];
      final candidateEnd = candidateVertices[(candidateIndex + 1) % candidateVertices.length];
      for (var existingIndex = 0; existingIndex < existingVertices.length; existingIndex++) {
        final existingStart = existingVertices[existingIndex];
        final existingEnd = existingVertices[(existingIndex + 1) % existingVertices.length];
        if (!_segmentsShareLine(
          candidateStart,
          candidateEnd,
          existingStart,
          existingEnd,
        )) {
          continue;
        }

        final candidateDistances = candidateVertices.map(
          (point) => _signedDistance(point, existingStart, existingEnd),
        );
        final existingDistances = existingVertices.map(
          (point) => _signedDistance(point, existingStart, existingEnd),
        );
        final candidateMin = candidateDistances.reduce((a, b) => a < b ? a : b);
        final candidateMax = candidateDistances.reduce((a, b) => a > b ? a : b);
        final existingMin = existingDistances.reduce((a, b) => a < b ? a : b);
        final existingMax = existingDistances.reduce((a, b) => a > b ? a : b);
        final occupyOppositeHalfPlanes =
            (candidateMin >= -_topologyEpsilon && existingMax <= _topologyEpsilon) ||
            (candidateMax <= _topologyEpsilon && existingMin >= -_topologyEpsilon);
        if (occupyOppositeHalfPlanes) return true;
      }
    }
    return false;
  }

  bool _segmentsShareLine(
    LocalPoint firstStart,
    LocalPoint firstEnd,
    LocalPoint secondStart,
    LocalPoint secondEnd,
  ) {
    if (_signedDistance(firstStart, secondStart, secondEnd).abs() > _topologyEpsilon ||
        _signedDistance(firstEnd, secondStart, secondEnd).abs() > _topologyEpsilon) {
      return false;
    }
    final secondDx = secondEnd.x - secondStart.x;
    final secondDy = secondEnd.y - secondStart.y;
    final squaredLength = secondDx * secondDx + secondDy * secondDy;
    if (squaredLength == 0) return false;
    final firstProjection =
        ((firstStart.x - secondStart.x) * secondDx + (firstStart.y - secondStart.y) * secondDy) / squaredLength;
    final secondProjection =
        ((firstEnd.x - secondStart.x) * secondDx + (firstEnd.y - secondStart.y) * secondDy) / squaredLength;
    final overlapStart = firstProjection < secondProjection ? firstProjection : secondProjection;
    final overlapEnd = firstProjection > secondProjection ? firstProjection : secondProjection;
    return overlapEnd > _topologyEpsilon && overlapStart < 1 - _topologyEpsilon;
  }

  double _signedDistance(
    LocalPoint point,
    LocalPoint lineStart,
    LocalPoint lineEnd,
  ) {
    final dx = lineEnd.x - lineStart.x;
    final dy = lineEnd.y - lineStart.y;
    final squaredLength = dx * dx + dy * dy;
    if (squaredLength == 0) return double.infinity;
    return ((point.x - lineStart.x) * dy - (point.y - lineStart.y) * dx) / squaredLength;
  }

  Feature<Polygon> _toPolygon(LotBoundary boundary) {
    final vertices = boundary.vertices;
    final positions = <Position>[
      for (final point in vertices) Position(point.x, point.y),
      if (vertices.isNotEmpty) Position(vertices.first.x, vertices.first.y),
    ];
    return Feature<Polygon>(
      geometry: Polygon(coordinates: [positions]),
    );
  }

  bool _sameBoundary(LotBoundary first, LotBoundary second) {
    final firstVertices = first.vertices;
    final secondVertices = second.vertices;
    if (firstVertices.length != secondVertices.length) return false;
    if (firstVertices.isEmpty) return true;

    for (var offset = 0; offset < secondVertices.length; offset++) {
      if (_matchesFrom(firstVertices, secondVertices, offset, 1) ||
          _matchesFrom(firstVertices, secondVertices, offset, -1)) {
        return true;
      }
    }
    return false;
  }

  bool _matchesFrom(
    List<LocalPoint> first,
    List<LocalPoint> second,
    int offset,
    int direction,
  ) {
    for (var index = 0; index < first.length; index++) {
      final secondIndex = (offset + direction * index) % second.length;
      final firstPoint = first[index];
      final secondPoint = second[secondIndex];
      if ((firstPoint.x - secondPoint.x).abs() > 1e-7 || (firstPoint.y - secondPoint.y).abs() > 1e-7) {
        return false;
      }
    }
    return true;
  }
}
