import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/sync/queued_request.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/sync_queue_repository_impl.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';

void main() {
  group('operationFromRequest', () {
    SyncQueueOperation map(String method, String path, {int attempts = 1, bool locked = false}) =>
        SyncQueueRepositoryImpl.operationFromRequest(
          _request(method: method, path: path, attempts: attempts, locked: locked),
        );

    test('traduce cada recurso sincronizable a su tipo de operación', () {
      expect(map('POST', '/api/v1/animales').kind, SyncOperationKind.animalRegistration);
      expect(map('PUT', '/api/v1/animales/a-1').kind, SyncOperationKind.animalUpdate);
      expect(map('POST', '/api/v1/pesajes').kind, SyncOperationKind.weighing);
      expect(map('POST', '/api/v1/movimientos_lotes').kind, SyncOperationKind.lotMovement);
      expect(map('POST', '/api/v1/lotes').kind, SyncOperationKind.lot);
      expect(map('POST', '/api/v1/egresos_operativos').kind, SyncOperationKind.operatingExpense);
      expect(
        map('POST', '/api/v1/egresos_operativos/categorias').kind,
        SyncOperationKind.operatingExpenseCategory,
      );
      expect(map('POST', '/api/v1/ventas').kind, SyncOperationKind.other);
    });

    test('no confunde recursos que comparten prefijo', () {
      expect(map('POST', '/api/v1/lotes_historicos').kind, SyncOperationKind.other);
    });

    test('distingue espera, envío en curso y reintento', () {
      expect(map('POST', '/api/v1/pesajes').state, SyncOperationState.waiting);
      expect(map('POST', '/api/v1/pesajes', locked: true).state, SyncOperationState.sending);
      expect(map('POST', '/api/v1/pesajes', attempts: 3).state, SyncOperationState.retrying);
      expect(map('POST', '/api/v1/pesajes', attempts: 3, locked: true).state, SyncOperationState.sending);
    });
  });

  group('watch', () {
    late List<BrickQueuedRequest> queue;
    late StreamController<void> changes;
    late int reads;
    Exception? failWith;

    SyncQueueRepositoryImpl repository({Duration poll = const Duration(hours: 1)}) => SyncQueueRepositoryImpl(
      readQueue: () async {
        reads++;
        final error = failWith;
        if (error != null) throw error;
        return List.of(queue);
      },
      changes: changes.stream,
      pollInterval: poll,
    );

    setUp(() {
      queue = [];
      changes = StreamController<void>.broadcast();
      reads = 0;
      failWith = null;
    });

    tearDown(() => changes.close());

    test('emite la cola al suscribirse', () async {
      queue = [_request(path: '/api/v1/pesajes')];

      final snapshot = await repository().watch().first;

      expect(snapshot.pendingCount, 1);
      expect(snapshot.operations.single.kind, SyncOperationKind.weighing);
    });

    test('vuelve a leer ante un cambio local o una respuesta del backend', () async {
      final emitted = <SyncQueueSnapshot>[];
      final subscription = repository().watch().listen(emitted.add);
      await pumpEventQueue();
      expect(emitted.single.isEmpty, isTrue);

      queue = [_request(path: '/api/v1/animales')];
      changes.add(null);
      await pumpEventQueue();

      expect(emitted, hasLength(2));
      expect(emitted.last.operations.single.kind, SyncOperationKind.animalRegistration);
      await subscription.cancel();
    });

    test('la consulta periódica detecta lo que Brick cambia por su cuenta', () async {
      queue = [_request(path: '/api/v1/pesajes')];
      final emitted = <SyncQueueSnapshot>[];
      final subscription = repository(poll: const Duration(milliseconds: 10)).watch().listen(emitted.add);
      await pumpEventQueue();

      // Brick toma la request y después la borra al recibir el 2xx.
      queue = [_request(path: '/api/v1/pesajes', locked: true)];
      await Future<void>.delayed(const Duration(milliseconds: 30));
      queue = [];
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await subscription.cancel();

      expect(emitted.map((snapshot) => snapshot.isSending), [false, true, false]);
      expect(emitted.last.isEmpty, isTrue);
    });

    test('no reemite si la cola no cambió entre consultas', () async {
      queue = [_request(path: '/api/v1/pesajes')];
      final emitted = <SyncQueueSnapshot>[];
      final subscription = repository(poll: const Duration(milliseconds: 5)).watch().listen(emitted.add);

      await Future<void>.delayed(const Duration(milliseconds: 40));
      await subscription.cancel();

      expect(reads, greaterThan(2));
      expect(emitted, hasLength(1));
    });

    test('un error de lectura no corta el stream y la próxima lectura se recupera', () async {
      failWith = Exception('database is locked');
      final emitted = <SyncQueueSnapshot>[];
      final errors = <Object>[];
      final subscription = repository().watch().listen(emitted.add, onError: errors.add);
      await pumpEventQueue();

      expect(errors.single, isA<DomainException>());
      expect(emitted, isEmpty);

      failWith = null;
      changes.add(null);
      await pumpEventQueue();

      expect(emitted.single.isEmpty, isTrue);
      await subscription.cancel();
    });

    test('deja de consultar al cancelar la suscripción', () async {
      final subscription = repository(poll: const Duration(milliseconds: 5)).watch().listen((_) {});
      await pumpEventQueue();
      await subscription.cancel();
      final readsAfterCancel = reads;

      await Future<void>.delayed(const Duration(milliseconds: 30));
      changes.add(null);
      await pumpEventQueue();

      expect(reads, readsAfterCancel);
    });
  });
}

BrickQueuedRequest _request({
  required String path,
  int queueId = 1,
  String method = 'POST',
  int attempts = 1,
  bool locked = false,
}) {
  return BrickQueuedRequest(
    queueId: queueId,
    method: method,
    path: path,
    attempts: attempts,
    isLocked: locked,
    createdAt: DateTime(2026, 11, 3, 11, 42),
    updatedAt: DateTime(2026, 11, 3, 11, 42),
  );
}
