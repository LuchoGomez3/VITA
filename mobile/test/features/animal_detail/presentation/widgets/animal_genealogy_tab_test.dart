import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_genealogy_tab.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<void> pumpTab(WidgetTester tester, Result<AnimalGenealogy> result) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: AnimalGenealogyTab(animal: _animal, loadGenealogy: (_) async => result),
          ),
        ),
        GoRoute(
          path: AppRoutes.animalDetail,
          builder: (context, state) => Text('Ficha ${state.pathParameters['animalId']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('dibuja el animal, sus padres, sus abuelos y las crías', (tester) async {
    await pumpTab(
      tester,
      const Result.success(
        AnimalGenealogy(
          father: GenealogyAnimal(id: 'toro', visualTag: '003 0820', breed: 'Aberdeen Angus', categoryName: 'Toro'),
          mother: GenealogyAnimal(id: 'vaca', visualTag: '003 0421', breed: 'Hereford', categoryName: 'Vaca'),
          maternalGrandfather: GenealogyAnimal(id: 'abuelo', visualTag: '002 0099', breed: '', categoryName: ''),
          offspring: [GenealogyAnimal(id: 'cria', visualTag: '006 0001', breed: 'Hereford', categoryName: 'Ternera')],
        ),
      ),
    );

    expect(find.text(AnimalDetailStrings.genealogyCurrent('Aberdeen Angus')), findsOneWidget);
    expect(find.text('Padre · Aberdeen Angus'), findsOneWidget);
    expect(find.text('Madre · Hereford'), findsOneWidget);
    expect(find.text(AnimalDetailStrings.genealogyMaternalGrandfather), findsOneWidget);
    expect(
      find.text(AnimalDetailStrings.genealogyMissing(AnimalDetailStrings.genealogyPaternalGrandfather)),
      findsOneWidget,
    );
    expect(
      find.text(AnimalDetailStrings.genealogyMissing(AnimalDetailStrings.genealogyMaternalGrandmother)),
      findsOneWidget,
    );
    // Los títulos de sección van en mayúsculas.
    expect(find.text(AnimalDetailStrings.genealogyOffspringSection(1).toUpperCase()), findsOneWidget);
    expect(find.text('006 0001'.replaceFirst(' ', '\n')), findsOneWidget);
    expect(find.text(AnimalDetailStrings.genealogyTapHint), findsOneWidget);
  });

  testWidgets('tocar un progenitor abre su ficha', (tester) async {
    await pumpTab(
      tester,
      const Result.success(
        AnimalGenealogy(
          mother: GenealogyAnimal(id: 'vaca', visualTag: '003 0421', breed: 'Hereford', categoryName: 'Vaca'),
        ),
      ),
    );

    await tester.tap(find.text('Madre · Hereford'));
    await tester.pumpAndSettle();

    expect(find.text('Ficha vaca'), findsOneWidget);
  });

  testWidgets('un nodo sin datos no abre nada', (tester) async {
    await pumpTab(tester, const Result.success(AnimalGenealogy()));

    await tester.tap(find.text(AnimalDetailStrings.genealogyMissing(AnimalDetailStrings.genealogyFather)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ficha '), findsNothing);
    // Sin padres cargados explica de dónde salen.
    expect(find.text(AnimalDetailStrings.genealogyEmpty), findsOneWidget);
  });

  testWidgets('muestra el error si no se pudo leer', (tester) async {
    await pumpTab(tester, const Result.failure(DomainException(message: 'No se pudo cargar la genealogía.')));

    expect(find.text('No se pudo cargar la genealogía.'), findsOneWidget);
  });
}

final _animal = AnimalDetail(
  id: 'animal-id',
  rfidTagNumber: '982000412884712',
  visualTag: '003 1284',
  sex: AnimalSex.female,
  breed: 'Aberdeen Angus',
  birthDate: DateTime.utc(2022, 3, 14),
  categoryId: 'category-id',
  categoryName: 'Vaca',
  lotId: 'lot-id',
  lotName: 'La Cumbre',
  establishmentId: 'establishment-id',
  currentWeight: 442,
  weighingMethod: AnimalWeighingMethod.manual,
  weighingDate: DateTime.utc(2026, 10),
  syncStatus: AnimalSyncStatus.synchronized,
  productiveStatus: AnimalProductiveStatus.active,
  updatedAt: DateTime.utc(2026, 10),
  weightHistory: const [],
);
