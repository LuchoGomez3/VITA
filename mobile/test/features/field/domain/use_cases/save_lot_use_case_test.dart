import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/data/services/turf_lot_overlap_validator.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_draft.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';
import 'package:frontend_mayoral/features/field/domain/services/local_lot_boundary_validator.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/save_lot_use_case.dart';

void main() {
  late _DurableMemoryLotRepository repository;
  late SaveLotUseCase saveLot;

  setUp(() {
    repository = _DurableMemoryLotRepository();
    saveLot = SaveLotUseCase(
      repository: repository,
      validator: const LocalLotBoundaryValidator(),
      overlapValidator: const TurfLotOverlapValidator(),
      createId: () => 'lot-local-1',
      now: () => DateTime.utc(2026, 8, 28, 17),
    );
  });

  test('genera identidad local y conserva coordenadas cartesianas', () async {
    final result = await saveLot(
      establishmentId: 'est-1',
      draft: _draft('Lote norte'),
    );

    expect(result, isA<Success<Lot>>());
    expect(repository.records.single.id, 'lot-local-1');
    expect(repository.records.single.boundary.vertices.first.x, 100);
    expect(repository.records.single.createdAt, DateTime.utc(2026, 8, 28, 17));
  });

  test('impide nombres duplicados dentro del mismo establecimiento', () async {
    await saveLot(establishmentId: 'est-1', draft: _draft('Lote norte'));

    final result = await saveLot(
      establishmentId: 'est-1',
      draft: _draft('  LOTE NORTE  '),
    );

    expect(result, isA<Failure<Lot>>());
    expect(repository.records, hasLength(1));
  });

  test('impide guardar un lote superpuesto aunque tenga otro nombre', () async {
    await saveLot(establishmentId: 'est-1', draft: _draft('Lote norte'));

    final result = await saveLot(
      establishmentId: 'est-1',
      draft: _draft('Lote sur'),
    );

    expect(result, isA<Failure<Lot>>());
    expect(repository.records, hasLength(1));
  });
}

LotDraft _draft(String name) => LotDraft(
  name: name,
  surfaceTenths: 457,
  hasWater: true,
  boundary: const LotBoundary(
    vertices: [
      LocalPoint(x: 100, y: 100),
      LocalPoint(x: 300, y: 100),
      LocalPoint(x: 300, y: 300),
      LocalPoint(x: 100, y: 300),
    ],
  ),
);

class _DurableMemoryLotRepository implements LotRepository {
  final List<Lot> records = [];

  @override
  Future<Result<Lot>> getLot(String lotId) async => Result.success(records.singleWhere((lot) => lot.id == lotId));

  @override
  Future<Result<List<Lot>>> getLots(String establishmentId) async => Result.success(
    records.where((lot) => lot.establishmentId == establishmentId).toList(),
  );

  @override
  Future<Result<Lot>> saveLot(Lot lot) async {
    records.add(lot);
    return Result.success(lot);
  }
}
