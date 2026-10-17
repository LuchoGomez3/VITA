import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/livestock/data/repositories/animal_list_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_animal_list_use_case.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/animal_list_cubit.dart';

/// Construye el cubit de la lista de animales sobre los stores locales.
AnimalListCubit createAnimalListCubit() {
  final repository = AnimalListRepositoryImpl(
    animalStore: BrickAnimalStore.instance,
    pesajeStore: BrickPesajeStore.instance,
    categoryStore: BrickCategoriaStore.instance,
    lotStore: BrickLotStore.instance,
    establishmentCatalog: const EstablishmentCatalog(secureStorage: FlutterSecureStorageService()),
  );
  return AnimalListCubit(
    getAnimalListUseCase: GetAnimalListUseCase(repository),
    getEstablishmentsUseCase: GetAnimalListEstablishmentsUseCase(repository),
  );
}
