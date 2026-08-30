import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/animal_register/data/datasources/animal_registration_offline_context.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_registration_repository_impl.dart';
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
}) {
  // TODO(agusf): inyectar el proveedor del establecimiento activo,
  // BrickCategoriaStore y BrickAnimalStore cuando categorias y genealogia
  // tengan catalogos offline reales.
  final registrationContext = AnimalRegistrationOfflineContext(
    storage: const FlutterSecureStorageService(),
    lotStore: BrickLotStore.instance,
  );
  final repository = AnimalRegistrationRepositoryImpl(
    brickStore: BrickAnimalStore.instance,
  );

  return RegisterAnimalBloc(
    initialStep: initialStep,
    initialRfid: initialRfid,
    registerAnimalUseCase: RegisterAnimalUseCase(repository),
    registrationContext: registrationContext,
  )..add(const RegisterAnimalEvent.destinationsRequested());
}
