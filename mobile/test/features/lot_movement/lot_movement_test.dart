import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/entities/lot_movement.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/repositories/lot_movement_repository.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/use_cases/lot_movement_use_cases.dart';
import 'package:frontend_mayoral/features/lot_movement/presentation/cubit/lot_movement_cubit.dart';
import 'package:frontend_mayoral/features/lot_movement/presentation/pages/lot_movement_page.dart';
import 'package:frontend_mayoral/features/lot_movement/presentation/strings/lot_movement_strings.dart';
import 'package:go_router/go_router.dart';

const establishment = '10000000-0000-4000-8000-000000000001';
const source = '20000000-0000-4000-8000-000000000001';
const destination = '20000000-0000-4000-8000-000000000002';
const animalOne = '30000000-0000-4000-8000-000000000001';
const animalTwo = '30000000-0000-4000-8000-000000000002';
const movementId = '40000000-0000-4000-8000-000000000001';

void main() {
  late _Repository repository;
  late SaveLotMovementUseCase save;
  setUp(() {
    repository = _Repository();
    save = SaveLotMovementUseCase(repository, createId: () => movementId, now: () => DateTime.utc(2026, 10, 5));
  });
  Future<Result<AnimalLotMovement>> submit({
    String? origin,
    List<String> ids = const [animalOne],
    String target = destination,
    String reason = '  Rotación  ',
  }) => save(
    establishmentId: establishment,
    sourceLotId: origin,
    destinationLotId: target,
    animalIds: ids,
    occurredAt: DateTime.utc(2026, 10, 5, 12),
    reason: reason,
  );

  test('asignación inicial conserva origen null y selección múltiple', () async {
    final result = await submit(ids: [animalOne, animalTwo]);
    expect(result, isA<Success<AnimalLotMovement>>());
    expect(repository.saved!.sourceLotId, isNull);
    expect(repository.saved!.animalIds, [animalOne, animalTwo]);
    expect(repository.saved!.reason, 'Rotación');
    expect(repository.saved!.syncStatus, MovementSyncStatus.pending);
  });
  test('traslado conserva lote de origen y UUID del comando', () async {
    repository.data = repository.data.copyWith(
      animals: [const MovementAnimal(id: animalOne, tag: '001', lotId: source, canMove: true)],
    );
    expect(await submit(origin: source), isA<Success<AnimalLotMovement>>());
    expect(repository.saved!.sourceLotId, source);
    expect(repository.saved!.id, movementId);
  });
  test('rechaza animales de distintos orígenes sin guardar', () async {
    repository.data = repository.data.copyWith(
      animals: [
        const MovementAnimal(id: animalOne, tag: '001', canMove: true),
        const MovementAnimal(id: animalTwo, tag: '002', lotId: source, canMove: true),
      ],
    );
    expect(await submit(ids: [animalOne, animalTwo]), isA<Failure<AnimalLotMovement>>());
    expect(repository.saved, isNull);
  });
  test('rechaza selección vacía, IDs duplicados, motivo vacío y destino no activo', () async {
    expect(await submit(ids: []), isA<Failure<AnimalLotMovement>>());
    expect(await submit(ids: [animalOne, animalOne]), isA<Failure<AnimalLotMovement>>());
    expect(await submit(reason: '  '), isA<Failure<AnimalLotMovement>>());
    expect(await submit(target: source), isA<Failure<AnimalLotMovement>>());
    expect(repository.saved, isNull);
  });
  test('rechaza UUID inválido y animal con ubicación sin confirmar', () async {
    expect(await submit(ids: ['invalid']), isA<Failure<AnimalLotMovement>>());
    repository.data = repository.data.copyWith(
      animals: [const MovementAnimal(id: animalOne, tag: '001', canMove: false)],
    );
    expect(await submit(), isA<Failure<AnimalLotMovement>>());
    expect(repository.saved, isNull);
  });
  test('cambiar de origen limpia la selección e impide mezclar orígenes', () async {
    final cubit = LotMovementCubit(
      establishmentId: establishment,
      loadContext: LoadMovementContextUseCase(repository),
      saveMovement: save,
      retryMovement: RetryLotMovementUseCase(repository),
    );
    await cubit.load();
    cubit.selectAnimal(repository.data.animals.first, selected: true);
    expect(cubit.state.selectedIds, [animalOne]);
    cubit.selectOrigin(source);
    expect(cubit.state.selectedIds, isEmpty);
    cubit.selectAnimal(repository.data.animals.first, selected: true);
    expect(cubit.state.selectedIds, isEmpty);
    await cubit.close();
  });
  test('doble pulsación sólo guarda una vez mientras SQLite está ocupado', () async {
    repository.completer = Completer<Result<AnimalLotMovement>>();
    final cubit = LotMovementCubit(
      establishmentId: establishment,
      loadContext: LoadMovementContextUseCase(repository),
      saveMovement: save,
      retryMovement: RetryLotMovementUseCase(repository),
      initialAnimalId: animalOne,
    );
    await cubit.load();
    final first = cubit.save(destinationLotId: destination, occurredAt: DateTime.utc(2026), reason: 'Rotación');
    await cubit.save(destinationLotId: destination, occurredAt: DateTime.utc(2026), reason: 'Rotación');
    await Future<void>.delayed(Duration.zero);
    expect(repository.saveCount, 1);
    repository.completer!.complete(Result.success(repository.saved!));
    await first;
    expect(cubit.state.saving, isA<Data<AnimalLotMovement>>());
    expect(cubit.state.selectedIds, isEmpty);
    await cubit.close();
  });
  test('reintento usa el ID guardado sin generar otra operación', () async {
    await submit();
    final original = repository.saved;
    expect(await RetryLotMovementUseCase(repository)(movementId), isA<Success<void>>());
    expect(repository.retriedId, original!.id);
    expect(repository.saveCount, 1);
  });
  testWidgets('formulario exige selección y confirma cantidad, origen y destino antes de guardar', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => LotMovementPage(
            createCubit: () => LotMovementCubit(
              establishmentId: establishment,
              loadContext: LoadMovementContextUseCase(repository),
              saveMovement: save,
              retryMovement: RetryLotMovementUseCase(repository),
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    final review = find.text(LotMovementStrings.review);
    await Scrollable.ensureVisible(tester.element(review), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(review);
    await tester.pumpAndSettle();
    expect(find.text(LotMovementStrings.emptySelection), findsOneWidget);
    final first = find.widgetWithText(CheckboxListTile, '001');
    await Scrollable.ensureVisible(tester.element(first), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(first);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(first).value, isTrue);
    final dropdown = find.byType(DropdownButtonFormField<String>).last;
    await Scrollable.ensureVisible(tester.element(dropdown), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Norte').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Rotación');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(review), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(review);
    await tester.pumpAndSettle();
    expect(find.text('1 animal\nOrigen: Sin lote asignado\nDestino: Norte'), findsOneWidget);
    expect(repository.saveCount, 0);
    await tester.tap(find.text(LotMovementStrings.cancel));
    await tester.pumpAndSettle();
    expect(repository.saveCount, 0);
    await tester.tap(review);
    await tester.pumpAndSettle();
    await tester.tap(find.text(LotMovementStrings.confirm));
    await tester.pumpAndSettle();
    expect(repository.saveCount, 1);
    expect(find.text(LotMovementStrings.pendingSaved), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
  testWidgets('origen ausente en caché y códigos vacíos no rompen el selector', (tester) async {
    repository.data = repository.data.copyWith(
      animals: [],
      origins: const [MovementLot(id: '', name: 'Dato legado sin UUID')],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: LotMovementPage(
          createCubit: () => LotMovementCubit(
            establishmentId: establishment,
            sourceLotId: source,
            loadContext: LoadMovementContextUseCase(repository),
            saveMovement: save,
            retryMovement: RetryLotMovementUseCase(repository),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final field = tester.widget<DropdownButtonFormField<String>>(find.byType(DropdownButtonFormField<String>).first);
    expect(field.initialValue, source);
    expect(find.text(source), findsOneWidget);
    expect(find.text(LotMovementStrings.noAnimals), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('sin destinos activos muestra el estado vacío y deshabilita revisar', (tester) async {
    repository.data = repository.data.copyWith(destinations: []);
    await tester.pumpWidget(
      MaterialApp(
        home: LotMovementPage(
          createCubit: () => LotMovementCubit(
            establishmentId: establishment,
            loadContext: LoadMovementContextUseCase(repository),
            saveMovement: save,
            retryMovement: RetryLotMovementUseCase(repository),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(LotMovementStrings.noDestinations), findsOneWidget);
    final button = find.widgetWithText(FilledButton, LotMovementStrings.review);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

/// Doble de dominio: permite simular una escritura lenta sin depender de Brick.
class _Repository implements LotMovementRepository {
  MovementContext data = const MovementContext(
    animals: [
      MovementAnimal(id: animalOne, tag: '001', canMove: true),
      MovementAnimal(id: animalTwo, tag: '002', canMove: true),
    ],
    destinations: [MovementLot(id: destination, name: 'Norte')],
    origins: [],
    history: [],
  );
  AnimalLotMovement? saved;
  int saveCount = 0;
  String? retriedId;
  Completer<Result<AnimalLotMovement>>? completer;
  @override
  Stream<void> get changes => const Stream.empty();
  @override
  Future<Result<MovementContext>> getContext(String establishmentId, {bool refreshRemote = false}) async =>
      Result.success(data);
  @override
  Future<Result<AnimalLotMovement>> save(AnimalLotMovement movement) async {
    saved = movement;
    saveCount++;
    return completer?.future ?? Future.value(Result.success(movement));
  }

  @override
  Future<Result<void>> retry(String movementId) async {
    retriedId = movementId;
    return const Result.success(null);
  }
}
