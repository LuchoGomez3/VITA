import 'package:frontend_mayoral/features/field/domain/entities/local_coordinate_space.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary_validation.dart';
import 'package:frontend_mayoral/features/field/domain/services/lot_boundary_validator.dart';

/// Valida polígonos dentro del lienzo cartesiano local de 1000 × 1000.
class LocalLotBoundaryValidator implements LotBoundaryValidator {
  /// Crea el validador determinista sin dependencias cartográficas.
  const LocalLotBoundaryValidator();

  static const _coordinateTolerance = 1e-7;
  static const _minimumAreaSquareUnits = 0.01;

  @override
  LotBoundaryValidation validate(LotBoundary boundary) {
    final vertices = boundary.vertices;
    final preliminaryIssues = <LotBoundaryValidationIssue>[
      if (vertices.length < 3) LotBoundaryValidationIssue.insufficientVertices,
      if (vertices.any(_isInvalidCoordinate)) LotBoundaryValidationIssue.invalidCoordinate,
      if (_hasDuplicateVertex(vertices)) LotBoundaryValidationIssue.duplicateVertex,
    ];
    if (preliminaryIssues.isNotEmpty) {
      return LotBoundaryValidation(
        issues: preliminaryIssues,
        estimatedAreaSquareUnits: 0,
      );
    }

    if (_hasSelfIntersection(vertices)) {
      return const LotBoundaryValidation(
        issues: [LotBoundaryValidationIssue.selfIntersection],
        estimatedAreaSquareUnits: 0,
      );
    }

    final area = _area(vertices);
    if (area <= _minimumAreaSquareUnits) {
      return LotBoundaryValidation(
        issues: const [LotBoundaryValidationIssue.zeroArea],
        estimatedAreaSquareUnits: area,
      );
    }

    return LotBoundaryValidation(
      issues: const [],
      estimatedAreaSquareUnits: area,
    );
  }

  bool _isInvalidCoordinate(LocalPoint point) =>
      !point.x.isFinite ||
      !point.y.isFinite ||
      point.x < 0 ||
      point.x > LocalCoordinateSpace.extent ||
      point.y < 0 ||
      point.y > LocalCoordinateSpace.extent;

  bool _hasDuplicateVertex(List<LocalPoint> vertices) {
    for (var first = 0; first < vertices.length; first++) {
      for (var second = first + 1; second < vertices.length; second++) {
        if ((vertices[first].x - vertices[second].x).abs() <= _coordinateTolerance &&
            (vertices[first].y - vertices[second].y).abs() <= _coordinateTolerance) {
          return true;
        }
      }
    }
    return false;
  }

  bool _hasSelfIntersection(List<LocalPoint> vertices) {
    for (var firstEdge = 0; firstEdge < vertices.length; firstEdge++) {
      final firstStart = vertices[firstEdge];
      final firstEnd = vertices[(firstEdge + 1) % vertices.length];
      for (var secondEdge = firstEdge + 1; secondEdge < vertices.length; secondEdge++) {
        final adjacent = secondEdge == firstEdge + 1 || (firstEdge == 0 && secondEdge == vertices.length - 1);
        if (adjacent) continue;
        if (_segmentsIntersect(
          firstStart,
          firstEnd,
          vertices[secondEdge],
          vertices[(secondEdge + 1) % vertices.length],
        )) {
          return true;
        }
      }
    }
    return false;
  }

  bool _segmentsIntersect(
    LocalPoint firstStart,
    LocalPoint firstEnd,
    LocalPoint secondStart,
    LocalPoint secondEnd,
  ) {
    final first = _orientation(firstStart, firstEnd, secondStart);
    final second = _orientation(firstStart, firstEnd, secondEnd);
    final third = _orientation(secondStart, secondEnd, firstStart);
    final fourth = _orientation(secondStart, secondEnd, firstEnd);
    if (first * second < 0 && third * fourth < 0) return true;
    return (_isZero(first) && _isPointOnSegment(secondStart, firstStart, firstEnd)) ||
        (_isZero(second) && _isPointOnSegment(secondEnd, firstStart, firstEnd)) ||
        (_isZero(third) && _isPointOnSegment(firstStart, secondStart, secondEnd)) ||
        (_isZero(fourth) && _isPointOnSegment(firstEnd, secondStart, secondEnd));
  }

  double _orientation(LocalPoint start, LocalPoint end, LocalPoint point) =>
      (end.x - start.x) * (point.y - start.y) - (end.y - start.y) * (point.x - start.x);

  bool _isPointOnSegment(LocalPoint point, LocalPoint start, LocalPoint end) {
    final minX = start.x < end.x ? start.x : end.x;
    final maxX = start.x > end.x ? start.x : end.x;
    final minY = start.y < end.y ? start.y : end.y;
    final maxY = start.y > end.y ? start.y : end.y;
    return point.x >= minX - _coordinateTolerance &&
        point.x <= maxX + _coordinateTolerance &&
        point.y >= minY - _coordinateTolerance &&
        point.y <= maxY + _coordinateTolerance;
  }

  double _area(List<LocalPoint> vertices) {
    var doubledArea = 0.0;
    for (var index = 0; index < vertices.length; index++) {
      final current = vertices[index];
      final next = vertices[(index + 1) % vertices.length];
      doubledArea += current.x * next.y - next.x * current.y;
    }
    return doubledArea.abs() / 2;
  }

  bool _isZero(double value) => value.abs() <= _coordinateTolerance;
}
