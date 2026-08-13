import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_registration_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_register/data/datasources/animal_registration_mock_context.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/register_animal_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';

/// Crea el BLoC del flujo de registro de animal con sus dependencias actuales.
///
/// Este archivo funciona como composition root temporal de la feature: conoce
/// data, Brick y mocks para que la page de presentation no tenga que importar
/// implementaciones concretas.
///
// TODO(agustin): Reemplazar este wiring manual cuando definamos la estrategia
// comun para crear BLoCs/repositories. Opciones probables: RepositoryProvider /
// MultiBlocProvider, providers a nivel router, o un container tipo get_it +
// injectable. En el flujo final, la page deberia conocer solo al BLoC. El mock
// de contexto tambien debe desaparecer cuando existan sesion, establecimiento
// seleccionado y catalogos sincronizados.
RegisterAnimalBloc createRegisterAnimalBloc({
  RegisterAnimalStep initialStep = RegisterAnimalStep.identification,
  String initialRfid = '',
}) {
  // TODO(agustin): Reemplazar este mock por un contexto real basado en sesion,
  // establecimiento seleccionado y catalogos sincronizados.
  const registrationContext = AnimalRegistrationMockContext();
  final repository = AnimalRegistrationRepositoryImpl(
    brickStore: BrickAnimalStore.instance,
  );

  return RegisterAnimalBloc(
    initialStep: initialStep,
    initialRfid: initialRfid,
    registerAnimalUseCase: RegisterAnimalUseCase(repository),
    registrationContext: registrationContext,
  );
}
