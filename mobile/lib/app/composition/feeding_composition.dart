import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/feeding_record_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/food_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_forage_period_brick_store.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_feeding_cubit.dart';
import 'package:frontend_mayoral/features/feeding/data/repositories/feeding_history_repository_impl.dart';
import 'package:frontend_mayoral/features/feeding/data/repositories/feeding_register_repository_impl.dart';
import 'package:frontend_mayoral/features/feeding/domain/use_cases/feeding_use_cases.dart';
import 'package:frontend_mayoral/features/feeding/presentation/cubit/register_feeding_cubit.dart';

/// Construye el cubit de la pestaña Alimentación de la ficha.
AnimalFeedingCubit createAnimalFeedingCubit() => AnimalFeedingCubit(
  GetAnimalFeedingHistoryUseCase(
    FeedingHistoryRepositoryImpl(
      animalStore: BrickAnimalStore.instance,
      movementStore: BrickAnimalLotMovementStore.instance,
      lotStore: BrickLotStore.instance,
      periodStore: BrickLotForagePeriodStore.instance,
      foodStore: BrickFoodStore.instance,
      recordStore: BrickFeedingRecordStore.instance,
      localChanges: AppBrickRepository.instance.localChanges,
    ),
  ),
);

/// Construye el cubit de "Registrar alimentación".
RegisterFeedingCubit createRegisterFeedingCubit() {
  final repository = FeedingRegisterRepositoryImpl(
    animalStore: BrickAnimalStore.instance,
    categoryStore: BrickCategoriaStore.instance,
    lotStore: BrickLotStore.instance,
    foodStore: BrickFoodStore.instance,
    recordStore: BrickFeedingRecordStore.instance,
  );
  return RegisterFeedingCubit(
    prepare: PrepareFeedingFormUseCase(repository),
    resolveTag: ResolveFeedingTagUseCase(repository),
    register: RegisterFeedingUseCase(repository: repository, createId: generateUuidV4),
  );
}
