import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_tag_kind.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/errors/movement_failure.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/use_cases/animal_movement_use_cases.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/group_movement_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/group_movement_state.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';

void main() {
  late _Repository repository;
  late _Move move;
  late GroupMovementCubit cubit;

  setUp(() {
    repository = _Repository();
    move = _Move();
    cubit = GroupMovementCubit(
      prepare: PrepareGroupMovementUseCase(repository),
      resolveTag: ResolveMovementTagUseCase(repository),
      register: RegisterGroupMovementUseCase(move),
    )..selectTagKind(MovementTagKind.visual);
    addTearDown(cubit.close);
  });

  test('la preparación expone loading y datos con selecciones inmutables', () async {
    final pending = Completer<Result<MovementAnimal?>>();
    repository.animalResult = pending.future;

    final loading = cubit.start(const ['a1']);
    expect(cubit.state.preparation, isA<Loading<GroupMovementPreparation>>());
    pending.complete(const Result.success(_animal));
    await loading;

    expect(cubit.state.preparation, isA<Data<GroupMovementPreparation>>());
    expect(cubit.state.establishmentId, 'campo-1');
    expect(cubit.state.animals, [_animal]);
    expect(() => cubit.state.animals.clear(), throwsUnsupportedError);
    expect(() => cubit.state.destinations.clear(), throwsUnsupportedError);
  });

  test('una falla local se conserva como motivo tipado', () async {
    final error = movementException(
      const MovementFailure.localRead(MovementReadTarget.animal),
      code: DomainErrorCode.offline,
    );
    repository.animalResult = Future.value(Result.failure(error));

    await cubit.start(const ['a1']);

    expect((cubit.state.preparation as ResultError<GroupMovementPreparation>).error, error);
    expect(cubit.state.submission, isA<Initial<GroupMovementSummary>>());
  });

  test('resolver caravana no sustituye los datos preparados', () async {
    await cubit.start(const ['a1']);
    final preparation = cubit.state.preparation;
    final pending = Completer<Result<MovementAnimal?>>();
    repository.tagResult = pending.future;

    final reading = cubit.addTag('a2');
    expect(cubit.state.tagResolution, isA<Loading<MovementAnimal>>());
    expect(cubit.state.preparation, preparation);
    pending.complete(Result.success(_animal.copyWith(id: 'a2', visualTag: '002')));
    expect(await reading, isTrue);
    expect(cubit.state.tagResolution, isA<Data<MovementAnimal>>());
    expect(cubit.state.animals.map((animal) => animal.id), ['a1', 'a2']);

    expect(await cubit.addTag('   '), isFalse);
    final error = (cubit.state.tagResolution as ResultError<MovementAnimal>).error;
    expect(error.reason, const MovementFailure.tagRequired());
    expect(cubit.state.animals, hasLength(2));
  });

  test('validar destino y motivo no escribe ni elimina la selección', () async {
    await cubit.start(const ['a1']);

    await cubit.submit('Rotación');
    expect(
      (cubit.state.submission as ResultError<GroupMovementSummary>).error.reason,
      const MovementFailure.destinationRequired(),
    );
    cubit.selectDestination('destino');
    expect(cubit.state.submission, isA<Initial<GroupMovementSummary>>());
    await cubit.submit('  ');
    expect(
      (cubit.state.submission as ResultError<GroupMovementSummary>).error.reason,
      const MovementFailure.reasonRequired(),
    );
    expect(move.calls, 0);
    expect(cubit.state.animals, [_animal]);
  });

  test('una caravana ambigua conserva la selección sin agregar animales', () async {
    await cubit.start(const ['a1']);
    final error = movementException(const MovementFailure.ambiguousTag('002'));
    repository.tagResult = Future.value(Result.failure(error));

    expect(await cubit.addTag('002'), isFalse);
    expect((cubit.state.tagResolution as ResultError<MovementAnimal>).error, error);
    expect(cubit.state.animals, [_animal]);
    expect(move.calls, 0);
  });

  test('guardar expone loading, error y luego permite un envío exitoso', () async {
    await cubit.start(const ['a1']);
    cubit.selectDestination('destino');
    final pending = Completer<Result<LotAnimalMovement>>();
    move.result = pending.future;

    final saving = cubit.submit('Rotación');
    expect(cubit.state.submission, isA<Loading<GroupMovementSummary>>());
    const error = DomainException(message: 'write_failed', code: DomainErrorCode.offline);
    pending.complete(const Result.failure(error));
    await saving;
    expect((cubit.state.submission as ResultError<GroupMovementSummary>).error, error);
    expect(cubit.state.animals, [_animal]);

    move.result = null;
    await cubit.submit('Rotación');
    expect(
      (cubit.state.submission as Data<GroupMovementSummary>).data,
      const GroupMovementSummary(movedCount: 1, alreadyThereCount: 0, destinations: {'destino': 'Destino'}),
    );
  });

  test('una preparación tardía no emite después del cierre', () async {
    final pending = Completer<Result<MovementAnimal?>>();
    repository.animalResult = pending.future;
    final loading = cubit.start(const ['a1']);
    await cubit.close();

    pending.complete(const Result.success(_animal));
    await loading;

    expect(cubit.state.preparation, isA<Loading<GroupMovementPreparation>>());
  });

  test('dos lecturas simultáneas de la misma caravana agregan un solo animal', () async {
    await cubit.start(const ['a1']);
    final pending = Completer<Result<MovementAnimal?>>();
    repository.tagResult = pending.future;

    final first = cubit.addTag('002');
    final repeated = cubit.addTag('002');
    await cubit.submit('Rotación');
    expect(move.calls, 0);
    pending.complete(Result.success(_animal.copyWith(id: 'a2', visualTag: '002')));

    expect(await Future.wait([first, repeated]), [true, false]);
    expect(cubit.state.animals.map((animal) => animal.id), ['a1', 'a2']);
    expect(
      (cubit.state.tagResolution as ResultError<MovementAnimal>).error.reason,
      const MovementFailure.alreadySelected('002'),
    );
  });

  test('guardar dos veces y editar durante el guardado no duplica la operación', () async {
    await cubit.start(const ['a1']);
    cubit.selectDestination('destino');
    final pending = Completer<Result<LotAnimalMovement>>();
    move.result = pending.future;

    final saving = cubit.submit('Rotación');
    await cubit.submit('Rotación');
    cubit
      ..remove('a1')
      ..selectDestination('otro')
      ..selectDate(DateTime.utc(2026));
    expect(await cubit.addTag('002'), isFalse);

    expect(move.calls, 1);
    expect(cubit.state.destinationId, 'destino');
    expect(cubit.state.animals, [_animal]);
    expect(cubit.state.occurredAt, isNull);
    pending.complete(const Result.failure(DomainException(message: 'offline')));
    await saving;
  });

  test('cerrar con lecturas en cola descarta ambas sin emitir tarde', () async {
    await cubit.start(const ['a1']);
    final pending = Completer<Result<MovementAnimal?>>();
    repository.tagResult = pending.future;
    final first = cubit.addTag('002');
    final second = cubit.addTag('003');
    await cubit.close();
    pending.complete(Result.success(_animal.copyWith(id: 'a2')));

    expect(await Future.wait([first, second]), [false, false]);
    expect(cubit.state.animals, [_animal]);
  });

  test('las copias tienen igualdad por valor y permiten limpiar campos nulos', () {
    const state = GroupMovementState(animals: [_animal], destinationId: 'destino');
    expect(state.copyWith(), state);
    expect(state.copyWith(destinationId: null).destinationId, isNull);
    expect(_animal.copyWith(breed: 'Angus'), isNot(_animal));
  });

  for (final changeDestination in [false, true]) {
    test('un reintento parcial no repite el origen guardado; cambia destino: $changeDestination', () async {
      await cubit.start(const ['a1']);
      repository.tagResult = Future.value(Result.success(_animal.copyWith(id: 'a2', lotId: 'otro-origen')));
      await cubit.addTag('002');
      cubit.selectDestination('destino');
      move.failOnceSource = 'otro-origen';

      await cubit.submit('Rotación');

      expect(cubit.state.submission, isA<ResultError<GroupMovementSummary>>());
      expect(cubit.state.animals.map((animal) => animal.id), ['a2']);
      expect(cubit.state.savedSummary.movedCount, 1);
      expect(cubit.state.savedSummary.destinations, {'destino': 'Destino'});
      if (changeDestination) cubit.selectDestination('segundo-destino');
      await cubit.submit('Rotación');

      final summary = (cubit.state.submission as Data<GroupMovementSummary>).data;
      expect(summary.movedCount, 2);
      expect(summary.destinations, {
        'destino': 'Destino',
        if (changeDestination) 'segundo-destino': 'Segundo destino',
      });
      expect(move.sourceCalls, ['origen', 'otro-origen', 'otro-origen']);
    });
  }
}

