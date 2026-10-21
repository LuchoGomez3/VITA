import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/animal_movement/animal_movement_composition.dart';
import 'package:frontend_mayoral/features/quick_read/data/repositories/quick_read_repository_impl.dart';
import 'package:frontend_mayoral/features/quick_read/domain/use_cases/quick_read_use_cases.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/cubit/quick_read_cubit.dart';

/// Construye el cubit del lector de caravanas (todo se lee del celular).
QuickReadCubit createQuickReadCubit() {
  final repository = QuickReadRepositoryImpl(
    movementRepository: createAnimalMovementRepository(),
    animalStore: BrickAnimalStore.instance,
    pesajeStore: BrickPesajeStore.instance,
    establishmentCatalog: const EstablishmentCatalog(secureStorage: FlutterSecureStorageService()),
  );
  return QuickReadCubit(
    resolveTag: ResolveQuickReadTagUseCase(repository),
    refresh: RefreshQuickReadUseCase(repository),
    getEstablishments: GetQuickReadEstablishmentsUseCase(repository),
  );
}
