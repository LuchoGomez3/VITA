import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/utils/coalesced_task.dart';

void main() {
  test('un error síncrono permite volver a solicitar la tarea', () async {
    var calls = 0;
    final task = CoalescedTask(() {
      if (++calls == 1) throw StateError('read failed');
      return Future<void>.value();
    });

    await expectLater(task.run(), throwsStateError);
    await task.run();
    expect(calls, 2);
  });

  test('cerrar descarta la recarga pendiente sin bloquear la lectura activa', () async {
    var calls = 0;
    final pending = Completer<void>();
    final task = CoalescedTask(() {
      calls++;
      return pending.future;
    });
    final running = task.run();
    unawaited(task.run());
    task.close();
    pending.complete();

    await running;
    await task.run();
    expect(calls, 1);
  });
}
