import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/features/establishment_register/data/repositories/establishment_registration_repository_impl.dart';
import 'package:frontend_mayoral/features/establishment_register/data/sources/establishment_registration_remote_data_source.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/register_establishment_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:http/http.dart' as http;

/// Crea el BLoC del flujo de registro de establecimiento con sus dependencias actuales.
///
/// Este archivo funciona como composition root temporal de la feature, igual
/// que `auth_composition.dart`.
///
// TODO(agustin): Reemplazar este wiring manual por la estrategia de DI que se
// adopte para toda la app.
RegisterEstablishmentBloc createRegisterEstablishmentBloc({
  RegisterEstablishmentStep initialStep = RegisterEstablishmentStep.identification,
}) {
  final client = http.Client();
  final repository = EstablishmentRegistrationRepositoryImpl(
    remoteDataSource: EstablishmentRegistrationRemoteDataSource(
      backendBaseUrl: AppConfig.current.backendBaseUrl,
      tokenProvider: SessionBackendAccessTokenProvider.instance,
      client: client,
    ),
  );

  return RegisterEstablishmentBloc(
    initialStep: initialStep,
    registerEstablishmentUseCase: RegisterEstablishmentUseCase(repository),
    onClose: client.close,
  );
}
