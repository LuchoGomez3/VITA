/// Serializa recargas y agrupa los pedidos recibidos mientras una está activa.
///
/// Una ráfaga deja una sola recarga pendiente. El cierre impide iniciar trabajo
/// adicional; el dueño sigue siendo responsable de descartar respuestas tardías.
class CoalescedTask {
  /// Crea la tarea sin ejecutarla.
  CoalescedTask(this._action);

  final Future<void> Function() _action;
  Future<void>? _running;
  bool _requested = false;
  bool _closed = false;

  /// Espera hasta completar también los pedidos agrupados durante la ejecución.
  Future<void> run() {
    if (_closed) return Future<void>.value();
    _requested = true;
    return _running ??= _drain();
  }

  Future<void> _drain() async {
    try {
      while (_requested && !_closed) {
        _requested = false;
        await Future<void>.sync(_action);
      }
    } finally {
      _running = null;
    }
  }

  /// Descarta pedidos pendientes sin esperar una lectura que no es cancelable.
  void close() {
    _closed = true;
    _requested = false;
  }
}
