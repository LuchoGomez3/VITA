import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_movement_repository.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';

void main() {
  late _LotRepository lotRepository;
  late _MovementRepository movementRepository;
  late MoveLotAnimalsUseCase moveAnimals;

  setUp(() {
    lotRepository = _LotRepository([
      _lot('origin', LotStatus.active),
      _lot('destination', LotStatus.active),
      _lot('inactive', LotStatus.inactive),
    ]);
    movementRepository = _MovementRepository();
    moveAnimals = MoveLotAnimalsUseCase(
      lotRepository: lotRepository,
      movementRepository: movementRepository,
      createId: () => 'movement-1',
      now: () => DateTime.utc(2026, 8, 30, 20),
    );
  });

  test('registra varios animales y normaliza el motivo', () async {
    final result = await moveAnimals(
      establishmentId: 'est-1',
      sourceLotId: 'origin',
      destinationLotId: 'destination',
      animalIds: const ['animal-1', 'animal-2', 'animal-1'],
      occurredAt: DateTime(2026, 8, 30),
      reason: '  Rotación de pastoreo  ',
    );

    expect(result, isA<Success<LotAnimalMovement>>());
    expect(movementRepository.saved!.animalIds, ['animal-1', 'animal-2']);
    expect(movementRepository.saved!.reason, 'Rotación de pastoreo');
    expect(movementRepository.saved!.id, 'movement-1');
  });

  test('rechaza un destino inactivo antes de persistir', () async {
    final result = await moveAnimals(
      establishmentId: 'est-1',
      sourceLotId: 'origin',
      destinationLotId: 'inactive',
      animalIds: const ['animal-1'],
      occurredAt: DateTime(2026, 8, 30),
      reason: 'Descanso',
    );

    expect(result, isA<Failure<LotAnimalMovement>>());
    expect(movementRepository.saved, isNull);
  });

  test('requiere selección y motivo', () async {
    final result = await moveAnimals(
      establishmentId: 'est-1',
      sourceLotId: 'origin',
      destinationLotId: 'destination',
      animalIds: const [],
      occurredAt: DateTime(2026, 8, 30),
      reason: '',
    );

    expect(result, isA<Failure<LotAnimalMovement>>());
    expect(movementRepository.saved, isNull);
  });
}

Lot _lot(String id, LotStatus status) => Lot(
  id: id,
  establishmentId: 'est-1',
  name: id,
  boundary: const LotBoundary(
    vertices: [
      LocalPoint(x: 0, y: 0),
      LocalPoint(x: 10, y: 0),
      LocalPoint(x: 10, y: 10),
    ],
  ),
  surfaceTenths: 100,
  hasWater: true,
  status: status,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

class _LotRepository implements LotRepository {
  _LotRepository(this.lots);

  final List<Lot> lots;

  @override
  Future<Result<Lot>> getLot(String lotId) async => Result.success(lots.singleWhere((lot) => lot.id == lotId));

  @override
  Future<Result<List<Lot>>> getLots(String establishmentId) async => Result.success(lots);

  @override
  Future<Result<Lot>> saveLot(Lot lot) async => Result.success(lot);
}

class _MovementRepository implements LotAnimalMovementRepository {
  LotAnimalMovement? saved;

  @override
  Future<Result<LotAnimalMovement>> moveAnimals(
    LotAnimalMovement movement,
  ) async {
    saved = movement;
    return Result.success(movement);
  }
}
