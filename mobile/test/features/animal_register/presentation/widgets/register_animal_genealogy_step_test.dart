import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_category.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_parent.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_category_repository.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_parent_repository.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_context.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_repository.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_rfid_repository.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/check_animal_rfid_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/get_animal_categories_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/get_animal_parents_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/register_animal_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/steps/register_animal_genealogy_step.dart';

void main() {
  testWidgets('searches local caravans by sex and shows an inline error', (tester) async {
    final bloc = RegisterAnimalBloc(
      registerAnimalUseCase: RegisterAnimalUseCase(_RegistrationRepository()),
      checkAnimalRfidUseCase: CheckAnimalRfidUseCase(_RfidRepository()),
      getAnimalCategoriesUseCase: GetAnimalCategoriesUseCase(_CategoryRepository()),
      getAnimalParentsUseCase: GetAnimalParentsUseCase(_ParentRepository()),
      registrationContext: _Context(),
      initialStep: RegisterAnimalStep.genealogy,
    )..add(const RegisterAnimalEvent.establishmentsRequested());
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: const Scaffold(body: RegisterAnimalGenealogyStep()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    final motherInput = find.byType(TextFormField).first;
    await tester.ensureVisible(motherInput);
    await tester.enterText(motherInput, '999');
    await tester.pump();
    expect(find.text(AnimalRegisterStrings.parentNotFound), findsOneWidget);

    await tester.enterText(motherInput, '0030421');
    await tester.pump();
    expect(find.text(AnimalRegisterStrings.parentNotFound), findsNothing);
    await tester.tap(find.textContaining('003 0421 · Aberdeen Angus · 982000412884421'));
    await tester.pump();
    expect(bloc.state.draft.mother?.id, 'mother-id');

    final fatherInput = find.byType(TextFormField).first;
    await tester.ensureVisible(fatherInput);
    await tester.enterText(fatherInput, '0030421');
    await tester.pump();
    expect(find.text(AnimalRegisterStrings.parentNotFound), findsOneWidget);
  });
}

class _Context extends Fake implements AnimalRegistrationContext {
  @override
  Future<List<AnimalRegistrationEstablishment>> loadEstablishments() async => const [
    AnimalRegistrationEstablishment(id: 'farm-id', name: 'La Sirena'),
  ];

  @override
  Future<List<AnimalRegistrationDestination>> loadDestinations(String establishmentId) async => const [];
}

class _ParentRepository extends Fake implements AnimalParentRepository {
  @override
  Future<Result<List<AnimalParent>>> getParents(String establishmentId) async => const Result.success([
    AnimalParent(
      id: 'mother-id',
      visualTag: '003 0421',
      rfid: '982000412884421',
      breed: 'Aberdeen Angus',
      sex: AnimalSex.female,
    ),
    AnimalParent(
      id: 'father-id',
      visualTag: '003 0820',
      rfid: '982000412884820',
      breed: 'Hereford',
      sex: AnimalSex.male,
    ),
  ]);
}

class _CategoryRepository extends Fake implements AnimalCategoryRepository {
  @override
  Future<Result<List<AnimalCategory>>> getCategories() async => const Result.success([]);
}

class _RegistrationRepository extends Fake implements AnimalRegistrationRepository {}

class _RfidRepository extends Fake implements AnimalRfidRepository {
  @override
  Future<Result<bool>> isRegistered(String rfid) async => const Result.success(false);
}
