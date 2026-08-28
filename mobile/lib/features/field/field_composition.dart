import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/field/data/repositories/field_establishment_repository_impl.dart';
import 'package:frontend_mayoral/features/field/data/repositories/lot_repository_impl.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/services/local_lot_boundary_validator.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_field_establishments_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lots_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/save_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/validate_lot_boundary_use_case.dart';
import 'package:frontend_mayoral/features/field/presentation/bloc/lot_editor_bloc.dart';
import 'package:frontend_mayoral/features/field/presentation/cubit/lot_overview_cubit.dart';

/// Crea el BLoC de la Fase 1 con el adaptador geométrico seleccionado.
LotEditorBloc createLotEditorBloc({
  required String establishmentId,
  required List<Lot> existingLots,
}) {
  const validator = LocalLotBoundaryValidator();
  final repository = LotRepositoryImpl(store: BrickLotStore.instance);
  return LotEditorBloc(
    validateBoundary: const ValidateLotBoundaryUseCase(validator),
    saveLot: SaveLotUseCase(
      repository: repository,
      validator: validator,
      createId: generateUuidV4,
    ),
    establishmentId: establishmentId,
    existingLots: existingLots,
  );
}

/// Crea el visor desde catálogos y lotes exclusivamente locales.
LotOverviewCubit createLotOverviewCubit() {
  final lotRepository = LotRepositoryImpl(store: BrickLotStore.instance);
  const establishmentRepository = FieldEstablishmentRepositoryImpl(
    FlutterSecureStorageService(),
  );
  return LotOverviewCubit(
    getEstablishments: const GetFieldEstablishmentsUseCase(
      establishmentRepository,
    ),
    getLots: GetLotsUseCase(lotRepository),
  );
}

/// Construye la consulta local usada por el detalle.
GetLotUseCase createGetLotUseCase() => GetLotUseCase(LotRepositoryImpl(store: BrickLotStore.instance));
