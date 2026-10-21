import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/animal_movement/data/repositories/animal_movement_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/use_cases/animal_movement_use_cases.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/group_movement_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/movement_history_cubit.dart';
import 'package:frontend_mayoral/features/field/data/repositories/lot_animal_movement_repository_impl.dart';
import 'package:frontend_mayoral/features/field/data/repositories/lot_repository_impl.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';

/// Repositorio offline de movimientos; también lo usa el lector de caravanas.
AnimalMovementRepositoryImpl createAnimalMovementRepository() => AnimalMovementRepositoryImpl(
  animalStore: BrickAnimalStore.instance,
  lotStore: BrickLotStore.instance,
  categoryStore: BrickCategoriaStore.instance,
  movementStore: BrickAnimalLotMovementStore.instance,
);

/// Construye el cubit del historial de potreros de la ficha.
MovementHistoryCubit createMovementHistoryCubit() =>
    MovementHistoryCubit(GetAnimalMovementHistoryUseCase(createAnimalMovementRepository()));

/// Construye el cubit de "Mover animales" sobre el movimiento entre lotes de
/// "Campo y potreros" (mismo registro offline y misma sincronización).
GroupMovementCubit createGroupMovementCubit() {
  final repository = createAnimalMovementRepository();
  return GroupMovementCubit(
    prepare: PrepareGroupMovementUseCase(repository),
    resolveTag: ResolveMovementTagUseCase(repository),
    register: RegisterGroupMovementUseCase(
      MoveLotAnimalsUseCase(
        lotRepository: LotRepositoryImpl(store: BrickLotStore.instance),
        movementRepository: LotAnimalMovementRepositoryImpl(
          animalStore: BrickAnimalStore.instance,
          lotStore: BrickLotStore.instance,
          movementStore: BrickAnimalLotMovementStore.instance,
        ),
        createId: generateUuidV4,
      ),
    ),
  );
}
