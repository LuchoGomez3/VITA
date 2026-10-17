import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/current_location_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/get_current_location_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/register_establishment_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_draft_validation.dart';

void main() {
  group('RegisterEstablishmentBloc', () {
    late _FakeEstablishmentRegistrationRepository repository;
    late _FakeCurrentLocationRepository locationRepository;
    late RegisterEstablishmentBloc bloc;

    setUp(() {
      repository = _FakeEstablishmentRegistrationRepository();
      locationRepository = _FakeCurrentLocationRepository();
      bloc = RegisterEstablishmentBloc(
        registerEstablishmentUseCase: RegisterEstablishmentUseCase(repository),
        getCurrentLocationUseCase: GetCurrentLocationUseCase(locationRepository),
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
        getCurrentLocationUseCase: GetCurrentLocationUseCase(locationRepository),
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

    test('fills the coordinates with the GPS reading', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RegisterEstablishmentState>().having(
            (state) => state.locationResult,
            'locationResult',
            isA<Loading<CurrentLocation>>(),
          ),
          isA<RegisterEstablishmentState>()
              .having((state) => state.locationResult, 'locationResult', isA<Data<CurrentLocation>>())
              .having((state) => state.draft.latitud, 'latitud', -32.1234)
              .having((state) => state.draft.longitud, 'longitud', -63.5678)
              .having((state) => state.draft.ubicacionConfirmadaPorGps, 'ubicacionConfirmadaPorGps', isTrue),
        ]),
      );

      bloc.add(const RegisterEstablishmentEvent.currentLocationRequested());

      await expectation;
      expect(locationRepository.calls, 1);
    });

    test('keeps the draft unconfirmed when the GPS reading fails', () async {
      locationRepository.result = const Result.failure(
        DomainException(
          message: 'sin señal',
          reason: CurrentLocationFailure.timeout,
        ),
      );

      bloc.add(const RegisterEstablishmentEvent.currentLocationRequested());

      await Future<void>.delayed(Duration.zero);
      expect(
        bloc.state.locationResult,
        isA<ResultError<CurrentLocation>>().having(
          (result) => result.error.reason,
          'reason',
          CurrentLocationFailure.timeout,
        ),
      );
      expect(bloc.state.draft.ubicacionConfirmadaPorGps, isFalse);
      expect(bloc.state.draft.isLocationStepValid, isFalse);
    });

    test('submits the GPS coordinates read in step 3', () async {
      bloc
        ..add(
          RegisterEstablishmentEvent.draftChanged(
            _validDraft(bloc.state.draft).copyWith(ubicacionConfirmadaPorGps: false),
          ),
        )
        ..add(const RegisterEstablishmentEvent.currentLocationRequested());
      await Future<void>.delayed(Duration.zero);

      bloc.add(const RegisterEstablishmentEvent.submitRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.submitResult, isA<Data<RegisteredEstablishment>>());
      expect(repository.lastRegistration?.latitud, -32.1234);
      expect(repository.lastRegistration?.longitud, -63.5678);
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

    group('boundary polygon (step 4)', () {
      test('adds vertices in drawing order', () async {
        bloc
          ..add(const RegisterEstablishmentEvent.boundaryPointAdded(_a))
          ..add(const RegisterEstablishmentEvent.boundaryPointAdded(_b));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.draft.poligono, [_a, _b]);
      });

      test('undo removes the last added vertex, one step at a time', () async {
        bloc
          ..add(const RegisterEstablishmentEvent.boundaryPointAdded(_a))
          ..add(const RegisterEstablishmentEvent.boundaryPointAdded(_b))
          ..add(const RegisterEstablishmentEvent.boundaryUndoRequested());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.draft.poligono, [_a]);

        bloc
          ..add(const RegisterEstablishmentEvent.boundaryUndoRequested())
          ..add(const RegisterEstablishmentEvent.boundaryUndoRequested());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.draft.poligono, isEmpty);
        expect(bloc.state.boundaryHistory, isEmpty);
      });

      test('undo reverts a whole drag, not each of its moves', () async {
        const moved1 = BoundaryPoint(latitud: -33.61, longitud: -64.57);
        const moved2 = BoundaryPoint(latitud: -33.615, longitud: -64.565);
        bloc
          ..add(const RegisterEstablishmentEvent.boundaryPointAdded(_a))
          ..add(const RegisterEstablishmentEvent.boundaryPointAdded(_b))
          ..add(const RegisterEstablishmentEvent.boundaryPointAdded(_c))
          ..add(const RegisterEstablishmentEvent.boundaryPointMoveStarted())
          ..add(const RegisterEstablishmentEvent.boundaryPointMoved(2, moved1))
          ..add(const RegisterEstablishmentEvent.boundaryPointMoved(2, moved2));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.draft.poligono, [_a, _b, moved2]);

        bloc.add(const RegisterEstablishmentEvent.boundaryUndoRequested());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.draft.poligono, [_a, _b, _c]);
      });

      test('ignores a move for a vertex that does not exist', () async {
        bloc
          ..add(const RegisterEstablishmentEvent.boundaryPointAdded(_a))
          ..add(const RegisterEstablishmentEvent.boundaryPointMoved(3, _b));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.draft.poligono, [_a]);
      });

      test('clear removes every vertex and can be undone', () async {
        bloc
          ..add(const RegisterEstablishmentEvent.boundaryPointAdded(_a))
          ..add(const RegisterEstablishmentEvent.boundaryPointAdded(_b))
          ..add(const RegisterEstablishmentEvent.boundaryCleared());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.draft.poligono, isEmpty);

        bloc.add(const RegisterEstablishmentEvent.boundaryUndoRequested());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.draft.poligono, [_a, _b]);
      });

      test('marks a vertex where the GPS is, without touching the step 3 location', () async {
        bloc.add(const RegisterEstablishmentEvent.boundaryPointFromGpsRequested());
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.boundaryGpsResult, isA<Data<CurrentLocation>>());
        expect(bloc.state.draft.poligono, [const BoundaryPoint(latitud: -32.1234, longitud: -63.5678)]);
        expect(bloc.state.locationResult, isA<Initial<CurrentLocation>>());
        expect(bloc.state.draft.ubicacionConfirmadaPorGps, isFalse);
        expect(locationRepository.calls, 1);
      });

      test('keeps the polygon unchanged when the GPS vertex reading fails', () async {
        bloc.add(const RegisterEstablishmentEvent.boundaryPointAdded(_a));
        await Future<void>.delayed(Duration.zero);
        locationRepository.result = const Result.failure(
          DomainException(message: 'gps apagado', reason: CurrentLocationFailure.serviceDisabled),
        );

        bloc.add(const RegisterEstablishmentEvent.boundaryPointFromGpsRequested());
        await Future<void>.delayed(Duration.zero);

        expect(
          bloc.state.boundaryGpsResult,
          isA<ResultError<CurrentLocation>>().having(
            (result) => result.error.reason,
            'reason',
            CurrentLocationFailure.serviceDisabled,
          ),
        );
        expect(bloc.state.draft.poligono, [_a]);
        expect(bloc.state.locationResult, isA<Initial<CurrentLocation>>());
      });

      test('submits the drawn polygon and its area as the surface', () async {
        bloc.add(RegisterEstablishmentEvent.draftChanged(_validDraft(bloc.state.draft)));
        for (final point in [_a, _b, _c, _d]) {
          bloc.add(RegisterEstablishmentEvent.boundaryPointAdded(point));
        }
        await Future<void>.delayed(Duration.zero);

        bloc.add(const RegisterEstablishmentEvent.submitRequested());
        await Future<void>.delayed(Duration.zero);

        final sent = repository.lastRegistration!;
        expect(sent.poligono, [_a, _b, _c, _d]);
        expect(sent.superficieHectareas, bloc.state.draft.superficieHectareas);
        expect(sent.superficieHectareas, isNot(320));
      });

      test('submits the hand-entered surface with no polygon', () async {
        bloc.add(RegisterEstablishmentEvent.draftChanged(_validDraft(bloc.state.draft)));
        await Future<void>.delayed(Duration.zero);

        bloc.add(const RegisterEstablishmentEvent.submitRequested());
        await Future<void>.delayed(Duration.zero);

        expect(repository.lastRegistration?.poligono, isEmpty);
        expect(repository.lastRegistration?.superficieHectareas, 320);
      });

      test('does not submit a polygon whose sides cross', () async {
        bloc.add(RegisterEstablishmentEvent.draftChanged(_validDraft(bloc.state.draft)));
        for (final point in [_a, _c, _b, _d]) {
          bloc.add(RegisterEstablishmentEvent.boundaryPointAdded(point));
        }
        await Future<void>.delayed(Duration.zero);

        bloc.add(const RegisterEstablishmentEvent.submitRequested());
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.submitResult, isA<ResultError<RegisteredEstablishment>>());
        expect(repository.registerCalls, 0);
      });
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
    superficieManualHectareas: 320,
  );
}

const _a = BoundaryPoint(latitud: -33.60, longitud: -64.60);
const _b = BoundaryPoint(latitud: -33.60, longitud: -64.58);
const _c = BoundaryPoint(latitud: -33.62, longitud: -64.58);
const _d = BoundaryPoint(latitud: -33.62, longitud: -64.60);

class _FakeEstablishmentRegistrationRepository implements EstablishmentRegistrationRepository {
  int registerCalls = 0;
  EstablishmentRegistration? lastRegistration;

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
      ),
      createdAt: DateTime(2025, 3, 14),
      role: UserRole.owner,
    ),
  );

  @override
  Future<Result<RegisteredEstablishment>> register(
    EstablishmentRegistration registration,
  ) async {
    registerCalls += 1;
    lastRegistration = registration;
    return result;
  }
}

class _FakeCurrentLocationRepository implements CurrentLocationRepository {
  int calls = 0;

  Result<CurrentLocation> result = const Result.success(
    CurrentLocation(latitud: -32.1234, longitud: -63.5678, precisionMetros: 6),
  );

  @override
  Future<Result<CurrentLocation>> getCurrentLocation() async {
    calls += 1;
    return result;
  }
}
