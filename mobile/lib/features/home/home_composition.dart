import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/home/data/repositories/home_dashboard_repository_impl.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_establishments_use_case.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/sync/sync_composition.dart';

/// Construye el cubit del tablero con sus dependencias offline-first.
HomeDashboardCubit createHomeDashboardCubit() {
  final syncCoordinator = createOfflineSyncCoordinator();
  final repository = HomeDashboardRepositoryImpl(
    animalStore: BrickAnimalStore.instance,
    categoryStore: BrickCategoriaStore.instance,
    pesajeStore: BrickPesajeStore.instance,
    secureStorage: const FlutterSecureStorageService(),
    operatingExpenseStore: BrickOperatingExpenseStore.instance,
  );
  return HomeDashboardCubit(
    getHomeDashboardUseCase: GetHomeDashboardUseCase(repository),
    getHomeEstablishmentsUseCase: GetHomeEstablishmentsUseCase(repository),
    refreshOfflineData: syncCoordinator.synchronize,
    syncResults: syncCoordinator.results,
    connectivityChanges: Connectivity().onConnectivityChanged
        .map(
          (results) => results.any(
            (result) => result != ConnectivityResult.none,
          ),
        )
        .distinct(),
  );
}
