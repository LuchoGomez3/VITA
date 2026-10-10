import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/services/field_boundary_geometry.dart';
import 'package:turf/turf.dart' as turf;

void main() {
  // Campo irregular de unos cientos de hectáreas cerca de Coronel Moldes.
  const field = [
    BoundaryPoint(latitud: -33.6200, longitud: -64.6000),
    BoundaryPoint(latitud: -33.6180, longitud: -64.5720),
    BoundaryPoint(latitud: -33.6350, longitud: -64.5650),
    BoundaryPoint(latitud: -33.6460, longitud: -64.5800),
    BoundaryPoint(latitud: -33.6390, longitud: -64.6020),
  ];

  const square = [
    BoundaryPoint(latitud: -33.10, longitud: -64.10),
    BoundaryPoint(latitud: -33.10, longitud: -64.20),
    BoundaryPoint(latitud: -33.20, longitud: -64.20),
    BoundaryPoint(latitud: -33.20, longitud: -64.10),
  ];

  group('FieldBoundaryGeometry.areaHectares', () {
    test('matches the geodesic area computed by Turf', () {
      final turfSquareMeters = turf.area(
        turf.Polygon(
          coordinates: [
            [
              for (final point in [...field, field.first]) turf.Position(point.longitud, point.latitud),
            ],
          ],
        ),
      )!;

      expect(
        FieldBoundaryGeometry.areaHectares(field),
        closeTo(turfSquareMeters / 10000, 0.01),
      );
    });

    test('does not depend on the drawing direction', () {
      expect(
        FieldBoundaryGeometry.areaHectares(field.reversed.toList()),
        closeTo(FieldBoundaryGeometry.areaHectares(field), 1e-9),
      );
    });

    test('is about 10 x 11 km for a 0.1 degree square at this latitude', () {
      // 0,1° de latitud ≈ 11,1 km; 0,1° de longitud a -33° ≈ 9,3 km.
      expect(FieldBoundaryGeometry.areaHectares(square), closeTo(10350, 100));
    });

    test('is zero with fewer than 3 vertices', () {
      expect(FieldBoundaryGeometry.areaHectares(const []), 0);
      expect(FieldBoundaryGeometry.areaHectares(square.sublist(0, 2)), 0);
    });

    test('is zero for collinear vertices', () {
      const line = [
        BoundaryPoint(latitud: -33.1, longitud: -64.1),
        BoundaryPoint(latitud: -33.2, longitud: -64.1),
        BoundaryPoint(latitud: -33.3, longitud: -64.1),
      ];

      expect(FieldBoundaryGeometry.areaHectares(line), closeTo(0, 1e-6));
    });
  });

  group('FieldBoundaryGeometry.selfIntersects', () {
    test('a simple polygon does not self-intersect', () {
      expect(FieldBoundaryGeometry.selfIntersects(square), isFalse);
      expect(FieldBoundaryGeometry.selfIntersects(field), isFalse);
    });

    test('a triangle never self-intersects', () {
      expect(FieldBoundaryGeometry.selfIntersects(square.sublist(0, 3)), isFalse);
    });

    test('detects a bow tie (corners visited diagonally)', () {
      final bowTie = [square[0], square[2], square[1], square[3]];

      expect(FieldBoundaryGeometry.selfIntersects(bowTie), isTrue);
    });

    test('detects the closing side crossing another side', () {
      // El último lado (del 5 al 1) cruza el lado 2-3.
      const crossing = [
        BoundaryPoint(latitud: 0, longitud: 0),
        BoundaryPoint(latitud: 0, longitud: 4),
        BoundaryPoint(latitud: 4, longitud: 4),
        BoundaryPoint(latitud: 4, longitud: 2),
        BoundaryPoint(latitud: -1, longitud: 6),
      ];

      expect(FieldBoundaryGeometry.selfIntersects(crossing), isTrue);
    });

    test('detects a vertex touching a non adjacent side', () {
      const touching = [
        BoundaryPoint(latitud: 0, longitud: 0),
        BoundaryPoint(latitud: 0, longitud: 4),
        BoundaryPoint(latitud: 4, longitud: 4),
        BoundaryPoint(latitud: 0, longitud: 2),
        BoundaryPoint(latitud: 4, longitud: 0),
      ];

      expect(FieldBoundaryGeometry.selfIntersects(touching), isTrue);
    });
  });
}
