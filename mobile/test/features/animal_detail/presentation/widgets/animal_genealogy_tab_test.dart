import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/widgets/app_ear_tag_badge.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_genealogy_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_genealogy_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_genealogy_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_genealogy_tab.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<void> pumpTab(WidgetTester tester, List<GenealogyAnimalRecord> records) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final repository = _FamilyRepository((_) async => Result.success(records));
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: AnimalGenealogyTab(
              animal: _animal,
              createCubit: () => AnimalGenealogyCubit(GetAnimalGenealogyUseCase(repository)),
            ),
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

  testWidgets('dibuja el animal, padres, abuelos y crías', (tester) async {
    await pumpTab(tester, [
      _record(_animal.id, mother: 'vaca', father: 'toro'),
      _record('toro', tag: '003 0820'),
      _record('vaca', tag: '003 0421', father: 'abuelo', breed: 'Hereford'),
      _record('abuelo', breed: ''),
      _record('cria', tag: '006 0001', mother: _animal.id),
    ]);

    expect(find.text(AnimalDetailStrings.genealogyCurrent('Aberdeen Angus')), findsOneWidget);
    expect(
      find.text(AnimalDetailStrings.genealogyNode(AnimalDetailStrings.genealogyFather, 'Aberdeen Angus')),
      findsOneWidget,
    );
    expect(
      find.text(AnimalDetailStrings.genealogyNode(AnimalDetailStrings.genealogyMother, 'Hereford')),
      findsOneWidget,
    );
    expect(find.text(AnimalDetailStrings.genealogyMaternalGrandfather), findsOneWidget);
    expect(
      find.text(AnimalDetailStrings.genealogyMissing(AnimalDetailStrings.genealogyPaternalGrandfather)),
      findsOneWidget,
    );
    expect(find.text(AnimalDetailStrings.genealogyOffspringSection(1).toUpperCase()), findsOneWidget);
    expect(find.text('006 0001'.replaceFirst(' ', '\n')), findsOneWidget);
  });

  testWidgets('tocar un progenitor abre su ficha', (tester) async {
    await pumpTab(tester, [_record(_animal.id, mother: 'vaca'), _record('vaca', breed: 'Hereford')]);
    await tester.tap(find.text(AnimalDetailStrings.genealogyNode(AnimalDetailStrings.genealogyMother, 'Hereford')));
    await tester.pumpAndSettle();
    expect(find.text('Ficha vaca'), findsOneWidget);
  });

  testWidgets('crea mil crías bajo demanda y permite abrir la última', (tester) async {
    await pumpTab(tester, [
      _record(_animal.id),
      for (var index = 0; index < 1000; index++)
        _record(
          'cria-$index',
          tag: '006 ${index.toString().padLeft(4, '0')}',
          mother: _animal.id,
          birthDate: DateTime.utc(2026).subtract(Duration(days: index)),
        ),
    ]);
    final mountedOffspring = find.byWidgetPredicate(
      (widget) => widget is AppEarTagBadge && widget.visualTag.startsWith('006 '),
    );
    final lastChild = find.byWidgetPredicate(
      (widget) => widget is AppEarTagBadge && widget.visualTag == '006 0999',
    );

    expect(
      tester.widget<SliverList>(find.byType(SliverList)).delegate,
      isA<SliverChildBuilderDelegate>(),
      reason:
          'Una lista eager también monta solo elementos visibles; el delegado debe construir los widgets por demanda.',
    );
    expect(mountedOffspring.evaluate().length, inExclusiveRange(0, 1000));
    expect(lastChild, findsNothing);

    await tester.scrollUntilVisible(lastChild, 500, maxScrolls: 200);
    expect(mountedOffspring.evaluate().length, inExclusiveRange(0, 1000));
    expect(lastChild.hitTestable(), findsOneWidget);

    await tester.tap(lastChild);
    await tester.pumpAndSettle();
    expect(find.text('Ficha cria-999'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('un nodo sin datos no navega y explica el origen de los datos', (tester) async {
    await pumpTab(tester, []);
    await tester.tap(find.text(AnimalDetailStrings.genealogyMissing(AnimalDetailStrings.genealogyFather)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ficha '), findsNothing);
    expect(find.text(AnimalDetailStrings.genealogyEmpty), findsOneWidget);
  });

  testWidgets('muestra carga pendiente y el mensaje centralizado ante error', (tester) async {
    final pending = Completer<Result<List<GenealogyAnimalRecord>>>();
    final repository = _FamilyRepository((_) => pending.future);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalGenealogyTab(
            animal: _animal,
            createCubit: () => AnimalGenealogyCubit(GetAnimalGenealogyUseCase(repository)),
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.complete(const Result.failure(DomainException(message: 'animal_genealogy_read_failed')));
    await tester.pumpAndSettle();
    expect(find.text(AnimalDetailStrings.genealogyLoadError), findsOneWidget);
    expect(find.text('animal_genealogy_read_failed'), findsNothing);
  });

  testWidgets('cambiar de animal cierra el Cubit anterior y descarta su respuesta pendiente', (tester) async {
    final pending = Completer<Result<List<GenealogyAnimalRecord>>>();
    final repository = _FamilyRepository(
      (id) => id == _animal.id ? pending.future : Future.value(const Result.success([])),
    );
    final cubits = <AnimalGenealogyCubit>[];
    AnimalGenealogyCubit createCubit() {
      final cubit = AnimalGenealogyCubit(GetAnimalGenealogyUseCase(repository));
      cubits.add(cubit);
      return cubit;
    }

    Future<void> showAnimal(AnimalDetail animal) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalGenealogyTab(animal: animal, createCubit: createCubit),
        ),
      ),
    );

    await showAnimal(_animal);
    await showAnimal(_animal.copyWith(id: 'nuevo'));
    await tester.pumpAndSettle();
    expect(cubits, hasLength(2));
    expect(cubits.first.isClosed, isTrue);
    expect(find.text(AnimalDetailStrings.genealogyEmpty), findsOneWidget);

    pending.complete(Result.success([_record(_animal.id, mother: 'madre-vieja'), _record('madre-vieja')]));
    await tester.pumpAndSettle();
    expect(find.text('madre-vieja'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(cubits.last.isClosed, isTrue);
  });

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('genealogía soporta $size con texto al 200%', (tester) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = _FamilyRepository((_) async => Result.success([_record(_animal.id)]));
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: AnimalGenealogyTab(
              animal: _animal,
              createCubit: () => AnimalGenealogyCubit(GetAnimalGenealogyUseCase(repository)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });
  }
}

GenealogyAnimalRecord _record(
  String id, {
  String? tag,
  String? mother,
  String? father,
  DateTime? birthDate,
  String breed = 'Aberdeen Angus',
}) => GenealogyAnimalRecord(
  animal: GenealogyAnimal(id: id, visualTag: tag ?? id, breed: breed, categoryName: 'Vaca'),
  birthDate: birthDate ?? DateTime.utc(2022),
  motherId: mother,
  fatherId: father,
);

class _FamilyRepository implements AnimalGenealogyRepository {
  const _FamilyRepository(this.read);
  final Future<Result<List<GenealogyAnimalRecord>>> Function(String) read;

  @override
  Future<Result<List<GenealogyAnimalRecord>>> getLocalFamily(String animalId) => read(animalId);
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
