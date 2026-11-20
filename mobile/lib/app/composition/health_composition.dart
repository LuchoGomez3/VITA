import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/health_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/health/data/repositories/health_repository_impl.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_registration_cubit.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_result_cubit.dart';

/// Arma la capa de datos bajo la sesión autenticada actual.
HealthRepositoryImpl createHealthRepository({void Function()? onPending}) {
  final tokens = SessionBackendAccessTokenProvider.instance;
  return HealthRepositoryImpl(
    store: HealthBrickStore.instance!,
    animals: BrickAnimalStore.instance,
    memberships: const EstablishmentCatalog(secureStorage: FlutterSecureStorageService()),
    session: () => switch (tokens.userId) {
      final userId? => (userId: userId, generation: tokens.sessionGeneration),
      null => null,
    },
    onPending: onPending,
  );
}

/// Arma los casos de uso del historial en la ficha.
ReadHealthUseCase createHealthReader() => ReadHealthUseCase(createHealthRepository());

/// Arma el registro de ficha, lote o manga.
HealthRegistrationCubit createHealthRegistrationCubit() {
  final repository = createHealthRepository();
  return HealthRegistrationCubit(
    reader: ReadHealthUseCase(repository),
    register: RegisterHealthEventsUseCase(repository),
    establishments: repository.establishments,
  );
}

/// Arma la carga del primer resultado del estudio.
HealthResultCubit createHealthResultCubit() => HealthResultCubit(
  RecordHealthResultUseCase(createHealthRepository()),
);
