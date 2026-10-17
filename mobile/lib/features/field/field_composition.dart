import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/field/data/repositories/field_establishment_repository_impl.dart';
import 'package:frontend_mayoral/features/field/data/repositories/lot_animal_movement_repository_impl.dart';
import 'package:frontend_mayoral/features/field/data/repositories/lot_animal_repository_impl.dart';
import 'package:frontend_mayoral/features/field/data/repositories/lot_repository_impl.dart';
import 'package:frontend_mayoral/features/field/data/services/turf_lot_overlap_validator.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/services/local_lot_boundary_validator.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/delete_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_available_destination_lots_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_field_establishments_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_animal_counts_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_animals_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lots_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/save_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/update_lot_details_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/validate_lot_placement_use_case.dart';
import 'package:frontend_mayoral/features/field/presentation/bloc/lot_editor_bloc.dart';
import 'package:frontend_mayoral/features/field/presentation/cubit/lot_detail_cubit.dart';
import 'package:frontend_mayoral/features/field/presentation/cubit/lot_overview_cubit.dart';

/// Crea el BLoC de la Fase 1 con el adaptador geométrico seleccionado.
LotEditorBloc createLotEditorBloc({
  required String establishmentId,
  required List<Lot> existingLots,
}) {
  const validator = LocalLotBoundaryValidator();
  const overlapValidator = TurfLotOverlapValidator();
  final repository = LotRepositoryImpl(store: BrickLotStore.instance);
  return LotEditorBloc(
    validatePlacement: const ValidateLotPlacementUseCase(
      boundaryValidator: validator,
      overlapValidator: overlapValidator,
    ),
    saveLot: SaveLotUseCase(
      repository: repository,
      validator: validator,
      overlapValidator: overlapValidator,
      createId: generateUuidV4,
    ),
    establishmentId: establishmentId,
    existingLots: existingLots,
  );
}

/// Crea el visor desde catálogos y lotes exclusivamente locales.
LotOverviewCubit createLotOverviewCubit() {
  // TODO(field-permissions): adaptar acciones cuando Producto y backend cierren
  // los tres roles finales. Backend seguirá siendo la autoridad de permisos.
  final lotRepository = LotRepositoryImpl(store: BrickLotStore.instance);
  final animalRepository = LotAnimalRepositoryImpl(
    store: BrickAnimalStore.instance,
  );
  const establishmentRepository = FieldEstablishmentRepositoryImpl(
    FlutterSecureStorageService(),
  );
  return LotOverviewCubit(
    getEstablishments: const GetFieldEstablishmentsUseCase(
      establishmentRepository,
    ),
    getLots: GetLotsUseCase(lotRepository),
    getAnimalCounts: GetLotAnimalCountsUseCase(animalRepository),
  );
}

/// Construye el estado completo de una ficha de lote.
LotDetailCubit createLotDetailCubit(String lotId) {
  final lotRepository = LotRepositoryImpl(store: BrickLotStore.instance);
  final animalRepository = LotAnimalRepositoryImpl(
    store: BrickAnimalStore.instance,
  );
  final movementRepository = LotAnimalMovementRepositoryImpl(
    animalStore: BrickAnimalStore.instance,
    lotStore: BrickLotStore.instance,
    movementStore: BrickAnimalLotMovementStore.instance,
  );
  return LotDetailCubit(
    lotId: lotId,
    getLot: GetLotUseCase(lotRepository),
    getAvailableDestinations: GetAvailableDestinationLotsUseCase(
      lotRepository,
    ),
    getAnimals: GetLotAnimalsUseCase(animalRepository),
    moveAnimals: MoveLotAnimalsUseCase(
      lotRepository: lotRepository,
      movementRepository: movementRepository,
      createId: generateUuidV4,
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
}
