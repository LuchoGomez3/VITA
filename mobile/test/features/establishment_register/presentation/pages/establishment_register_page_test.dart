import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/restore_session_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/current_location_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/get_current_location_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/register_establishment_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/pages/establishment_register_page.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';

void main() {
  testWidgets('an expired session signs out (so the router asks to log in) instead of staying in the wizard', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final authSessionCubit = AuthSessionCubit(
      restoreSessionUseCase: RestoreSessionUseCase(authRepository),
      signOutUseCase: SignOutUseCase(authRepository),
    );
    addTearDown(authSessionCubit.close);
    late RegisterEstablishmentBloc bloc;

    await tester.pumpWidget(
      BlocProvider.value(
        value: authSessionCubit,
        child: MaterialApp(
          home: EstablishmentRegisterPage(
            initialStep: RegisterEstablishmentStep.review,
            showSatelliteImagery: false,
            createBloc: ({initialStep = RegisterEstablishmentStep.identification}) {
              return bloc = RegisterEstablishmentBloc(
                registerEstablishmentUseCase: RegisterEstablishmentUseCase(_ExpiredSessionRepository()),
                getCurrentLocationUseCase: GetCurrentLocationUseCase(_UnusedLocationRepository()),
                initialStep: initialStep,
              )..add(RegisterEstablishmentEvent.draftChanged(_validDraft));
            },
          ),
        ),
      ),
    );
    await tester.pump();

    bloc.add(const RegisterEstablishmentEvent.submitRequested());
    await tester.pump();
    await tester.pump();

    expect(authRepository.signOutCalls, 1);
    expect(authSessionCubit.state, isA<AuthSessionUnauthenticated>());
    expect(find.text(EstablishmentRegisterStrings.sessionExpiredMessage), findsOneWidget);
  });
}

final RegisterEstablishmentDraft _validDraft = RegisterEstablishmentDraft.initial().copyWith(
  nombre: 'Prueba',
  tiposProduccion: {'Cría'},
  cuitTitular: '20-12345678-6',
  nroRenspa: '07.123.0.00456/01',
  provincia: 'Córdoba',
  departamento: 'Río Cuarto',
  localidad: 'Coronel Moldes',
  latitud: -33.61,
  longitud: -64.59,
  ubicacionConfirmadaPorGps: true,
  superficieManualHectareas: 320,
);

class _ExpiredSessionRepository implements EstablishmentRegistrationRepository {
  @override
  Future<Result<RegisteredEstablishment>> register(EstablishmentRegistration registration) async {
    return const Result.failure(
      DomainException(message: 'La sesion expiro. Inicia sesion nuevamente.', code: DomainErrorCode.unauthorized),
    );
  }
}

class _UnusedLocationRepository implements CurrentLocationRepository {
  @override
  Future<Result<CurrentLocation>> getCurrentLocation() => throw UnimplementedError();
}

class _FakeAuthRepository implements AuthRepository {
  int signOutCalls = 0;

  @override
  Future<void> signOut() async => signOutCalls += 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}
