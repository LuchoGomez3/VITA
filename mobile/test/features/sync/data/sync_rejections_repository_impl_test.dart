import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/sync_rejections_repository_impl.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';

void main() {
  late StreamController<void> changes;
  late List<SyncRejectedRecord> stored;
  late int reads;
  Error? failWith;

  setUp(() {
    changes = StreamController<void>.broadcast();
    stored = [];
    reads = 0;
    failWith = null;
  });

  tearDown(() => changes.close());

  SyncRejectionsRepositoryImpl build() => SyncRejectionsRepositoryImpl(
    readRejected: () async {
      reads++;
      final error = failWith;
      if (error != null) throw error;
      return List.of(stored);
    },
    changes: changes.stream,
  );

  test('emite al suscribirse y relee ante cada cambio', () async {
    final emissions = <List<SyncRejectedRecord>>[];
    final subscription = build().watch().listen(emissions.add);
    await pumpEventQueue();
    expect(emissions, [isEmpty]);

    stored = [_record('pesaje-1')];
    changes.add(null);
    await pumpEventQueue();

    expect(emissions, hasLength(2));
    expect(emissions.last.single.localId, 'pesaje-1');
    await subscription.cancel();
  });

  test('no reemite si los rechazados no cambiaron', () async {
    stored = [_record('pesaje-1')];
    final emissions = <List<SyncRejectedRecord>>[];
    final subscription = build().watch().listen(emissions.add);
    await pumpEventQueue();

    changes
      ..add(null)
      ..add(null);
    await pumpEventQueue();

    expect(reads, greaterThan(1));
    expect(emissions, hasLength(1));
    await subscription.cancel();
  });

  test('un error de lectura se informa y la próxima lectura se recupera', () async {
    failWith = StateError('sqlite cerrado');
    final emissions = <List<SyncRejectedRecord>>[];
    final errors = <Object>[];
    final subscription = build().watch().listen(emissions.add, onError: errors.add);
    await pumpEventQueue();
    expect(errors.single, isA<DomainException>());

    failWith = null;
    changes.add(null);
    await pumpEventQueue();

    expect(emissions, [isEmpty]);
    await subscription.cancel();
  });

  test('deja de leer al cancelar la suscripción', () async {
    final subscription = build().watch().listen((_) {});
    await pumpEventQueue();
    await subscription.cancel();
    final readsBefore = reads;

    changes.add(null);
    await pumpEventQueue();

    expect(reads, readsBefore);
  });
}

SyncRejectedRecord _record(String id) => SyncRejectedRecord(
  localId: id,
  kind: SyncOperationKind.weighing,
  recordedAt: DateTime(2026, 11, 3),
  errorCode: 'ANIMAL_INEXISTENTE',
);
