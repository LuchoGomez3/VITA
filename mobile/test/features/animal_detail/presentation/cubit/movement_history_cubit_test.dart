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
    final updated = cubit.stream.first;
    repository.reads.last.complete(const Result.success([]));
    await updated;
    repository.reads.first.complete(Result.success([_entry]));
    await oldLoad;
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

  @override
  Stream<void> get historyChanges => changes.stream;

  @override
  Future<Result<List<MovementHistoryEntry>>> getHistory(String animalId) {
    final read = Completer<Result<List<MovementHistoryEntry>>>();
    reads.add(read);
    return read.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}
