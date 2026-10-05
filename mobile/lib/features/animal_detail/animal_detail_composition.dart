import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_observation_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/storage/animal_photo_store.dart';
import 'package:frontend_mayoral/features/animal_detail/data/datasources/animal_detail_remote_data_source.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_detail_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/retry_animal_sync_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/save_animal_detail_change_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';

/// Crea el Cubit de detalle de animal con dependencias offline-first.
///
/// La feature lee primero desde Brick/SQLite y usa el backend como fallback cuando
/// el animal aun no esta cacheado en el dispositivo.
AnimalDetailCubit createAnimalDetailCubit() {
  final repository = AnimalDetailRepositoryImpl(
    movementStore: BrickAnimalLotMovementStore.instance,
    lotStore: BrickLotStore.instance,
    observationStore: BrickAnimalObservationStore.instance,
    photoStore: const AnimalPhotoStore(),
    brickStore: BrickAnimalStore.instance,
    categoriaBrickStore: BrickCategoriaStore.instance,
    pesajeBrickStore: BrickPesajeStore.instance,
    remoteDataSource: AnimalDetailRemoteDataSource(
      tokenProvider: SessionBackendAccessTokenProvider.instance,
    ),
    remoteEnabled: !AppConfig.demoMode,
  );

  return AnimalDetailCubit(
    getAnimalDetailUseCase: GetAnimalDetailUseCase(repository),
    saveChangeUseCase: SaveAnimalDetailChangeUseCase(repository),
    retryAnimalSyncUseCase: RetryAnimalSyncUseCase(repository),
  );
}
