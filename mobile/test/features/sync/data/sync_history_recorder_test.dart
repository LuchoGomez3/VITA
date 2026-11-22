import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/sync_history_recorder.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';

void main() {
  late StreamController<BackendSyncResult> results;
  late DateTime clock;
  late SyncHistoryRecorder recorder;

  setUp(() {
    results = StreamController<BackendSyncResult>.broadcast();
    clock = DateTime(2026, 11, 3, 11);
    recorder = SyncHistoryRecorder(results: results.stream, capacity: 3, now: () => clock);
  });

  tearDown(() async {
    await recorder.dispose();
    await results.close();
  });

  test('recuerda solo lo que el backend aceptó, el más reciente primero', () async {
    recorder.start();
    final emissions = <List<SyncSentRecord>>[];
    final subscription = recorder.watch().listen(emissions.add);
    await pumpEventQueue();
    expect(emissions, [isEmpty]);

    results.add(_result('/api/v1/pesajes', 'pesaje-1'));
    clock = clock.add(const Duration(minutes: 1));
    results
      ..add(_result('/api/v1/movimientos_lotes', 'movimiento-1'))
      ..add(_result('/api/v1/animales', 'animal-1', synchronized: false));
    await pumpEventQueue();

    final latest = emissions.last;
    expect(latest.map((record) => record.localId), ['movimiento-1', 'pesaje-1']);
    expect(latest.first.kind, SyncOperationKind.lotMovement);
    expect(latest.first.sentAt, DateTime(2026, 11, 3, 11, 1));
    expect(latest.last.kind, SyncOperationKind.weighing);
    await subscription.cancel();
  });

  test('conserva como máximo la capacidad configurada', () async {
    recorder.start();
    for (var index = 1; index <= 5; index++) {
      results.add(_result('/api/v1/pesajes', 'pesaje-$index'));
    }
    await pumpEventQueue();

    final current = await recorder.watch().first;
    expect(current.map((record) => record.localId), ['pesaje-5', 'pesaje-4', 'pesaje-3']);
  });

  test('un registro confirmado dos veces aparece una sola vez, con la última hora', () async {
    recorder.start();
    results
      ..add(_result('/api/v1/movimientos_lotes', 'movimiento-1'))
      ..add(_result('/api/v1/pesajes', 'pesaje-1'));
    await pumpEventQueue();
    clock = clock.add(const Duration(seconds: 5));
    results.add(_result('/api/v1/movimientos_lotes', 'movimiento-1'));
    await pumpEventQueue();

    final current = await recorder.watch().first;
    expect(current.map((record) => record.localId), ['movimiento-1', 'pesaje-1']);
    expect(current.first.sentAt, DateTime(2026, 11, 3, 11, 0, 5));
  });

  test('un suscriptor nuevo recibe lo enviado antes de abrir la pantalla', () async {
    recorder
      ..start()
      ..start();
    results.add(_result('/api/v1/animales', 'animal-1'));
    await pumpEventQueue();

    final current = await recorder.watch().first;
    expect(current, hasLength(1));
    expect(current.single.kind, SyncOperationKind.animal);
  });
}

BackendSyncResult _result(String path, String id, {bool synchronized = true}) =>
    BackendSyncResult(resourcePath: path, localId: id, synchronized: synchronized);
