import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/lot_movement/data/repositories/lot_movement_repository_impl.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/use_cases/lot_movement_use_cases.dart';
import 'package:frontend_mayoral/features/lot_movement/presentation/cubit/lot_movement_cubit.dart';

/// Resuelve dependencias del flujo accesible por rutas desde distintas features.
LotMovementCubit createLotMovementCubit({required String establishmentId, String? animalId, String? sourceLotId}) {
  final repository = LotMovementRepositoryImpl(
    animals: BrickAnimalStore.instance,
    lots: BrickLotStore.instance,
    movements: BrickAnimalLotMovementStore.instance,
  );
  return LotMovementCubit(
    establishmentId: establishmentId,
    initialAnimalId: animalId,
    sourceLotId: sourceLotId,
    loadContext: LoadMovementContextUseCase(repository),
    saveMovement: SaveLotMovementUseCase(repository, createId: generateUuidV4),
    retryMovement: RetryLotMovementUseCase(repository),
  );
}
