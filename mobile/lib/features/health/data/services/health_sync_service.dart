import 'dart:async';

import 'package:frontend_mayoral/brick/auth/guarded_backend_request.dart';
import 'package:frontend_mayoral/brick/models/health_operation.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_registration_recovery.dart';
import 'package:frontend_mayoral/features/health/data/datasources/health_remote_data_source.dart';
import 'package:frontend_mayoral/features/health/data/mappers/health_codec.dart';
import 'package:frontend_mayoral/features/health/data/repositories/health_repository_impl.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
import 'package:logging/logging.dart';

/// Resuelve una dependencia de Sanidad bajo la sesión del envío.
typedef ResolveHealthAnimal =
    Future<AnimalRegistrationAvailability> Function(
      String animalId,
      String establishmentId,
      HealthSession session,
      Future<void> Function() guard,
    );

enum _SyncStep {
  completed,
  waiting,
  failed,
  retryableFailure;

  bool get succeeded => this == completed || this == waiting;
  bool get shouldRetry => this == waiting || this == retryableFailure;
}

/// Drena pendientes durables y descarga cambios por establecimiento.
class HealthSyncService {
  /// Crea el coordinador de Sanidad bajo la sesión compartida.
  HealthSyncService({
    required HealthRepositoryImpl repository,
    required HealthRemoteDataSource remote,
    required ResolveHealthAnimal resolveAnimal,
  }) : _repository = repository,
       _remote = remote,
       _resolveAnimal = resolveAnimal;

  final HealthRepositoryImpl _repository;
  final HealthRemoteDataSource _remote;
  final ResolveHealthAnimal _resolveAnimal;
  static final _logger = Logger('HealthSyncService');
  final _catalogDownloads = <(HealthSession, String), Future<void>>{};
  Future<bool>? _active;
  ({Timer timer, HealthSession session, bool refresh})? _retry;
  bool _requested = false;
  bool _refresh = false;
  bool _closed = false;
  bool _paused = false;

  /// Pide un ciclo y devuelve si la sesión completó sus pedidos sin fallas de sincronización.
  Future<bool> request({bool refresh = false}) {
    final session = _repository.session;
    if (_closed || session == null) return Future.value(false);
    _paused = false;
    _requested = true;
    _refresh = _refresh || refresh;
    final retry = _retry;
    if (retry != null && (retry.session != session || refresh || !retry.refresh)) _cancelRetry();
    return _active ??= _run().whenComplete(() => _active = null);
  }

  /// Descarga únicamente el catálogo solicitado por el formulario.
  Future<void> refreshCatalog(String establishmentId) async {
    final session = _repository.session;
    if (_closed || session == null) return;
    _paused = false;
    await _refreshResource(session, 'catalog', () => _downloadCatalog(session, establishmentId));
  }

  /// Cancela solicitudes programadas que pertenecían a la sesión anterior.
  void pause() {
    _paused = true;
    _requested = false;
    _refresh = false;
    _catalogDownloads.clear();
    _cancelRetry();
  }

  /// Libera los reintentos al cerrar la app.
  void dispose() {
    _closed = true;
    pause();
  }

  Future<bool> _run() async {
    HealthSession? processed;
    var succeeded = true;
    while (_requested) {
      final refresh = _refresh;
      _requested = false;
      _refresh = false;
      final current = _repository.session;
      if (current == null || _closed) return false;
      if (processed != current) succeeded = true;
      processed = current;
      final cycle = await _cycle(current, refresh: refresh);
      succeeded = succeeded && cycle.succeeded;
      final nextCycleCoversRetry = _requested && (_refresh || !refresh);
      if (cycle.retry && !nextCycleCoversRetry && !_paused && !_closed && _repository.session == current) {
        _scheduleRetry(current, refresh: refresh);
      }
    }
    return succeeded && !_closed && !_paused && _repository.session == processed;
  }

  void _scheduleRetry(HealthSession session, {required bool refresh}) {
    final scheduled = _retry;
    if (scheduled != null && scheduled.session == session && (scheduled.refresh || !refresh)) return;
    _cancelRetry();
    final timer = Timer(const Duration(seconds: 30), () {
      _retry = null;
      if (_repository.session == session) unawaited(request(refresh: refresh));
    });
    _retry = (timer: timer, session: session, refresh: refresh);
  }

  void _cancelRetry() {
    _retry?.timer.cancel();
    _retry = null;
  }

  Future<({bool succeeded, bool retry})> _cycle(HealthSession session, {required bool refresh}) async {
    try {
      final establishments = await _repository.establishments();
      final operations = await _repository.pendingOperations();
      var succeeded = true;
      var retry = false;
      void track(_SyncStep step) {
        succeeded = succeeded && step.succeeded;
        retry = retry || step.shouldRetry;
      }

      for (final establishment in establishments) {
        final id = establishment.id;
        final pending = operations.where((operation) => operation.establishmentId == id).toList();
        if (!refresh && pending.isEmpty) continue;
        Future<void> guard() => _authorize(session, id);

        for (final operation in [
          ...pending.where((item) => item.resultEventId == null),
          ...pending.where((item) => item.resultEventId != null),
        ]) {
          track(await _attempt(session, operation, guard));
        }
        if (refresh) {
          track(
            await _refreshResource(session, 'catalog', () => _downloadCatalog(session, id)),
          );
          track(await _refreshResource(session, 'history', () => _pull(session, id, guard)));
        }
      }
      return (succeeded: succeeded, retry: retry);
    } on Object catch (error) {
      if (_repository.session != session || _paused || _closed) return (succeeded: false, retry: false);
      _logger.warning('Health synchronization interrupted (${error.runtimeType})');
      return (succeeded: false, retry: true);
    }
  }

