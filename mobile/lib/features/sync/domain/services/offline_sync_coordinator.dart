import 'dart:async';

import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/sync/domain/use_cases/prepare_initial_data_sync_use_case.dart';

/// Coordina una unica sincronizacion compartida entre sesion y pantallas.
///
/// Si varios disparadores coinciden (restauracion, conectividad, resume o gesto
/// manual), todos esperan la misma operacion. Los resultados se publican para
/// que las pantallas vuelvan a leer SQLite sin acoplarse a los stores Brick.
class OfflineSyncCoordinator {
  /// Crea el coordinador con el caso de uso y el cierre de su cliente HTTP.
  OfflineSyncCoordinator({
    required PrepareInitialDataSyncUseCase prepareInitialDataSyncUseCase,
    void Function()? onClose,
    Object? Function()? sessionIdentity,
  }) : _prepareInitialDataSyncUseCase = prepareInitialDataSyncUseCase,
       _onClose = onClose,
       _sessionIdentity = sessionIdentity ?? (() => null);

  final PrepareInitialDataSyncUseCase _prepareInitialDataSyncUseCase;
  final void Function()? _onClose;
  final Object? Function() _sessionIdentity;
  Object? _activeSession;
  final StreamController<Result<PostAuthenticationSummary>> _results =
      StreamController<Result<PostAuthenticationSummary>>.broadcast();
  Future<Result<PostAuthenticationSummary>>? _activeSync;
  Future<void>? _catalogUpdate;
  bool _isDisposed = false;

  /// Resultados de cada ciclo terminado, exitoso o fallido.
  Stream<Result<PostAuthenticationSummary>> get results => _results.stream;

  /// Ejecuta o reutiliza el ciclo de sincronizacion que ya esta en curso.
  Future<Result<PostAuthenticationSummary>> synchronize() {
    if (_isDisposed) {
      return Future.value(
        const Result.failure(DomainException(message: 'Session ended', code: DomainErrorCode.unauthorized)),
      );
    }
    final session = _sessionIdentity();
    final catalogUpdate = _catalogUpdate;
    if (catalogUpdate != null) return _synchronizeAfter(catalogUpdate, session);
    final activeSync = _activeSync;
    if (activeSync != null) {
      if (_activeSession == session) return activeSync;
      // Los stores pueden persistir dentro del Future. Descartar solamente su
      // resultado no basta: hay que esperar sus escrituras antes del ciclo nuevo.
      return _synchronizeAfter(activeSync, session);
    }

    late final Future<Result<PostAuthenticationSummary>> operation;
    operation = _prepareInitialDataSyncUseCase()
        .then((result) {
          if (!_isDisposed && session == _sessionIdentity()) _results.add(result);
          return result;
        })
        .whenComplete(() {
          if (identical(_activeSync, operation)) _activeSync = null;
        });
    _activeSync = operation;
    _activeSession = session;
    return operation;
  }

  Future<Result<PostAuthenticationSummary>> _synchronizeAfter<T>(Future<T> previous, Object? session) async {
    await previous;
    if (_isDisposed || session != _sessionIdentity()) {
      return const Result.failure(DomainException(message: 'Session ended', code: DomainErrorCode.unauthorized));
    }
    return synchronize();
  }

  /// Serializa el guardado con el ciclo anterior y avisa antes de descargar.
  /// Así una consulta previa al canje no pisa la membresía confirmada.
  Future<void> updateCatalog(Future<PostAuthenticationSummary> Function() persist) async {
    final session = _sessionIdentity();
    final previous = _catalogUpdate;
    final active = _activeSync;
    final completed = Completer<void>();
    _catalogUpdate = completed.future;
    try {
      await previous;
      await active;
      if (_isDisposed || session != _sessionIdentity()) {
        throw const DomainException(message: 'Session ended', code: DomainErrorCode.unauthorized);
      }
      final summary = await persist();
      if (!_isDisposed && session == _sessionIdentity()) _results.add(Result.success(summary));
    } finally {
      if (identical(_catalogUpdate, completed.future)) _catalogUpdate = null;
      completed.complete();
    }
  }

  /// Fuerza un ciclo posterior a una mutación de membresía confirmada.
  /// Un ciclo que ya estaba en curso puede haber leído el catálogo anterior.
  Future<Result<PostAuthenticationSummary>> synchronizeAfterCurrent() {
    final active = _activeSync;
    if (active != null) return _synchronizeAfter(active, _sessionIdentity());
    return synchronize();
  }

  /// Libera el stream y el cliente HTTP de alcance global.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _results.close();
    _onClose?.call();
  }
}
