import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/connectivity_status.dart';

void main() {
  test('al abrir sin señal informa offline aunque la conectividad no cambie', () async {
    final changes = StreamController<List<ConnectivityResult>>();
    final emissions = <bool>[];
    final subscription = connectivityStatus(
      check: () async => [ConnectivityResult.none],
      changes: changes.stream,
    ).listen(emissions.add);
    await pumpEventQueue();

    expect(emissions, [false]);

    changes
      ..add([ConnectivityResult.none])
      ..add([ConnectivityResult.wifi, ConnectivityResult.mobile])
      ..add([ConnectivityResult.wifi]);
    await pumpEventQueue();

    expect(emissions, [false, true]);
    await subscription.cancel();
    await changes.close();
  });

  test('si falla la consulta inicial sigue con los cambios', () async {
    final changes = StreamController<List<ConnectivityResult>>();
    final emissions = <bool>[];
    final subscription = connectivityStatus(
      check: () => Future.error(StateError('plugin no disponible')),
      changes: changes.stream,
    ).listen(emissions.add);
    await pumpEventQueue();
    expect(emissions, isEmpty);

    changes.add([ConnectivityResult.none]);
    await pumpEventQueue();

    expect(emissions, [false]);
    await subscription.cancel();
    await changes.close();
  });
}
