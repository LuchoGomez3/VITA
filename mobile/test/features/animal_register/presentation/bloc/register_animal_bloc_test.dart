import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_category.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_parent.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_category_repository.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_parent_repository.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_context.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_repository.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/get_animal_categories_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/get_animal_parents_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/register_animal_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';

void main() {
  group('RegisterAnimalBloc', () {
    late _FakeAnimalRegistrationRepository repository;
    late _FakeAnimalCategoryRepository categoryRepository;
    late RegisterAnimalBloc bloc;

    setUp(() {
      repository = _FakeAnimalRegistrationRepository();
      categoryRepository = _FakeAnimalCategoryRepository();
      bloc = RegisterAnimalBloc(
        registerAnimalUseCase: RegisterAnimalUseCase(repository),
        getAnimalParentsUseCase: GetAnimalParentsUseCase(_FakeAnimalParentRepository()),
        getAnimalCategoriesUseCase: GetAnimalCategoriesUseCase(
          categoryRepository,
        ),
        registrationContext: const _TestAnimalRegistrationContext(),
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

    test('initializes the draft with an RFID received from identification', () {
      final prefilledBloc = RegisterAnimalBloc(
        initialRfid: '982000412991416',
        registerAnimalUseCase: RegisterAnimalUseCase(repository),
        getAnimalParentsUseCase: GetAnimalParentsUseCase(_FakeAnimalParentRepository()),
        getAnimalCategoriesUseCase: GetAnimalCategoriesUseCase(
          categoryRepository,
        ),
        registrationContext: const _TestAnimalRegistrationContext(),
      );
      addTearDown(prefilledBloc.close);

      expect(prefilledBloc.state.draft.rfid, '982000412991416');
      expect(prefilledBloc.state.draft.categoryId, isNull);
      expect(prefilledBloc.state.draft.categoryName, isNull);
      expect(prefilledBloc.state.draft.mother, isNull);
      expect(prefilledBloc.state.draft.father, isNull);
    });

    test('loads global categories without preselecting one', () async {
      bloc.add(const RegisterAnimalEvent.categoriesRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.categories, _FakeAnimalCategoryRepository.categories);
      expect(bloc.state.draft.categoryId, isNull);
      expect(bloc.state.draft.categoryName, isNull);
    });

    test('represents category loading failures with ResultState', () async {
      categoryRepository.result = const Result.failure(
        DomainException(
          message: 'No se pudieron cargar las categorías guardadas.',
          code: DomainErrorCode.offline,
        ),
      );

      bloc.add(const RegisterAnimalEvent.categoriesRequested());
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state.categoriesState,
        isA<ResultError<List<AnimalCategory>>>(),
      );
      expect(bloc.state.categories, isEmpty);
    });

    test('represents an empty category catalog without a selection', () async {
      categoryRepository.result = const Result.success([]);

      bloc.add(const RegisterAnimalEvent.categoriesRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.categoriesState, const ResultState<List<AnimalCategory>>.data([]));
      expect(bloc.state.draft.categoryId, isNull);
      expect(bloc.state.draft.categoryName, isNull);
    });

    test('keeps a valid establishment received from identification', () async {
      final prefilledBloc = RegisterAnimalBloc(
        initialEstablishmentId: '8b75eb38-8b0f-44dc-979f-89ce2817b63d',
        registerAnimalUseCase: RegisterAnimalUseCase(repository),
        getAnimalParentsUseCase: GetAnimalParentsUseCase(_FakeAnimalParentRepository()),
        getAnimalCategoriesUseCase: GetAnimalCategoriesUseCase(
          categoryRepository,
        ),
        registrationContext: const _TestAnimalRegistrationContext(),
      );
      addTearDown(prefilledBloc.close);

      prefilledBloc.add(const RegisterAnimalEvent.establishmentsRequested());
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        prefilledBloc.state.draft.establishmentId,
        '8b75eb38-8b0f-44dc-979f-89ce2817b63d',
      );
      expect(prefilledBloc.state.draft.establishmentName, 'La Sirena');
      expect(prefilledBloc.state.destinations, isNotEmpty);
    });

    test('requires an explicit choice and loads lots from that establishment', () async {
      final context = _MultipleEstablishmentsContext();
      final selectionBloc = RegisterAnimalBloc(
        registerAnimalUseCase: RegisterAnimalUseCase(repository),
        getAnimalParentsUseCase: GetAnimalParentsUseCase(_FakeAnimalParentRepository()),
        getAnimalCategoriesUseCase: GetAnimalCategoriesUseCase(
          categoryRepository,
        ),
        registrationContext: context,
      );
      addTearDown(selectionBloc.close);

      selectionBloc.add(const RegisterAnimalEvent.establishmentsRequested());
      await Future<void>.delayed(Duration.zero);

      expect(selectionBloc.state.draft.establishmentId, isNull);

      selectionBloc.add(
        const RegisterAnimalEvent.establishmentSelected('establishment-2'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(selectionBloc.state.draft.establishmentId, 'establishment-2');
      expect(selectionBloc.state.draft.establishmentName, 'El Ombú');
      expect(context.destinationRequests, ['establishment-2']);
      expect(selectionBloc.state.destinations.single.name, 'Lote Sur');
    });

    test('keeps the selected global category when establishment changes', () async {
      final context = _MultipleEstablishmentsContext();
      final selectionBloc = RegisterAnimalBloc(
        registerAnimalUseCase: RegisterAnimalUseCase(repository),
        getAnimalParentsUseCase: GetAnimalParentsUseCase(_FakeAnimalParentRepository()),
        getAnimalCategoriesUseCase: GetAnimalCategoriesUseCase(
          categoryRepository,
        ),
        registrationContext: context,
      );
      addTearDown(selectionBloc.close);
      selectionBloc.add(const RegisterAnimalEvent.establishmentsRequested());
      await Future<void>.delayed(Duration.zero);
      selectionBloc.add(
        RegisterAnimalEvent.draftChanged(
          selectionBloc.state.draft.copyWith(
            categoryId: _FakeAnimalCategoryRepository.categories.single.id,
            categoryName: _FakeAnimalCategoryRepository.categories.single.name,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      selectionBloc.add(
        const RegisterAnimalEvent.establishmentSelected('establishment-2'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        selectionBloc.state.draft.categoryId,
        _FakeAnimalCategoryRepository.categories.single.id,
      );
      expect(
        selectionBloc.state.draft.categoryName,
        _FakeAnimalCategoryRepository.categories.single.name,
      );
    });

    test('loads local parents and clears selections when establishment changes', () async {
      final parents = _FakeAnimalParentRepository()
        ..result = const Result.success([
          AnimalParent(
            id: 'mother-id',
            visualTag: '003 0421',
            rfid: '982000412884421',
            breed: 'Aberdeen Angus',
            sex: AnimalSex.female,
          ),
        ]);
      final selectionBloc = RegisterAnimalBloc(
        registerAnimalUseCase: RegisterAnimalUseCase(repository),
        getAnimalCategoriesUseCase: GetAnimalCategoriesUseCase(categoryRepository),
        getAnimalParentsUseCase: GetAnimalParentsUseCase(parents),
        registrationContext: _MultipleEstablishmentsContext(),
      );
      addTearDown(selectionBloc.close);
      selectionBloc.add(const RegisterAnimalEvent.establishmentsRequested());
      await Future<void>.delayed(Duration.zero);
      selectionBloc.add(const RegisterAnimalEvent.establishmentSelected('establishment-1'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(parents.requestedEstablishments, ['establishment-1']);
      final mother = (selectionBloc.state.parentsState as Data<List<AnimalParent>>).data.single;
      selectionBloc.add(RegisterAnimalEvent.draftChanged(selectionBloc.state.draft.copyWith(mother: mother)));
      await Future<void>.delayed(Duration.zero);
      selectionBloc.add(const RegisterAnimalEvent.establishmentSelected('establishment-2'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(selectionBloc.state.draft.mother, isNull);
      expect(selectionBloc.state.draft.father, isNull);
      expect(parents.requestedEstablishments, ['establishment-1', 'establishment-2']);
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
        getAnimalParentsUseCase: GetAnimalParentsUseCase(_FakeAnimalParentRepository()),
        getAnimalCategoriesUseCase: GetAnimalCategoriesUseCase(
          categoryRepository,
        ),
        registrationContext: const _TestAnimalRegistrationContext(),
      );
      addTearDown(reviewBloc.close);

      reviewBloc.add(const RegisterAnimalEvent.nextStepRequested());

      await Future<void>.delayed(Duration.zero);
      expect(reviewBloc.state.currentStep, RegisterAnimalStep.review);
    });

    test('represents establishment loading failures with ResultState', () async {
      final failingBloc = RegisterAnimalBloc(
        registerAnimalUseCase: RegisterAnimalUseCase(repository),
        getAnimalParentsUseCase: GetAnimalParentsUseCase(_FakeAnimalParentRepository()),
        getAnimalCategoriesUseCase: GetAnimalCategoriesUseCase(
          categoryRepository,
        ),
        registrationContext: const _FailingAnimalRegistrationContext(),
      );
      addTearDown(failingBloc.close);

      failingBloc.add(const RegisterAnimalEvent.establishmentsRequested());
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        failingBloc.state.establishmentsState,
        isA<ResultError<List<AnimalRegistrationEstablishment>>>(),
      );
      expect(failingBloc.state.establishments, isEmpty);
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
        establishmentId: '8b75eb38-8b0f-44dc-979f-89ce2817b63d',
        establishmentName: 'La Sirena',
        destinationId: 'lot-1',
        categoryId: 'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8',
        categoryName: 'Ternera',
        mother: const AnimalParent(
          id: '56fb8531-13f7-41c6-a1e1-85ea9b7094fa',
          visualTag: '003 0421',
          rfid: '982000412884421',
          breed: 'Aberdeen Angus',
          sex: AnimalSex.female,
        ),
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
      expect(
        repository.lastRegistration?.categoryId,
        'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8',
      );
      expect(repository.lastRegistration?.categoryName, 'Ternera');
      expect(repository.lastRegistration?.motherId, '56fb8531-13f7-41c6-a1e1-85ea9b7094fa');
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
        establishmentId: '8b75eb38-8b0f-44dc-979f-89ce2817b63d',
        establishmentName: 'La Sirena',
        destinationId: 'lot-1',
        categoryId: 'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8',
        categoryName: 'Ternera',
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

class _TestAnimalRegistrationContext implements AnimalRegistrationContext {
  const _TestAnimalRegistrationContext();

  @override
  Future<List<AnimalRegistrationEstablishment>> loadEstablishments() async => const [
    AnimalRegistrationEstablishment(
      id: '8b75eb38-8b0f-44dc-979f-89ce2817b63d',
      name: 'La Sirena',
    ),
  ];

  @override
  Future<List<AnimalRegistrationDestination>> loadDestinations(
    String establishmentId,
  ) async => const [
    AnimalRegistrationDestination(
      id: 'lot-1',
      name: 'La Cumbre',
      details: '142,0 ha',
    ),
  ];

  @override
  String resolveLotId(String destinationSelectionId) => destinationSelectionId == 'lot-1'
      ? '62af91d7-307d-4a07-b2bd-b2d8976ec91a'
      : throw StateError('Unknown destination.');

  @override
  String resolveLotName(String destinationSelectionId) => 'La Cumbre';
}

class _FailingAnimalRegistrationContext implements AnimalRegistrationContext {
  const _FailingAnimalRegistrationContext();

  @override
  Future<List<AnimalRegistrationEstablishment>> loadEstablishments() {
    throw StateError('forced local read failure');
  }

  @override
  Future<List<AnimalRegistrationDestination>> loadDestinations(
    String establishmentId,
  ) {
    throw StateError('forced local read failure');
  }

  @override
  String resolveLotId(String destinationSelectionId) => 'lot-id';

  @override
  String resolveLotName(String destinationSelectionId) => 'Lote';
}

class _MultipleEstablishmentsContext implements AnimalRegistrationContext {
  final destinationRequests = <String>[];

  @override
  Future<List<AnimalRegistrationEstablishment>> loadEstablishments() async => const [
    AnimalRegistrationEstablishment(
      id: 'establishment-1',
      name: 'La Sirena',
    ),
    AnimalRegistrationEstablishment(
      id: 'establishment-2',
      name: 'El Ombú',
    ),
  ];

  @override
  Future<List<AnimalRegistrationDestination>> loadDestinations(
    String establishmentId,
  ) async {
    destinationRequests.add(establishmentId);
    return const [
      AnimalRegistrationDestination(
        id: 'lot-2',
        name: 'Lote Sur',
        details: '20,0 ha',
      ),
    ];
  }

  @override
  String resolveLotId(String destinationSelectionId) => destinationSelectionId;

  @override
  String resolveLotName(String destinationSelectionId) => 'Lote Sur';
}

class _FakeAnimalRegistrationRepository implements AnimalRegistrationRepository {
  int registerCalls = 0;
  AnimalRegistration? lastRegistration;

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
    lastRegistration = registration;
    return result;
  }
}

class _FakeAnimalCategoryRepository implements AnimalCategoryRepository {
  static const categories = [
    AnimalCategory(
      id: 'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8',
      name: 'Ternera',
    ),
  ];

  Result<List<AnimalCategory>> result = const Result.success(categories);

  @override
  Future<Result<List<AnimalCategory>>> getCategories() async => result;
}

class _FakeAnimalParentRepository implements AnimalParentRepository {
  Result<List<AnimalParent>> result = const Result.success([]);
  final requestedEstablishments = <String>[];

  @override
  Future<Result<List<AnimalParent>>> getParents(String establishmentId) async {
    requestedEstablishments.add(establishmentId);
    return result;
  }
}
