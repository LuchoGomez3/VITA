import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/sync_activity_repository.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/sync_queue_repository.dart';
import 'package:frontend_mayoral/features/sync/presentation/cubit/sync_queue_cubit.dart';

void main() {
  late StreamController<SyncQueueSnapshot> queue;
  late StreamController<bool> connectivity;

  setUp(() {
    queue = StreamController<SyncQueueSnapshot>();
    connectivity = StreamController<bool>();
  });

  tearDown(() async {
    await queue.close();
    await connectivity.close();
  });

  SyncQueueCubit build({Future<bool> Function()? synchronizeNow}) => SyncQueueCubit(
    repository: _FakeRepository(queue.stream),
    connectivityChanges: connectivity.stream,
    synchronizeNow: synchronizeNow ?? () async => true,
  );

  test('refleja la cola y la conectividad a medida que cambian', () async {
    final cubit = build();
    expect(cubit.state.snapshot, isNull);

    queue.add(_snapshot(2));
    connectivity.add(false);
    await pumpEventQueue();
    expect(cubit.state.pendingCount, 2);
    expect(cubit.state.isOnline, isFalse);

    queue.add(_snapshot(0));
    connectivity.add(true);
    await pumpEventQueue();
    expect(cubit.state.pendingCount, 0);
    expect(cubit.state.isOnline, isTrue);

    await cubit.close();
  });

  test('un error de lectura se muestra y se limpia con la próxima foto', () async {
    final cubit = build();

    queue.addError(const DomainException(message: 'sqlite'));
    await pumpEventQueue();
    expect(cubit.state.error?.message, 'sqlite');

    queue.add(_snapshot(1));
    await pumpEventQueue();
    expect(cubit.state.error, isNull);
    expect(cubit.state.pendingCount, 1);

    await cubit.close();
  });

  test('sincronizar ahora informa el resultado y no se superpone', () async {
    final pending = Completer<bool>();
    var calls = 0;
    final cubit = build(
      synchronizeNow: () {
        calls++;
        return pending.future;
      },
    );

    final first = cubit.synchronizeNow();
    expect(cubit.state.isSynchronizing, isTrue);
    await cubit.synchronizeNow();
    expect(calls, 1);

    pending.complete(false);
    expect(await first, isFalse);
    expect(cubit.state.isSynchronizing, isFalse);

    await cubit.close();
  });

  test('suma los rechazados y lo enviado, y un error en rechazados no tapa la cola', () async {
    final rejections = StreamController<List<SyncRejectedRecord>>();
    final history = StreamController<List<SyncSentRecord>>();
    final cubit = SyncQueueCubit(
      repository: _FakeRepository(queue.stream),
      connectivityChanges: connectivity.stream,
      synchronizeNow: () async => true,
      rejections: _FakeRejections(rejections.stream),
      history: _FakeHistory(history.stream),
    );

    final rejected = SyncRejectedRecord(
      localId: 'pesaje-1',
      kind: SyncOperationKind.weighing,
      recordedAt: DateTime(2026, 11, 3),
    );
    final sent = SyncSentRecord(localId: 'mov-1', kind: SyncOperationKind.lotMovement, sentAt: DateTime(2026, 11, 3));
    queue.add(_snapshot(1));
    rejections.add([rejected]);
    history.add([sent]);
    await pumpEventQueue();
    expect(cubit.state.rejected, [rejected]);
    expect(cubit.state.recentlySent, [sent]);

    rejections.addError(const DomainException(message: 'sqlite'));
    await pumpEventQueue();
    expect(cubit.state.error, isNull);
    expect(cubit.state.rejected, [rejected]);
    expect(cubit.state.pendingCount, 1);

    await cubit.close();
    await rejections.close();
    await history.close();
  });

  test('una excepción al sincronizar se informa como fallo', () async {
    final cubit = build(synchronizeNow: () async => throw StateError('sin red'));

    expect(await cubit.synchronizeNow(), isFalse);
    expect(cubit.state.isSynchronizing, isFalse);

    await cubit.close();
  });
}

SyncQueueSnapshot _snapshot(int pending) => SyncQueueSnapshot(
  readAt: DateTime(2026, 11, 3),
  operations: [
    for (var index = 0; index < pending; index++)
      SyncQueueOperation(
        queueId: index,
        kind: SyncOperationKind.weighing,
        state: SyncOperationState.waiting,
        attempts: 1,
        queuedAt: DateTime(2026, 11, 3),
        lastAttemptAt: DateTime(2026, 11, 3),
      ),
  ],
);

class _FakeRepository implements SyncQueueRepository {
  _FakeRepository(this._stream);

  final Stream<SyncQueueSnapshot> _stream;

  @override
  Stream<SyncQueueSnapshot> watch() => _stream;
}

class _FakeRejections implements SyncRejectionsRepository {
  _FakeRejections(this._stream);

  final Stream<List<SyncRejectedRecord>> _stream;

  @override
  Stream<List<SyncRejectedRecord>> watch() => _stream;
}

class _FakeHistory implements SyncHistoryRepository {
  _FakeHistory(this._stream);

  final Stream<List<SyncSentRecord>> _stream;

  @override
  Stream<List<SyncSentRecord>> watch() => _stream;
}