  Future<void> _authorize(HealthSession session, String establishmentId) async {
    _repository.requireSession(session);
    final authorized = await _repository.authorize(establishmentId);
    if (_closed || _paused || authorized != session) {
      throw const HealthFailure(HealthProblem.unauthorized);
    }
  }

  Future<void> _downloadCatalog(HealthSession session, String establishmentId) {
    final key = (session, establishmentId);
    final active = _catalogDownloads[key];
    if (active != null) return active;
    late final Future<void> download;
    Future<void> guard() async {
      await _authorize(session, establishmentId);
      if (!identical(_catalogDownloads[key], download)) {
        throw const HealthFailure(HealthProblem.unauthorized);
      }
    }

    Future<void> fetch() async {
      final catalog = await _remote.catalog(establishmentId, guard);
      await guard();
      await _repository.cacheCatalog(session, catalog);
    }

    // Registra la descarga antes de que el transporte consulte la sesión.
    download = Future<void>.microtask(fetch).whenComplete(() {
      if (identical(_catalogDownloads[key], download)) _catalogDownloads.remove(key);
    });
    return _catalogDownloads[key] = download;
  }

  Future<_SyncStep> _refreshResource(HealthSession session, String resource, Future<void> Function() refresh) async {
    if (_closed || _paused || _repository.session != session) return _SyncStep.failed;
    try {
      await refresh();
      return _SyncStep.completed;
    } on HealthRemoteFailure catch (error) {
      if (error.routeUnavailable) return _SyncStep.completed;
      _logger.warning('Health $resource refresh returned HTTP ${error.status}');
      return _transient(error) ? _SyncStep.retryableFailure : _SyncStep.failed;
    } on Object catch (error) {
      if (_closed || _paused || _repository.session != session) return _SyncStep.failed;
      _logger.warning('Health $resource refresh interrupted (${error.runtimeType})');
      return _SyncStep.retryableFailure;
    }
  }

  Future<_SyncStep> _attempt(
    HealthSession session,
    BrickHealthOperationModel operation,
    Future<void> Function() guard,
  ) async {
    try {
      await guard();
      final resultId = operation.resultEventId;
      if (resultId == null) {
        final animals = (HealthCodec.object(operation.payload)['animales'] as List).cast<Map<String, dynamic>>();
        for (final entry in animals) {
          final animalId = entry['animal_id'] as String;
          final availability = await _resolveAnimal(
            animalId,
            operation.establishmentId,
            session,
            guard,
          );
          if (availability != AnimalRegistrationAvailability.confirmed) {
            if (availability == AnimalRegistrationAvailability.rejected) {
              await _repository.reject(
                session,
                operation,
                HealthCodec.animalRegistrationRejectedCode,
                details: (animalId: animalId, field: null),
              );
            }
            return availability == AnimalRegistrationAvailability.rejected ? _SyncStep.completed : _SyncStep.waiting;
          }
        }
      } else {
        final event = await _repository.localEvent(operation.establishmentId, resultId);
        if (event == null ||
            event.syncStatus != HealthSyncStatus.synchronized ||
            event.deletedAt != null ||
            event.result != null) {
          return _SyncStep.completed;
        }
      }
      final response = await _remote.submit(operation.payload, guard, resultEventId: resultId);
      await guard();
      await _repository.accept(session, operation, response);
      return _SyncStep.completed;
    } on BackendRequestFailure catch (error) {
      if (_closed || _paused || _repository.session != session) return _SyncStep.failed;
      final healthFailure = error is HealthRemoteFailure ? error : null;
      final currentEvent = healthFailure?.currentEvent;
      if (error.status == 409 && currentEvent != null && operation.resultEventId == currentEvent.id) {
        await _repository.accept(session, operation, [currentEvent], resultConflict: true);
        return _SyncStep.completed;
      } else if (error.definitive) {
        await _repository.reject(
          session,
          operation,
          error.code ?? 'respuesta_animal_invalida',
          details: healthFailure?.rejection,
        );
        return _SyncStep.completed;
      }
      return _transient(error) ? _SyncStep.retryableFailure : _SyncStep.failed;
    } on Object catch (error) {
      if (_closed || _paused || _repository.session != session) return _SyncStep.failed;
      _logger.warning('Health submission interrupted (${error.runtimeType})');
      return _SyncStep.retryableFailure;
    }
  }

  Future<void> _pull(HealthSession session, String establishmentId, Future<void> Function() guard) async {
    var cursor = await _repository.cursor(establishmentId);
    while (true) {
      final page = await _remote.history(establishmentId, cursor, guard);
      if (page.hasMore && page.cursor == cursor) throw const FormatException('Health cursor did not advance');
      await guard();
      await _repository.reconcilePage(session, establishmentId, page.events, page.cursor);
      cursor = page.cursor;
      if (!page.hasMore) return;
    }
  }

  static bool _transient(BackendRequestFailure error) =>
      error.status == 408 || error.status == 425 || error.status == 429 || error.status >= 500;
}
