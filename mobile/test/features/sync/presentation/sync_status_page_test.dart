import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/sync_queue_repository.dart';
import 'package:frontend_mayoral/features/sync/presentation/cubit/sync_queue_cubit.dart';
import 'package:frontend_mayoral/features/sync/presentation/pages/sync_status_page.dart';
import 'package:frontend_mayoral/features/sync/presentation/strings/sync_status_strings.dart';

void main() {
  late StreamController<SyncQueueSnapshot> queue;
  late StreamController<bool> connectivity;
  late Future<bool> Function() synchronizeNow;

  setUp(() {
    queue = StreamController<SyncQueueSnapshot>();
    connectivity = StreamController<bool>();
    synchronizeNow = () async => true;
  });

  tearDown(() async {
    await queue.close();
    await connectivity.close();
  });

  Future<void> pumpPage(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: SyncStatusPage(
        createCubit: () => SyncQueueCubit(
          repository: _FakeRepository(queue.stream),
          connectivityChanges: connectivity.stream,
          synchronizeNow: () => synchronizeNow(),
        ),
      ),
    ),
  );

  testWidgets('sin señal muestra lo guardado en el teléfono y cada operación', (tester) async {
    await pumpPage(tester);
    expect(find.text(SyncStatusStrings.loadingSubtitle), findsOneWidget);

    queue.add(
      _snapshot([
        _operation(1, SyncOperationKind.weighing, SyncOperationState.waiting),
        _operation(2, SyncOperationKind.lotMovement, SyncOperationState.retrying, attempts: 3),
      ]),
    );
    connectivity.add(false);
    await tester.pump();

    expect(find.text(SyncStatusStrings.pendingSubtitle(2)), findsOneWidget);
    expect(find.text(SyncStatusStrings.offlineBannerTitle(2)), findsOneWidget);
    expect(find.text('Pesaje'), findsOneWidget);
    expect(find.text('Movimiento entre lotes'), findsOneWidget);
    expect(find.text('Reintentando · 2 fallos'), findsOneWidget);
  });

  testWidgets('la lista se actualiza en vivo hasta quedar vacía', (tester) async {
    await pumpPage(tester);
    queue.add(_snapshot([_operation(1, SyncOperationKind.animalRegistration, SyncOperationState.sending)]));
    connectivity.add(true);
    await tester.pump();
    expect(find.text(SyncStatusStrings.sendingBannerTitle(1)), findsOneWidget);
    expect(find.text('Alta de animal'), findsOneWidget);

    queue.add(_snapshot([]));
    await tester.pump();

    expect(find.text('Alta de animal'), findsNothing);
    expect(find.text(SyncStatusStrings.queueSectionTitle), findsNothing);
    expect(find.text(SyncStatusStrings.emptyBannerTitle), findsWidgets);
  });

  testWidgets('avisa si la sincronización manual falla', (tester) async {
    synchronizeNow = () async => false;
    await pumpPage(tester);
    queue.add(_snapshot([]));
    await tester.pump();

    await tester.tap(find.byTooltip(SyncStatusStrings.refreshTooltip));
    await tester.pump();
    await tester.pump();

    expect(find.text(SyncStatusStrings.manualSyncFailed), findsOneWidget);
  });
}

SyncQueueSnapshot _snapshot(List<SyncQueueOperation> operations) =>
    SyncQueueSnapshot(operations: operations, readAt: DateTime(2026, 11, 3));

SyncQueueOperation _operation(int id, SyncOperationKind kind, SyncOperationState state, {int attempts = 1}) =>
    SyncQueueOperation(
      queueId: id,
      kind: kind,
      state: state,
      attempts: attempts,
      queuedAt: DateTime(2026, 11, 3, 11, 42),
      lastAttemptAt: DateTime(2026, 11, 3, 11, 42),
    );

class _FakeRepository implements SyncQueueRepository {
  _FakeRepository(this._stream);

  final Stream<SyncQueueSnapshot> _stream;

  @override
  Stream<SyncQueueSnapshot> watch() => _stream;
}