const _animal = MovementAnimal(
  id: 'a1',
  establishmentId: 'campo-1',
  visualTag: '001',
  rfidTagNumber: '982000000000001',
  breed: 'Hereford',
  categoryName: 'Novillo',
  lotId: 'origen',
  lotName: 'Origen',
);

class _Repository extends Fake implements AnimalMovementRepository {
  Future<Result<MovementAnimal?>>? animalResult;
  Future<Result<MovementAnimal?>>? tagResult;

  @override
  Future<Result<MovementAnimal?>> getAnimal(String animalId) =>
      animalResult ?? Future.value(const Result.success(_animal));

  @override
  Future<Result<MovementAnimal?>> findAnimalByTag(
    String tag, {
    required String establishmentId,
    required MovementTagKind kind,
  }) => tagResult ?? Future.value(const Result.success(null));

  @override
  Future<Result<List<MovementDestination>>> getDestinations(String establishmentId) async => const Result.success([
    MovementDestination(id: 'destino', name: 'Destino', animalCount: 0),
    MovementDestination(id: 'segundo-destino', name: 'Segundo destino', animalCount: 0),
  ]);
}

class _Move extends Fake implements MoveLotAnimalsUseCase {
  Future<Result<LotAnimalMovement>>? result;
  int calls = 0;
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
  }) {
    calls++;
    sourceCalls.add(sourceLotId);
    if (sourceLotId == failOnceSource) {
      failOnceSource = null;
      return Future.value(
        const Result.failure(DomainException(message: 'write_failed', code: DomainErrorCode.offline)),
      );
    }
    return result ??
        Future.value(
          Result.success(
            LotAnimalMovement(
              id: 'movement-1',
              establishmentId: establishmentId,
              sourceLotId: sourceLotId,
              destinationLotId: destinationLotId,
              animalIds: animalIds,
              occurredAt: occurredAt,
              reason: reason,
              createdAt: occurredAt,
              updatedAt: occurredAt,
            ),
          ),
        );
  }
}
