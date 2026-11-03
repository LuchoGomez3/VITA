import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_tag_kind.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/use_cases/animal_movement_use_cases.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/group_movement_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/pages/group_movement_page.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/strings/animal_movement_strings.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('selector separa visual y RFID; solo agrega RFID de quince números', (tester) async {
    final repository = _RecordingRepository();
    final cubit = _createCubit(repository);
    await tester.pumpWidget(
      MaterialApp(
        home: GroupMovementPage(animalIds: const ['a1'], createCubit: () => cubit),
      ),
    );
    await tester.pumpAndSettle();
    final field = find.byType(TextField).first;
    final add = find.widgetWithIcon(IconButton, Icons.add);
    expect(cubit.state.tagKind, MovementTagKind.rfid);
    expect(tester.widget<IconButton>(add).onPressed, isNull);
    await tester.enterText(field, '98200041288400');
    await tester.pump();
    for (final invalid in ['9820004128840050', 'A982000412884005']) {
      await tester.enterText(field, invalid);
      await tester.pump();
      expect(tester.widget<TextField>(field).controller!.text, '98200041288400');
      expect(tester.widget<IconButton>(add).onPressed, isNull);
    }
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text(AnimalMovementStrings.invalidRfid), findsOneWidget);
    expect(repository.readings, isEmpty);

    await tester.tap(find.text(AnimalMovementStrings.visualMode));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    expect(find.text(AnimalMovementStrings.invalidRfid), findsNothing);
    await tester.enterText(field, 'A 982000412884005');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.text(AnimalMovementStrings.rfidMode));
    await tester.pumpAndSettle();
    await tester.enterText(field, '982000412884005');
    await tester.pump();
    expect(tester.widget<IconButton>(add).onPressed, isNotNull);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(repository.readings, [
      ('A 982000412884005', MovementTagKind.visual),
      ('982000412884005', MovementTagKind.rfid),
    ]);
    expect(cubit.state.animals.map((animal) => animal.id), ['a1', 'read-1', 'read-2']);
  });

  for (final (keepInitial, partial, retry) in [
    (true, false, false),
    (false, false, false),
    (true, true, true),
    (true, true, false),
  ]) {
    testWidgets('movimiento inicial=$keepInitial, parcial=$partial, reintento=$retry', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      final move = _FakeMove()..failOnceSource = partial ? 'sauces' : null;
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
              animalIds: const ['a1'],
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
      await tester.enterText(find.byType(TextField).first, '999000000000000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.textContaining('No hay ningún animal activo'), findsOneWidget);
      expect(find.text(AnimalMovementStrings.animalsTitle(2)), findsOneWidget);

      if (!keepInitial) {
        await tester.tap(find.byTooltip(AnimalMovementStrings.removeAnimal).first);
        await tester.pumpAndSettle();
      }
      final count = keepInitial ? 2 : 1;
      await tester.scrollUntilVisible(find.text('La Cumbre'), 200, scrollable: _list);
      await tester.tap(find.text('La Cumbre'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(TextFormField, AnimalMovementStrings.reasonHint),
        200,
        scrollable: _list,
      );
      await tester.enterText(find.widgetWithText(TextFormField, AnimalMovementStrings.reasonHint), 'Rotación');
      await tester.tap(find.text(AnimalMovementStrings.submit(count)));
      await tester.pumpAndSettle();

      if (partial) {
        expect(find.text(AnimalMovementStrings.animalsTitle(1)), findsOneWidget);
        if (retry) {
          await tester.tap(find.text(AnimalMovementStrings.submit(1)));
        } else {
          await tester.pageBack();
        }
        await tester.pumpAndSettle();
      }
      expect(result?.movedCount, partial && !retry ? 1 : count);
      expect(result?.destinations, {'cumbre': 'La Cumbre'});
      expect(move.calls, {
        if (keepInitial) 'bajo': ['a1'],
        if (!partial || retry) 'sauces': ['a2'],
      });
      if (partial) expect(move.sourceCalls, ['bajo', 'sauces', if (retry) 'sauces']);
    });
  }

  testWidgets('la respuesta de A no borra B y dos Enter capturan caravanas independientes', (tester) async {
    final repository = _DelayedRepository();
    final cubit = _createCubit(repository);
    await tester.pumpWidget(
      MaterialApp(
        home: GroupMovementPage(animalIds: const ['a1'], createCubit: () => cubit),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AnimalMovementStrings.visualMode));
    await tester.pumpAndSettle();
    final field = find.byType(TextField).first;

    await tester.enterText(field, '002');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    await tester.enterText(field, '00');
    repository.first.complete(Result.success(_animal('a2', '002', 'bajo')));
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, '00');

    await tester.enterText(field, '003');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    repository.second.complete(Result.success(_animal('a3', '003', 'bajo')));
    await tester.pumpAndSettle();

    expect(repository.tags, ['002', '003']);
    expect(cubit.state.animals.map((animal) => animal.id), ['a1', 'a2', 'a3']);
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
  });

  for (final editDuringLookup in [false, true]) {
    testWidgets('una lectura fallida solo restaura texto sin ediciones posteriores: $editDuringLookup', (tester) async {
      final repository = _DelayedRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: GroupMovementPage(
            animalIds: const ['a1'],
            createCubit: () => _createCubit(repository),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(AnimalMovementStrings.visualMode));
      await tester.pumpAndSettle();
      final field = find.byType(TextField).first;
      await tester.enterText(field, '002');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      if (editDuringLookup) await tester.enterText(field, '003');

      repository.first.complete(const Result.success(null));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(field).controller!.text, editDuringLookup ? '003' : '002');
      expect(find.text(AnimalMovementStrings.tagNotFound('002')), findsOneWidget);
    });
  }

  testWidgets('cerrar durante la búsqueda no accede al controller descartado', (tester) async {
    final repository = _DelayedRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: GroupMovementPage(
          animalIds: const ['a1'],
          createCubit: () => _createCubit(repository),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AnimalMovementStrings.visualMode));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '002');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());

    repository.first.complete(Result.success(_animal('a2', '002', 'bajo')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

GroupMovementCubit _createCubit(AnimalMovementRepository repository) => GroupMovementCubit(
  prepare: PrepareGroupMovementUseCase(repository),
  resolveTag: ResolveMovementTagUseCase(repository),
  register: RegisterGroupMovementUseCase(_FakeMove()),
);

class _DelayedRepository extends _FakeRepository {
  final first = Completer<Result<MovementAnimal?>>();
  final second = Completer<Result<MovementAnimal?>>();
  final tags = <String>[];

  @override
  Future<Result<MovementAnimal?>> findAnimalByTag(
    String tag, {
    required String establishmentId,
    required MovementTagKind kind,
  }) {
    tags.add(tag);
    return tag == '002' ? first.future : second.future;
  }
}

class _RecordingRepository extends _FakeRepository {
  final readings = <(String, MovementTagKind)>[];

  @override
  Future<Result<MovementAnimal?>> findAnimalByTag(
    String tag, {
    required String establishmentId,
    required MovementTagKind kind,
  }) async {
    readings.add((tag, kind));
    return Result.success(_animal('read-${readings.length}', tag, 'bajo'));
  }
}

final Finder _list = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;

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
  Future<Result<MovementAnimal?>> findAnimalByTag(
    String tag, {
    required String establishmentId,
    required MovementTagKind kind,
  }) async => Result.success(tag == '982000412884920' ? _animal('a2', '004 0023', 'sauces') : null);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakeMove implements MoveLotAnimalsUseCase {
  final calls = <String, List<String>>{};
  final sourceCalls = <String>[];
  String? failOnceSource;

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
    sourceCalls.add(sourceLotId);
    if (sourceLotId == failOnceSource) {
      failOnceSource = null;
      return const Result.failure(DomainException(message: 'write_failed', code: DomainErrorCode.offline));
    }
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
