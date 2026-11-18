import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Emite si el dispositivo tiene alguna conexión: primero el estado actual y
/// después cada cambio, sin repetir valores.
///
/// `onConnectivityChanged` solo avisa cuando la conectividad cambia, así que
/// una pantalla que se abre ya sin señal nunca se enteraría. Por eso se
/// consulta [check] al suscribirse. Si esa consulta falla, se sigue solo con
/// los cambios: la pantalla queda en "estado desconocido" en vez de romperse.
/// Un cambio que llega antes que la respuesta de [check] tiene prioridad.
Stream<bool> connectivityStatus({
  required Future<List<ConnectivityResult>> Function() check,
  required Stream<List<ConnectivityResult>> changes,
}) {
  late final StreamController<bool> controller;
  StreamSubscription<List<ConnectivityResult>>? changesSubscription;
  bool? last;
  var changed = false;

  bool isOnline(List<ConnectivityResult> results) => results.any((result) => result != ConnectivityResult.none);

  void emit({required bool online}) {
    if (controller.isClosed || online == last) return;
    last = online;
    controller.add(online);
  }

  controller = StreamController<bool>(
    onListen: () {
      changesSubscription = changes.listen((results) {
        changed = true;
        emit(online: isOnline(results));
      });
      check().then(
        (results) {
          if (!changed) emit(online: isOnline(results));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[Connectivity] initial check failed: $error\n$stackTrace');
        },
      );
    },
    onCancel: () async {
      await changesSubscription?.cancel();
      await controller.close();
    },
  );
  return controller.stream;
}
