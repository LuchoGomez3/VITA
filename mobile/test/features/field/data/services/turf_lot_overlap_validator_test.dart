import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/field/data/services/turf_lot_overlap_validator.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';

void main() {
  const validator = TurfLotOverlapValidator();

  group('TurfLotOverlapValidator', () {
    test('permite polígonos separados', () {
      expect(
        validator.hasPositiveAreaOverlap(
          _rectangle(0, 0, 10, 10),
          _rectangle(20, 20, 30, 30),
        ),
        isFalse,
      );
    });

    test('permite compartir un vértice', () {
      expect(
        validator.hasPositiveAreaOverlap(
          _rectangle(0, 0, 10, 10),
          _rectangle(10, 10, 20, 20),
        ),
        isFalse,
      );
    });

    test('permite compartir un borde', () {
      expect(
        validator.hasPositiveAreaOverlap(
          _rectangle(0, 0, 10, 10),
          _rectangle(10, 0, 20, 10),
        ),
        isFalse,
      );
    });

    test('estabiliza el contacto de borde ante ruido numérico mínimo', () {
      expect(
        validator.hasPositiveAreaOverlap(
          _rectangle(0, 0, 10, 10),
          _rectangle(10 - 1e-8, 0, 20, 10),
        ),
        isFalse,
      );
    });

    test('no tolera una superposición pequeña pero geométricamente real', () {
      expect(
        validator.hasPositiveAreaOverlap(
          _rectangle(0, 0, 10, 10),
          _rectangle(10 - 0.001, 0, 20, 10),
        ),
        isTrue,
      );
    });

    test('rechaza cruce con área positiva', () {
      expect(
        validator.hasPositiveAreaOverlap(
          _rectangle(0, 0, 10, 10),
          _rectangle(5, 5, 15, 15),
        ),
        isTrue,
      );
    });

    test('rechaza contención en ambos órdenes', () {
      final outer = _rectangle(0, 0, 20, 20);
      final inner = _rectangle(5, 5, 10, 10);

      expect(validator.hasPositiveAreaOverlap(inner, outer), isTrue);
      expect(validator.hasPositiveAreaOverlap(outer, inner), isTrue);
    });

    test('rechaza polígonos idénticos con distinto punto inicial', () {
      const first = LotBoundary(
        vertices: [
          LocalPoint(x: 0, y: 0),
          LocalPoint(x: 10, y: 0),
          LocalPoint(x: 10, y: 10),
          LocalPoint(x: 0, y: 10),
        ],
      );
      const shifted = LotBoundary(
        vertices: [
          LocalPoint(x: 10, y: 10),
          LocalPoint(x: 0, y: 10),
          LocalPoint(x: 0, y: 0),
          LocalPoint(x: 10, y: 0),
        ],
      );

      expect(validator.hasPositiveAreaOverlap(first, shifted), isTrue);
    });
  });
}

LotBoundary _rectangle(double left, double top, double right, double bottom) {
  return LotBoundary(
    vertices: [
      LocalPoint(x: left, y: top),
      LocalPoint(x: right, y: top),
      LocalPoint(x: right, y: bottom),
      LocalPoint(x: left, y: bottom),
    ],
  );
}
