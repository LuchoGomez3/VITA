import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary_validation.dart';
import 'package:frontend_mayoral/features/field/domain/services/local_lot_boundary_validator.dart';

void main() {
  const validator = LocalLotBoundaryValidator();

  group('LocalLotBoundaryValidator', () {
    test('acepta un polígono cartesiano y calcula área relativa', () {
      final result = validator.validate(
        const LotBoundary(
          vertices: [
            LocalPoint(x: 100, y: 100),
            LocalPoint(x: 300, y: 100),
            LocalPoint(x: 300, y: 300),
            LocalPoint(x: 100, y: 300),
          ],
        ),
      );

      expect(result.isValid, isTrue);
      expect(result.estimatedAreaSquareUnits, 40000);
    });

    test('rechaza menos de tres vértices', () {
      final result = validator.validate(
        const LotBoundary(
          vertices: [LocalPoint(x: 1, y: 1), LocalPoint(x: 2, y: 2)],
        ),
      );
      expect(result.issues, contains(LotBoundaryValidationIssue.insufficientVertices));
    });

    test('rechaza puntos fuera del lienzo 1000 por 1000', () {
      final result = validator.validate(
        const LotBoundary(
          vertices: [
            LocalPoint(x: -1, y: 0),
            LocalPoint(x: 10, y: 0),
            LocalPoint(x: 0, y: 10),
          ],
        ),
      );
      expect(result.issues, contains(LotBoundaryValidationIssue.invalidCoordinate));
    });

    test('rechaza vértices repetidos', () {
      final result = validator.validate(
        const LotBoundary(
          vertices: [
            LocalPoint(x: 10, y: 10),
            LocalPoint(x: 20, y: 20),
            LocalPoint(x: 10, y: 10),
          ],
        ),
      );
      expect(result.issues, contains(LotBoundaryValidationIssue.duplicateVertex));
    });

    test('rechaza puntos colineales', () {
      final result = validator.validate(
        const LotBoundary(
          vertices: [
            LocalPoint(x: 10, y: 10),
            LocalPoint(x: 20, y: 20),
            LocalPoint(x: 30, y: 30),
          ],
        ),
      );
      expect(result.issues, contains(LotBoundaryValidationIssue.zeroArea));
    });

    test('rechaza un polígono auto-intersectado', () {
      final result = validator.validate(
        const LotBoundary(
          vertices: [
            LocalPoint(x: 100, y: 100),
            LocalPoint(x: 300, y: 300),
            LocalPoint(x: 300, y: 100),
            LocalPoint(x: 100, y: 300),
          ],
        ),
      );
      expect(result.issues, contains(LotBoundaryValidationIssue.selfIntersection));
    });
  });
}
