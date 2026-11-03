import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/storage/animal_photo_store.dart';
import 'package:frontend_mayoral/features/animal_detail/data/datasources/animal_detail_remote_data_source.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_detail_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_genealogy_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_photo_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_genealogy_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_photo_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/retry_animal_sync_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_genealogy_cubit.dart';

/// Crea el Cubit de detalle de animal con dependencias offline-first.
///
/// La feature lee primero desde Brick/SQLite y usa el backend como fallback cuando
/// el animal aun no esta cacheado en el dispositivo.
AnimalDetailCubit createAnimalDetailCubit() {
  const photoStore = AnimalPhotoStore();
  final detailRepository = AnimalDetailRepositoryImpl(
    brickStore: BrickAnimalStore.instance,
    categoriaBrickStore: BrickCategoriaStore.instance,
    pesajeBrickStore: BrickPesajeStore.instance,
    lotBrickStore: BrickLotStore.instance,
    remoteDataSource: AnimalDetailRemoteDataSource(
      tokenProvider: SessionBackendAccessTokenProvider.instance,
    ),
  );
  const photoRepository = AnimalPhotoRepositoryImpl(photoStore: photoStore);

  return AnimalDetailCubit(
    getAnimalDetailUseCase: GetAnimalDetailUseCase(detailRepository),
    getAnimalPhotoUseCase: const GetAnimalPhotoUseCase(photoRepository),
    retryAnimalSyncUseCase: RetryAnimalSyncUseCase(detailRepository),
  );
}

/// Construye el Cubit de genealogía con lectura exclusivamente local.
AnimalGenealogyCubit createAnimalGenealogyCubit() {
  final repository = AnimalGenealogyRepositoryImpl(
    animalStore: BrickAnimalStore.instance,
    categoryStore: BrickCategoriaStore.instance,
  );
  return AnimalGenealogyCubit(GetAnimalGenealogyUseCase(repository));
}
