import 'dart:async';

import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
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
  }) : _prepareInitialDataSyncUseCase = prepareInitialDataSyncUseCase,
       _onClose = onClose;

  final PrepareInitialDataSyncUseCase _prepareInitialDataSyncUseCase;
  final void Function()? _onClose;
  final StreamController<Result<PostAuthenticationSummary>> _results =
      StreamController<Result<PostAuthenticationSummary>>.broadcast();
  Future<Result<PostAuthenticationSummary>>? _activeSync;
  bool _isDisposed = false;

  /// Resultados de cada ciclo terminado, exitoso o fallido.
  Stream<Result<PostAuthenticationSummary>> get results => _results.stream;

  /// Ejecuta o reutiliza el ciclo de sincronizacion que ya esta en curso.
  Future<Result<PostAuthenticationSummary>> synchronize() {
    final activeSync = _activeSync;
    if (activeSync != null) return activeSync;

    late final Future<Result<PostAuthenticationSummary>> operation;
    operation = _prepareInitialDataSyncUseCase()
        .then((result) {
          if (!_isDisposed) _results.add(result);
          return result;
        })
        .whenComplete(() {
          if (identical(_activeSync, operation)) _activeSync = null;
        });
    _activeSync = operation;
    return operation;
  }

  /// Libera el stream y el cliente HTTP de alcance global.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _results.close();
    _onClose?.call();
  }
}
