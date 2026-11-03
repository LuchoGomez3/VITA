import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_repository.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/delete_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/update_lot_details_use_case.dart';

void main() {
  late _LotRepository lotRepository;
  late _AnimalRepository animalRepository;

  setUp(() {
    lotRepository = _LotRepository(_lot());
    animalRepository = _AnimalRepository();
  });

  test('impide inactivar un lote con animales', () async {
    animalRepository.animals = [_animal()];
    final useCase = UpdateLotDetailsUseCase(
      lotRepository: lotRepository,
      animalRepository: animalRepository,
    );

    final result = await useCase(
      lotId: 'lot-1',
      name: 'Lote 1',
      surfaceTenths: 100,
      hasWater: true,
      status: LotStatus.inactive,
    );

    expect(result, isA<Failure<Lot>>());
    expect(lotRepository.lot.status, LotStatus.active);
  });

  test('elimina lógicamente un lote vacío', () async {
    final timestamp = DateTime.utc(2026, 8, 30, 22);
    final useCase = DeleteLotUseCase(
      lotRepository: lotRepository,
      animalRepository: animalRepository,
      now: () => timestamp,
    );

    final result = await useCase('lot-1');

    expect(result, isA<Success<Lot>>());
    expect(lotRepository.lot.deletedAt, timestamp);
    expect(lotRepository.lot.updatedAt, timestamp);
  });

  test('impide eliminar un lote con animales', () async {
    animalRepository.animals = [_animal()];
    final useCase = DeleteLotUseCase(
      lotRepository: lotRepository,
      animalRepository: animalRepository,
    );

    final result = await useCase('lot-1');

    expect(result, isA<Failure<Lot>>());
    expect(lotRepository.lot.deletedAt, isNull);
  });
}

Lot _lot() => Lot(
  id: 'lot-1',
  establishmentId: 'est-1',
  name: 'Lote 1',
  boundary: const LotBoundary(
    vertices: [
      LocalPoint(x: 0, y: 0),
      LocalPoint(x: 10, y: 0),
      LocalPoint(x: 10, y: 10),
    ],
  ),
  surfaceTenths: 100,
  hasWater: true,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

LotAnimalSummary _animal() => const LotAnimalSummary(
  id: 'animal-1',
  establishmentId: 'est-1',
  lotId: 'lot-1',
  rfidTagNumber: '982000000000001',
  visualTag: 'A1',
  categoryName: 'Vaca',
);

class _LotRepository implements LotRepository {
  _LotRepository(this.lot);

  Lot lot;

  @override
  Future<Result<Lot>> getLot(String lotId) async => Result.success(lot);

  @override
  Future<Result<List<Lot>>> getLots(String establishmentId) async => Result.success([lot]);

  @override
  Future<Result<Lot>> saveLot(Lot lot) async {
    this.lot = lot;
    return Result.success(lot);
  }
}

class _AnimalRepository implements LotAnimalRepository {
  List<LotAnimalSummary> animals = [];

  @override
  Future<Result<List<LotAnimalSummary>>> getAnimals({
    required String establishmentId,
    String? lotId,
  }) async => Result.success(animals);
}
