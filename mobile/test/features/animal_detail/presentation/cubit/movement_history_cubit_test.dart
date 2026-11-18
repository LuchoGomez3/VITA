import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_movement_history_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/movement_history_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';

void main() {
  test('una lectura vieja no reemplaza una invalidación ya resuelta', () async {
    final repository = _DelayedRepository();
    final cubit = MovementHistoryCubit(GetAnimalMovementHistoryUseCase(repository));
    addTearDown(repository.changes.close);
    addTearDown(cubit.close);
    final oldLoad = cubit.load('a1');
    repository.changes.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(repository.reads, hasLength(1));
    repository.reads.first.complete(Result.success([_entry]));
    await Future<void>.delayed(Duration.zero);
    expect(repository.reads, hasLength(2));
    expect(cubit.state, isA<Initial<List<MovementHistoryEntry>>>());
    repository.reads.last.complete(const Result.success([]));
    await oldLoad;
    expect((cubit.state as Data<List<MovementHistoryEntry>>).data, isEmpty);
  });

  test('500 invalidaciones durante una lectura dejan una sola recarga pendiente', () async {
    final repository = _DelayedRepository();
    final cubit = MovementHistoryCubit(GetAnimalMovementHistoryUseCase(repository));
    addTearDown(repository.changes.close);
    addTearDown(cubit.close);
    final loading = cubit.load('a1');
    for (var i = 0; i < 500; i++) {
      repository.changes.add(null);
    }
    await Future<void>.delayed(Duration.zero);
    expect(repository.reads, hasLength(1));
    repository.reads.first.complete(Result.success([_entry]));
    await Future<void>.delayed(Duration.zero);
    expect(repository.reads, hasLength(2));
    final current = _entry.copyWith(movementId: 'latest', syncStatus: MovementSyncStatus.synchronized);
    repository.reads.last.complete(Result.success([current]));
    await loading;
    expect(repository.reads, hasLength(2));
    expect((cubit.state as Data<List<MovementHistoryEntry>>).data, [current]);
  });

  test('un cambio de animal pendiente consulta solo el último solicitado', () async {
    final repository = _DelayedRepository();
    final cubit = MovementHistoryCubit(GetAnimalMovementHistoryUseCase(repository));
    addTearDown(repository.changes.close);
    addTearDown(cubit.close);
    final first = cubit.load('a1');
    final latest = cubit.load('a2');
    repository.reads.first.complete(Result.success([_entry]));
    await Future<void>.delayed(Duration.zero);
    expect(repository.animalIds, ['a1', 'a2']);
    repository.reads.last.complete(const Result.success([]));
    await Future.wait([first, latest]);
    expect((cubit.state as Data<List<MovementHistoryEntry>>).data, isEmpty);
  });

  test('cierra la escucha y descarta la lectura pendiente al salir', () async {
    final repository = _DelayedRepository();
    final cubit = MovementHistoryCubit(GetAnimalMovementHistoryUseCase(repository));
    addTearDown(repository.changes.close);
    final pending = cubit.load('a1');
    expect(repository.changes.hasListener, isTrue);
    await cubit.close();
    expect(repository.changes.hasListener, isFalse);
    repository.reads.single.complete(Result.success([_entry]));
    await pending;
    repository.changes.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(repository.reads, hasLength(1));
  });
}

final _entry = MovementHistoryEntry(
  fromLotName: null,
  movementId: 'old',
  toLotName: 'Bajo',
  occurredAt: DateTime.utc(2026),
  reason: 'Rotación',
  syncStatus: MovementSyncStatus.pending,
);

class _DelayedRepository implements AnimalMovementRepository {
  final changes = StreamController<void>.broadcast();
  final reads = <Completer<Result<List<MovementHistoryEntry>>>>[];
  final animalIds = <String>[];

  @override
  Stream<void> get historyChanges => changes.stream;

  @override
  Future<Result<List<MovementHistoryEntry>>> getHistory(String animalId) {
    animalIds.add(animalId);
    final read = Completer<Result<List<MovementHistoryEntry>>>();
    reads.add(read);
    return read.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}
