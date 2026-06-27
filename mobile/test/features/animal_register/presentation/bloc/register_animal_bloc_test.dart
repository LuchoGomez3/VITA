import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_register/data/sources/animal_registration_mock_context.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_repository.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/register_animal_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';

void main() {
  group('RegisterAnimalBloc', () {
    late _FakeAnimalRegistrationRepository repository;
    late RegisterAnimalBloc bloc;

    setUp(() {
      repository = _FakeAnimalRegistrationRepository();
      bloc = RegisterAnimalBloc(
        registerAnimalUseCase: RegisterAnimalUseCase(repository),
        registrationContext: const AnimalRegistrationMockContext(),
      );
      addTearDown(bloc.close);
    });

    test('updates the registration draft', () async {
      final updatedDraft = bloc.state.draft.copyWith(
        rfid: '982000412991416',
      );
      final expectedState = bloc.state.copyWith(draft: updatedDraft);

      final expectation = expectLater(bloc.stream, emits(expectedState));
      bloc.add(RegisterAnimalEvent.draftChanged(updatedDraft));

      await expectation;
    });

    test('moves forward and backward through the flow', () async {
      final forwardState = bloc.state.copyWith(
        currentStep: RegisterAnimalStep.basicData,
      );
      final backwardState = bloc.state;

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([forwardState, backwardState]),
      );
      bloc
        ..add(const RegisterAnimalEvent.nextStepRequested())
        ..add(const RegisterAnimalEvent.previousStepRequested());

      await expectation;
    });

    test('does not advance beyond review', () async {
      final reviewBloc = RegisterAnimalBloc(
        initialStep: RegisterAnimalStep.review,
        registerAnimalUseCase: RegisterAnimalUseCase(repository),
        registrationContext: const AnimalRegistrationMockContext(),
      );
      addTearDown(reviewBloc.close);

      reviewBloc.add(const RegisterAnimalEvent.nextStepRequested());

      await Future<void>.delayed(Duration.zero);
      expect(reviewBloc.state.currentStep, RegisterAnimalStep.review);
    });

    test('submits a valid draft and emits loading then data', () async {
      final expectedResult = ResultState<RegisteredAnimal>.data(
        RegisteredAnimal(
          id: 'local-id',
          registration: AnimalRegistration(
            rfidTagNumber: '982000412991416',
            visualTag: '003 1295',
            sex: AnimalSex.female,
            breed: 'Aberdeen Angus',
            birthDate: DateTime(2025, 3, 14),
            lotId: '62af91d7-307d-4a07-b2bd-b2d8976ec91a',
            lotName: 'La Cumbre',
            establishmentId: '8b75eb38-8b0f-44dc-979f-89ce2817b63d',
            categoryId: 'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8',
            categoryName: 'Ternera',
            initialWeight: 32.5,
            motherId: '56fb8531-13f7-41c6-a1e1-85ea9b7094fa',
            weighingDate: DateTime(2025, 3, 14),
          ),
          syncStatus: AnimalSyncStatus.pending,
          createdAt: DateTime(2025, 3, 14),
          updatedAt: DateTime(2025, 3, 14),
          displayDestination: 'La Cumbre',
          displayCategory: 'Ternera',
        ),
      );

      final draft = bloc.state.draft.copyWith(
        rfid: '982000412991416',
        visualTagSeries: '003',
        visualTagNumber: '1295',
        birthWeight: '32,5',
      );
      bloc.add(RegisterAnimalEvent.draftChanged(draft));
      await Future<void>.delayed(Duration.zero);

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(
          isA<RegisterAnimalState>().having(
            (state) => state.submitResult,
            'submitResult',
            expectedResult,
          ),
        ),
      );

      bloc.add(const RegisterAnimalEvent.submitRequested());

      await expectation;
      expect(repository.registerCalls, 1);
    });

    test('does not submit when validation fails', () async {
      final draft = bloc.state.draft.copyWith(
        rfid: '123',
        birthWeight: '',
      );
      bloc.add(RegisterAnimalEvent.draftChanged(draft));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const RegisterAnimalEvent.submitRequested());

      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.submitResult, isA<ResultError<RegisteredAnimal>>());
      expect(repository.registerCalls, 0);
    });

    test('emits repository failures', () async {
      repository.result = const Result.failure(
        DomainException(
          message: 'sync failure',
          code: DomainErrorCode.offline,
        ),
      );

      final draft = bloc.state.draft.copyWith(
        rfid: '982000412991416',
        visualTagSeries: '003',
        visualTagNumber: '1295',
        birthWeight: '32.5',
      );
      bloc.add(RegisterAnimalEvent.draftChanged(draft));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const RegisterAnimalEvent.submitRequested());

      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.submitResult, isA<ResultError<RegisteredAnimal>>());
      expect(repository.registerCalls, 1);
    });
  });
}

class _FakeAnimalRegistrationRepository implements AnimalRegistrationRepository {
  int registerCalls = 0;

  Result<RegisteredAnimal> result = Result.success(
    RegisteredAnimal(
      id: 'local-id',
      registration: AnimalRegistration(
        rfidTagNumber: '982000412991416',
        visualTag: '003 1295',
        sex: AnimalSex.female,
        breed: 'Aberdeen Angus',
        birthDate: DateTime(2025, 3, 14),
        lotId: '62af91d7-307d-4a07-b2bd-b2d8976ec91a',
        lotName: 'La Cumbre',
        establishmentId: '8b75eb38-8b0f-44dc-979f-89ce2817b63d',
        categoryId: 'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8',
        categoryName: 'Ternera',
        initialWeight: 32.5,
        motherId: '56fb8531-13f7-41c6-a1e1-85ea9b7094fa',
        weighingDate: DateTime(2025, 3, 14),
      ),
      syncStatus: AnimalSyncStatus.pending,
      createdAt: DateTime(2025, 3, 14),
      updatedAt: DateTime(2025, 3, 14),
      displayDestination: 'La Cumbre',
      displayCategory: 'Ternera',
    ),
  );

  @override
  Future<Result<RegisteredAnimal>> register(
    AnimalRegistration registration,
  ) async {
    registerCalls += 1;
    return result;
  }
}
