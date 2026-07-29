import 'package:frontend_mayoral/features/establishment_register/data/repositories/establishment_registration_mock_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/register_establishment_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';

/// Crea el BLoC del flujo de registro de establecimiento con sus dependencias actuales.
///
/// Este archivo funciona como composition root temporal de la feature, igual
/// que `animal_register_composition.dart`.
///
// TODO(lucho): Reemplazar el repositorio mock por la implementacion real
// (Etapa 3, ver .claude/specs/registrar-establecimiento.md) y este wiring
// manual por la estrategia de DI que se adopte para toda la app.
RegisterEstablishmentBloc createRegisterEstablishmentBloc({
  RegisterEstablishmentStep initialStep = RegisterEstablishmentStep.identification,
}) {
  final repository = EstablishmentRegistrationMockRepository();

  return RegisterEstablishmentBloc(
    initialStep: initialStep,
    registerEstablishmentUseCase: RegisterEstablishmentUseCase(repository),
  );
}
