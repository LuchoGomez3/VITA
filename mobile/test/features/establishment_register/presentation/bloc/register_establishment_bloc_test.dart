import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/register_establishment_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';

void main() {
  group('RegisterEstablishmentBloc', () {
    late _FakeEstablishmentRegistrationRepository repository;
    late RegisterEstablishmentBloc bloc;

    setUp(() {
      repository = _FakeEstablishmentRegistrationRepository();
      bloc = RegisterEstablishmentBloc(
        registerEstablishmentUseCase: RegisterEstablishmentUseCase(repository),
      );
      addTearDown(bloc.close);
    });

    test('updates the registration draft', () async {
      final updatedDraft = bloc.state.draft.copyWith(nombre: 'Estancia Nueva');
      final expectedState = bloc.state.copyWith(draft: updatedDraft);

      final expectation = expectLater(bloc.stream, emits(expectedState));
      bloc.add(RegisterEstablishmentEvent.draftChanged(updatedDraft));

      await expectation;
    });

    test('moves forward and backward through the flow', () async {
      final forwardState = bloc.state.copyWith(
        currentStep: RegisterEstablishmentStep.renspa,
      );
      final backwardState = bloc.state;

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([forwardState, backwardState]),
      );
      bloc
        ..add(const RegisterEstablishmentEvent.nextStepRequested())
        ..add(const RegisterEstablishmentEvent.previousStepRequested());

      await expectation;
    });

    test('does not advance beyond review', () async {
      final reviewBloc = RegisterEstablishmentBloc(
        initialStep: RegisterEstablishmentStep.review,
        registerEstablishmentUseCase: RegisterEstablishmentUseCase(repository),
      );
      addTearDown(reviewBloc.close);

      reviewBloc.add(const RegisterEstablishmentEvent.nextStepRequested());

      await Future<void>.delayed(Duration.zero);
      expect(reviewBloc.state.currentStep, RegisterEstablishmentStep.review);
    });

    test('does not go back before identification', () async {
      bloc.add(const RegisterEstablishmentEvent.previousStepRequested());

      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.currentStep, RegisterEstablishmentStep.identification);
    });

    test('jumps directly to a requested step', () async {
      bloc.add(
        const RegisterEstablishmentEvent.stepRequested(
          RegisterEstablishmentStep.surface,
        ),
      );

      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.currentStep, RegisterEstablishmentStep.surface);
    });

    test('submits a valid draft and emits loading then data', () async {
      bloc.add(RegisterEstablishmentEvent.draftChanged(_validDraft(bloc.state.draft)));
      await Future<void>.delayed(Duration.zero);

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(
          isA<RegisterEstablishmentState>().having(
            (state) => state.submitResult,
            'submitResult',
            isA<Data<RegisteredEstablishment>>(),
          ),
        ),
      );

      bloc.add(const RegisterEstablishmentEvent.submitRequested());

      await expectation;
      expect(repository.registerCalls, 1);
    });

    test('does not submit when a step is incomplete', () async {
      bloc.add(const RegisterEstablishmentEvent.submitRequested());

      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.submitResult, isA<ResultError<RegisteredEstablishment>>());
      expect(repository.registerCalls, 0);
    });

    test('does not submit when the location is still the GPS mock value', () async {
      final draft = _validDraft(bloc.state.draft).copyWith(
        latitud: mockLocationLatitud,
        longitud: mockLocationLongitud,
        ubicacionConfirmadaPorGps: true,
      );
      bloc.add(RegisterEstablishmentEvent.draftChanged(draft));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const RegisterEstablishmentEvent.submitRequested());

      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.submitResult, isA<ResultError<RegisteredEstablishment>>());
      expect(repository.registerCalls, 0);
    });

    test('emits repository failures', () async {
      repository.result = const Result.failure(
        DomainException(message: 'sin conexion', code: DomainErrorCode.offline),
      );

      bloc.add(RegisterEstablishmentEvent.draftChanged(_validDraft(bloc.state.draft)));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const RegisterEstablishmentEvent.submitRequested());

      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.submitResult, isA<ResultError<RegisteredEstablishment>>());
      expect(repository.registerCalls, 1);
    });

    test('clears a RENSPA conflict when the RENSPA changes', () async {
      repository.result = const Result.failure(
        DomainException(message: 'El RENSPA ya esta registrado.', code: DomainErrorCode.conflict),
      );

      bloc.add(RegisterEstablishmentEvent.draftChanged(_validDraft(bloc.state.draft)));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const RegisterEstablishmentEvent.submitRequested());
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state.submitResult,
        isA<ResultError<RegisteredEstablishment>>().having(
          (result) => result.error.code,
          'code',
          DomainErrorCode.conflict,
        ),
      );

      bloc.add(
        RegisterEstablishmentEvent.draftChanged(
          bloc.state.draft.copyWith(nroRenspa: '07.123.0.00456/02'),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.submitResult, isA<Initial<RegisteredEstablishment>>());
    });

    test('keeps a RENSPA conflict when an unrelated field changes', () async {
      repository.result = const Result.failure(
        DomainException(message: 'El RENSPA ya esta registrado.', code: DomainErrorCode.conflict),
      );

      bloc.add(RegisterEstablishmentEvent.draftChanged(_validDraft(bloc.state.draft)));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const RegisterEstablishmentEvent.submitRequested());
      await Future<void>.delayed(Duration.zero);

      bloc.add(
        RegisterEstablishmentEvent.draftChanged(
          bloc.state.draft.copyWith(nombre: 'Otro nombre'),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.submitResult, isA<ResultError<RegisteredEstablishment>>());
    });
  });
}

RegisterEstablishmentDraft _validDraft(RegisterEstablishmentDraft draft) {
  return draft.copyWith(
    nombre: 'Estancia La Sirena',
    tiposProduccion: {'Cría', 'Recría'},
    cuitTitular: '20-12345678-6',
    nroRenspa: '07.123.0.00456/01',
    provincia: 'Córdoba',
    departamento: 'Río Cuarto',
    localidad: 'Coronel Moldes',
    latitud: -31.4201,
    longitud: -64.1888,
    ubicacionConfirmadaPorGps: true,
  );
}

class _FakeEstablishmentRegistrationRepository implements EstablishmentRegistrationRepository {
  int registerCalls = 0;

  Result<RegisteredEstablishment> result = Result.success(
    RegisteredEstablishment(
      id: 'local-id',
      registration: const EstablishmentRegistration(
        nombre: 'La Sirena',
        descripcion: 'Cría y recría de Aberdeen Angus.',
        tiposProduccion: ['Cría', 'Recría'],
        cuitTitular: '20-21456789-3',
        nroRenspa: '07.123.0.00456/01',
        provincia: 'Córdoba',
        departamento: 'Río Cuarto',
        localidad: 'Coronel Moldes',
        latitud: -33.7242,
        longitud: -64.5891,
        superficieHectareas: 847,
        cantidadVertices: 7,
      ),
      createdAt: DateTime(2025, 3, 14),
    ),
  );

  @override
  Future<Result<RegisteredEstablishment>> register(
    EstablishmentRegistration registration,
  ) async {
    registerCalls += 1;
    return result;
  }
}
