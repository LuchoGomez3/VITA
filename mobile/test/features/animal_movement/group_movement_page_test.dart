import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/use_cases/animal_movement_use_cases.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/group_movement_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/pages/group_movement_page.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/strings/animal_movement_strings.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('leer caravanas, elegir destino y mover devuelve el resumen', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final move = _FakeMove();
    GroupMovementSummary? result;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => TextButton(
            onPressed: () async => result = await context.push<GroupMovementSummary>('/mover'),
            child: const Text('abrir'),
          ),
        ),
        GoRoute(
          path: '/mover',
          builder: (_, _) => GroupMovementPage(
            animalId: 'a1',
            createCubit: () {
              final repository = _FakeRepository();
              return GroupMovementCubit(
                prepare: PrepareGroupMovementUseCase(repository),
                resolveTag: ResolveMovementTagUseCase(repository),
                register: RegisterGroupMovementUseCase(move),
              );
            },
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text(AnimalMovementStrings.animalsTitle(1)), findsOneWidget);

    // El bastón escribe el RFID y manda Enter.
    await tester.enterText(find.byType(TextField).first, '982000412884920');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text(AnimalMovementStrings.animalsTitle(2)), findsOneWidget);

    // Una caravana desconocida muestra el error y no se agrega.
    await tester.enterText(find.byType(TextField).first, '999');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('No hay ningún animal activo'), findsOneWidget);
    expect(find.text(AnimalMovementStrings.animalsTitle(2)), findsOneWidget);

    await tester.scrollUntilVisible(find.text('La Cumbre'), 200, scrollable: _list);
    await tester.tap(find.text('La Cumbre'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(TextFormField, AnimalMovementStrings.reasonHint),
      200,
      scrollable: _list,
    );
    await tester.enterText(find.widgetWithText(TextFormField, AnimalMovementStrings.reasonHint), 'Rotación');
    await tester.tap(find.text(AnimalMovementStrings.submit(2)));
    await tester.pumpAndSettle();

    expect(result?.movedCount, 2);
    expect(move.calls, {
      'bajo': ['a1'],
      'sauces': ['a2'],
    });
  });
}

final _list = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;

MovementAnimal _animal(String id, String visualTag, String lotId) => MovementAnimal(
  id: id,
  establishmentId: 'campo-1',
  visualTag: visualTag,
  rfidTagNumber: '982000412884920',
  breed: 'Hereford',
  categoryName: 'Novillo',
  lotId: lotId,
  lotName: lotId,
);

class _FakeRepository implements AnimalMovementRepository {
  @override
  Future<Result<MovementAnimal?>> getAnimal(String animalId) async => Result.success(_animal('a1', '004 0028', 'bajo'));

  @override
  Future<Result<List<MovementDestination>>> getDestinations(String establishmentId) async => const Result.success([
    MovementDestination(id: 'bajo', name: 'El Bajo', animalCount: 2),
    MovementDestination(id: 'cumbre', name: 'La Cumbre', animalCount: 3),
  ]);

  @override
  Future<Result<MovementAnimal?>> findAnimalByTag(String tag) async =>
      Result.success(tag == '982000412884920' ? _animal('a2', '004 0023', 'sauces') : null);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakeMove implements MoveLotAnimalsUseCase {
  final calls = <String, List<String>>{};

  @override
  Future<Result<LotAnimalMovement>> call({
    required String establishmentId,
    required String sourceLotId,
    required String destinationLotId,
    required List<String> animalIds,
    required DateTime occurredAt,
    required String reason,
    String? responsibleId,
  }) async {
    calls[sourceLotId] = animalIds;
    return Result.success(
      LotAnimalMovement(
        id: 'm-$sourceLotId',
        establishmentId: establishmentId,
        sourceLotId: sourceLotId,
        destinationLotId: destinationLotId,
        animalIds: animalIds,
        occurredAt: occurredAt,
        reason: reason,
        createdAt: occurredAt,
        updatedAt: occurredAt,
      ),
    );
  }
}
