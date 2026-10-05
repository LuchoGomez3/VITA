import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/save_animal_detail_change_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/pages/animal_detail_page.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_actions.dart';
import 'package:go_router/go_router.dart';
import '../../animal_detail_fixture.dart';

AnimalDetailCubit _cubit(MemoryAnimalDetailRepository repository) => AnimalDetailCubit(
  getAnimalDetailUseCase: GetAnimalDetailUseCase(repository),
  saveChangeUseCase: SaveAnimalDetailChangeUseCase(repository),
);

void main() {
  testWidgets('offers pregnancy editing only for females', (tester) async {
    final repository = MemoryAnimalDetailRepository();
    for (final sex in AnimalSex.values) {
      final cubit = _cubit(repository);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => cubit,
            child: Scaffold(
              body: AnimalDetailActions(animalDetail: repository.detail.copyWith(sex: sex)),
            ),
          ),
        ),
      );
      expect(
        find.text(AnimalDetailStrings.changePregnancyAction),
        sex == AnimalSex.female ? findsOneWidget : findsNothing,
      );
      expect(find.text(AnimalDetailStrings.enterWeightAction), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
  });
  testWidgets('cancel does not save and confirmed death can be undone', (tester) async {
    final repository = MemoryAnimalDetailRepository();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => AnimalDetailPage(
            animalId: repository.detail.id,
            createCubit: () => _cubit(repository),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(find.text(AnimalDetailStrings.deathAction)), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(find.text(AnimalDetailStrings.deathAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AnimalDetailStrings.cancelAction));
    await tester.pumpAndSettle();
    expect(repository.changes, isEmpty);
    await tester.tap(find.text(AnimalDetailStrings.deathAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AnimalDetailStrings.confirmAction));
    await tester.pumpAndSettle();
    expect(repository.detail.status, AnimalStatus.dead);
    expect(find.text(AnimalDetailStrings.undoAction), findsOneWidget);
    await tester.tap(find.text(AnimalDetailStrings.undoAction));
    await tester.pumpAndSettle();
    expect(repository.detail.status, AnimalStatus.active);
    expect(repository.changes, hasLength(2));
  });
  testWidgets('weight form rejects zero and accepts decimal comma', (tester) async {
    final repository = MemoryAnimalDetailRepository();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => AnimalDetailPage(
            animalId: repository.detail.id,
            createCubit: () => _cubit(repository),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(find.text(AnimalDetailStrings.enterWeightAction)), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(find.text(AnimalDetailStrings.enterWeightAction));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '0');
    await tester.tap(find.text(AnimalDetailStrings.saveAction));
    await tester.pumpAndSettle();
    expect(repository.changes, isEmpty);
    expect(find.text(AnimalDetailStrings.invalidWeightError), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '350,5');
    await tester.tap(find.text(AnimalDetailStrings.saveAction));
    await tester.pumpAndSettle();
    expect(repository.changes.single.toString(), contains('350.5'));
  });
}
