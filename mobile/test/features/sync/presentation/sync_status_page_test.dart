import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/app_toast_host.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/sync_activity_repository.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/sync_queue_repository.dart';
import 'package:frontend_mayoral/features/sync/presentation/cubit/sync_queue_cubit.dart';
import 'package:frontend_mayoral/features/sync/presentation/pages/sync_status_page.dart';
import 'package:frontend_mayoral/features/sync/presentation/strings/sync_status_strings.dart';

void main() {
  late StreamController<SyncQueueSnapshot> queue;
  late StreamController<bool> connectivity;
  late StreamController<List<SyncRejectedRecord>> rejections;
  late StreamController<List<SyncSentRecord>> history;
  late Future<bool> Function() synchronizeNow;

  setUp(() {
    queue = StreamController<SyncQueueSnapshot>();
    connectivity = StreamController<bool>();
    rejections = StreamController<List<SyncRejectedRecord>>();
    history = StreamController<List<SyncSentRecord>>();
    synchronizeNow = () async => true;
  });

  tearDown(() async {
    await queue.close();
    await connectivity.close();
    await rejections.close();
    await history.close();
  });

  Future<void> pumpPage(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      builder: (_, child) => AppToastHost(child: child!),
      home: SyncStatusPage(
        createCubit: () => SyncQueueCubit(
          repository: _FakeRepository(queue.stream),
          connectivityChanges: connectivity.stream,
          synchronizeNow: () => synchronizeNow(),
          rejections: _FakeRejections(rejections.stream),
          history: _FakeHistory(history.stream),
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

  testWidgets('al reconectar, lo pendiente pasa a enviado y los rechazados se destacan', (tester) async {
    await pumpPage(tester);
    queue.add(_snapshot([_operation(1, SyncOperationKind.weighing, SyncOperationState.waiting)]));
    connectivity.add(false);
    rejections.add([
      SyncRejectedRecord(
        localId: 'mov-1',
        kind: SyncOperationKind.lotMovement,
        recordedAt: DateTime(2026, 11, 3, 10),
        errorCode: 'LOTE_INACTIVO',
      ),
    ]);
    history.add(const []);
    await tester.pump();

    expect(find.text(SyncStatusStrings.rejectedSectionTitle), findsOneWidget);
    expect(find.text(SyncStatusStrings.rejectedDetail('LOTE_INACTIVO')), findsOneWidget);
    expect(find.text(SyncStatusStrings.queueSectionTitle), findsOneWidget);
    expect(find.text(SyncStatusStrings.sentSectionTitle), findsNothing);

    queue.add(_snapshot([]));
    connectivity.add(true);
    history.add([
      SyncSentRecord(localId: 'pesaje-1', kind: SyncOperationKind.weighing, sentAt: DateTime(2026, 11, 3, 11)),
    ]);
    await tester.pump();

    expect(find.text(SyncStatusStrings.queueSectionTitle), findsNothing);
    expect(find.text(SyncStatusStrings.sentSectionTitle), findsOneWidget);
    expect(find.text(SyncStatusStrings.sentState), findsOneWidget);
    expect(find.text('Pesaje'), findsOneWidget);
  });

  testWidgets('espera la sincronización manual y conserva los pendientes si falla', (tester) async {
    final pending = Completer<bool>();
    synchronizeNow = () => pending.future;
    await pumpPage(tester);
    queue.add(_snapshot([_operation(1, SyncOperationKind.healthEvent, SyncOperationState.waiting)]));
    connectivity.add(true);
    await tester.pump();

    await tester.tap(find.byTooltip(SyncStatusStrings.refreshTooltip));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(SyncStatusStrings.manualSyncFailed), findsNothing);

    pending.complete(false);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(SyncStatusStrings.manualSyncFailed), findsOneWidget);
    expect(find.text(SyncStatusStrings.pendingSubtitle(1)), findsOneWidget);
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
