import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/animal_register/data/datasources/animal_registration_offline_context.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_category_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_parent_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_registration_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_rfid_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/check_animal_rfid_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/get_animal_categories_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/get_animal_parents_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/register_animal_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';

/// Crea el BLoC del flujo de registro de animal con sus dependencias actuales.
///
/// Este archivo funciona como composition root temporal de la feature: conoce
/// data y Brick para que la page de presentation no importe implementaciones
/// concretas.
///
// TODO(agustin): Reemplazar este wiring manual cuando definamos la estrategia
// comun para crear BLoCs/repositories. Opciones probables: RepositoryProvider /
// MultiBlocProvider, providers a nivel router, o un container tipo get_it +
// injectable. En el flujo final, la page deberia conocer solo al BLoC.
RegisterAnimalBloc createRegisterAnimalBloc({
  RegisterAnimalStep initialStep = RegisterAnimalStep.identification,
  String initialRfid = '',
  String? initialEstablishmentId,
}) {
  final registrationContext = AnimalRegistrationOfflineContext(
    establishmentCatalog: const EstablishmentCatalog(
      secureStorage: FlutterSecureStorageService(),
    ),
    lotStore: BrickLotStore.instance,
  );
  final repository = AnimalRegistrationRepositoryImpl(
    brickStore: BrickAnimalStore.instance,
  );
  final categoryRepository = AnimalCategoryRepositoryImpl(
    store: BrickCategoriaStore.instance,
  );

  return RegisterAnimalBloc(
      initialStep: initialStep,
      initialRfid: initialRfid,
      initialEstablishmentId: initialEstablishmentId,
      registerAnimalUseCase: RegisterAnimalUseCase(repository),
      getAnimalCategoriesUseCase: GetAnimalCategoriesUseCase(categoryRepository),
      checkAnimalRfidUseCase: CheckAnimalRfidUseCase(
        AnimalRfidRepositoryImpl(store: BrickAnimalStore.instance),
      ),
      getAnimalParentsUseCase: GetAnimalParentsUseCase(
        AnimalParentRepositoryImpl(store: BrickAnimalStore.instance),
      ),
      registrationContext: registrationContext,
    )
    ..add(const RegisterAnimalEvent.categoriesRequested())
    ..add(const RegisterAnimalEvent.establishmentsRequested());
}
