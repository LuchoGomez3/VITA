import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/local_lot_placement_resolver.dart';

void main() {
  final existingLot = Lot(
    id: 'lot-1',
    establishmentId: 'est-1',
    name: 'Existente',
    boundary: const LotBoundary(
      vertices: [
        LocalPoint(x: 100, y: 100),
        LocalPoint(x: 300, y: 100),
        LocalPoint(x: 300, y: 300),
        LocalPoint(x: 100, y: 300),
      ],
    ),
    surfaceTenths: 100,
    hasWater: true,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('ajusta un punto exterior al borde exacto más cercano', () {
    final placement = LocalLotPlacementResolver.resolve(
      point: const LocalPoint(x: 92, y: 180),
      existingLots: [existingLot],
      snapTolerance: 10,
    );

    expect(placement.isBlocked, isFalse);
    expect(placement.point, const LocalPoint(x: 100, y: 180));
  });

  test('ajusta al borde un punto apenas interior para permitir adyacencia', () {
    final placement = LocalLotPlacementResolver.resolve(
      point: const LocalPoint(x: 104, y: 180),
      existingLots: [existingLot],
      snapTolerance: 5,
    );

    expect(placement.isBlocked, isFalse);
    expect(placement.point, const LocalPoint(x: 100, y: 180));
  });

  test('bloquea un punto claramente dentro de un lote existente', () {
    final placement = LocalLotPlacementResolver.resolve(
      point: const LocalPoint(x: 200, y: 200),
      existingLots: [existingLot],
      snapTolerance: 10,
    );

    expect(placement.isBlocked, isTrue);
    expect(placement.point, const LocalPoint(x: 200, y: 200));
  });

  test('conserva un punto exterior alejado', () {
    final placement = LocalLotPlacementResolver.resolve(
      point: const LocalPoint(x: 20, y: 20),
      existingLots: [existingLot],
      snapTolerance: 10,
    );

    expect(placement.isBlocked, isFalse);
    expect(placement.point, const LocalPoint(x: 20, y: 20));
  });
}
