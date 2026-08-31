import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_movement_repository.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_repository.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/delete_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_available_destination_lots_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_animals_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/update_lot_details_use_case.dart';
import 'package:frontend_mayoral/features/field/presentation/cubit/lot_detail_cubit.dart';

void main() {
  test('conserva el detalle y expone el error al cargar destinos', () async {
    final lotRepository = _LotRepository();
    final animalRepository = _AnimalRepository();
    final cubit = LotDetailCubit(
      lotId: 'source-lot',
      getLot: GetLotUseCase(lotRepository),
      getAvailableDestinations: GetAvailableDestinationLotsUseCase(
        lotRepository,
      ),
      getAnimals: GetLotAnimalsUseCase(animalRepository),
      moveAnimals: MoveLotAnimalsUseCase(
        lotRepository: lotRepository,
        movementRepository: _MovementRepository(),
        createId: () => 'movement-id',
      ),
      updateLot: UpdateLotDetailsUseCase(
        lotRepository: lotRepository,
        animalRepository: animalRepository,
      ),
      deleteLot: DeleteLotUseCase(
        lotRepository: lotRepository,
        animalRepository: animalRepository,
      ),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.loadState, isA<Data<void>>());
    expect(cubit.state.lot?.id, 'source-lot');
    expect(cubit.state.animals, hasLength(1));
    expect(cubit.state.destinationsState, isA<ResultError<List<Lot>>>());
    expect(cubit.state.availableDestinations, isEmpty);
  });
}

class _LotRepository implements LotRepository {
  final Lot lot = Lot(
    id: 'source-lot',
    establishmentId: 'establishment-id',
    name: 'Lote origen',
    boundary: const LotBoundary(
      vertices: [
        LocalPoint(x: 0, y: 0),
        LocalPoint(x: 100, y: 0),
        LocalPoint(x: 0, y: 100),
      ],
    ),
    surfaceTenths: 100,
    hasWater: true,
    createdAt: DateTime.utc(2026, 8, 31),
    updatedAt: DateTime.utc(2026, 8, 31),
    status: LotStatus.active,
  );

  @override
  Future<Result<Lot>> getLot(String lotId) async => Result.success(lot);

  @override
  Future<Result<List<Lot>>> getLots(String establishmentId) async => const Result.failure(
    DomainException(
      message: 'No se pudieron cargar los destinos.',
      code: DomainErrorCode.offline,
    ),
  );

  @override
  Future<Result<Lot>> saveLot(Lot lot) async => Result.success(lot);
}

class _AnimalRepository implements LotAnimalRepository {
  @override
  Future<Result<List<LotAnimalSummary>>> getAnimals({
    required String establishmentId,
    String? lotId,
  }) async => const Result.success([
    LotAnimalSummary(
      id: 'animal-id',
      establishmentId: 'establishment-id',
      lotId: 'source-lot',
      rfidTagNumber: '982000412991416',
      visualTag: '003 1295',
      categoryName: 'Vaca',
    ),
  ]);
}

class _MovementRepository implements LotAnimalMovementRepository {
  @override
  Future<Result<LotAnimalMovement>> moveAnimals(
    LotAnimalMovement movement,
  ) async => Result.success(movement);
}
