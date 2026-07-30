import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/initial_data_sync_repository_impl.dart';
import 'package:frontend_mayoral/features/sync/domain/use_cases/prepare_initial_data_sync_use_case.dart';
import 'package:http/http.dart' as http;

/// Crea el caso de uso que prepara los datos offline posteriores al login.
///
/// La composicion queda dentro de `features/sync` para que auth no conozca los
/// stores Brick ni el detalle de que tablas se hidratan durante el bootstrap.
PrepareInitialDataSyncUseCase createPrepareInitialDataSyncUseCase({
  required http.Client client,
}) {
  return PrepareInitialDataSyncUseCase(
    InitialDataSyncRepositoryImpl(
      secureStorage: const FlutterSecureStorageService(),
      establishmentRemoteDataSource: EstablishmentRemoteDataSource(
        backendBaseUrl: AppConfig.current.backendBaseUrl,
        tokenProvider: SessionBackendAccessTokenProvider.instance,
        client: client,
      ),
      animalStore: BrickAnimalStore.instance,
      categoryStore: BrickCategoriaStore.instance,
      weighingStore: BrickPesajeStore.instance,
    ),
  );
}
