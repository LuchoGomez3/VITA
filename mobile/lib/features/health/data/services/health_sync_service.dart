import 'dart:async';

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/health_operation.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/features/health/data/datasources/health_remote_data_source.dart';
import 'package:frontend_mayoral/features/health/data/mappers/health_codec.dart';
import 'package:frontend_mayoral/features/health/data/repositories/health_repository_impl.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
import 'package:logging/logging.dart';

/// Disponibilidad del animal que debe existir antes del evento sanitario.
enum HealthAnimalDependency {
  /// El servidor ya conoce al animal.
  confirmed,

  /// El alta todavía puede llegar al servidor.
  waiting,

  /// El alta requiere que el usuario la revise.
  rejected,
}

/// Resuelve una dependencia de Sanidad bajo la sesión del envío.
typedef ResolveHealthAnimal =
    Future<HealthAnimalDependency> Function(
      String animalId,
      String establishmentId,
      HealthSession session,
      Future<void> Function() guard,
    );

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
  Future<void>? _active;
  Timer? _retry;
  bool _requested = false;
  bool _refresh = false;
  bool _closed = false;
  bool _paused = false;

  /// Pide un ciclo posterior si hay otro procesando una instantánea previa.
  Future<void> request({bool refresh = false}) {
    if (_closed || _repository.session == null) return Future.value();
    _paused = false;
    _requested = true;
    _refresh = _refresh || refresh;
    _retry?.cancel();
    return _active ??= _run().whenComplete(() => _active = null);
  }

  /// Cancela solicitudes programadas que pertenecían a la sesión anterior.
  void pause() {
    _paused = true;
    _requested = false;
    _refresh = false;
    _retry?.cancel();
  }

  /// Libera los reintentos al cerrar la app.
  void dispose() {
    _closed = true;
    pause();
  }

  Future<void> _run() async {
    while (_requested) {
      final refresh = _refresh;
      _requested = false;
      _refresh = false;
      final current = _repository.session;
      if (current == null || _closed) return;
      final shouldRetry = await _cycle(current, refresh: refresh);
      if (shouldRetry && !_requested && !_paused && !_closed && _repository.session == current) {
        _retry = Timer(const Duration(seconds: 30), () {
          if (_repository.session == current) unawaited(request(refresh: refresh));
        });
      }
    }
  }

  Future<bool> _cycle(HealthSession session, {required bool refresh}) async {
    try {
      final establishments = await _repository.establishments();
      final operations = await _repository.pendingOperations();
      var retry = false;
      for (final establishment in establishments) {
        final id = establishment.id;
        final pending = operations.where((operation) => operation.establishmentId == id).toList();
        if (!refresh && pending.isEmpty) continue;
        Future<void> guard() async {
          _repository.requireSession(session);
          final authorized = await _repository.authorize(id);
          if (_closed || _paused || authorized != session) {
            throw const HealthFailure(HealthProblem.unauthorized);
          }
        }

        for (final operation in [
          ...pending.where((item) => item.resultEventId == null),
          ...pending.where((item) => item.resultEventId != null),
        ]) {
          final completed = await _attempt(session, operation, guard);
          retry = !completed || retry;
        }
        if (refresh) {
          retry =
              await _refreshResource(session, 'catalog', () async {
                final catalog = await _remote.catalog(id, guard);
                await _repository.cacheCatalog(session, catalog);
              }) ||
              retry;
          retry = await _refreshResource(session, 'history', () => _pull(session, id, guard)) || retry;
        }
      }
      return retry;
    } on Object catch (error) {
      if (_repository.session != session) return false;
      _logger.warning('Health synchronization interrupted (${error.runtimeType})');
      return true;
    }
  }

  Future<bool> _refreshResource(HealthSession session, String resource, Future<void> Function() refresh) async {
    if (_closed || _paused || _repository.session != session) return false;
    try {
      await refresh();
      return false;
    } on HealthRemoteFailure catch (error) {
      if (error.status != 404) _logger.warning('Health $resource refresh returned HTTP ${error.status}');
      return _transient(error);
    } on Object catch (error) {
      if (_closed || _paused || _repository.session != session) return false;
      _logger.warning('Health $resource refresh interrupted (${error.runtimeType})');
      return true;
    }
  }

  Future<bool> _attempt(
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
          if (availability != HealthAnimalDependency.confirmed) {
            if (availability == HealthAnimalDependency.rejected) {
              await _repository.reject(
                session,
                operation,
                'alta_animal_rechazada',
                details: (animalId: animalId, field: null),
              );
            }
            return availability == HealthAnimalDependency.rejected;
          }
        }
      } else {
        final event = await _repository.localEvent(operation.establishmentId, resultId);
        if (event == null ||
            event.syncStatus != HealthSyncStatus.synchronized ||
            event.deletedAt != null ||
            event.result != null) {
          return true;
        }
      }
      final response = await _remote.submit(operation, guard);
      await guard();
      await _repository.accept(session, operation, response);
      return true;
    } on HealthRemoteFailure catch (error) {
      if (_paused || _repository.session != session) return true;
      final currentEvent = error.currentEvent;
      if (error.status == 409 && currentEvent != null && operation.resultEventId == currentEvent.id) {
        await _repository.accept(session, operation, [currentEvent], resultConflict: true);
      } else if (error.definitive) {
        await _repository.reject(session, operation, error.code, details: error.rejection);
      }
      return !_transient(error);
    } on Object catch (error) {
      if (_repository.session != session) return true;
      _logger.warning('Health submission interrupted (${error.runtimeType})');
      return false;
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

  static bool _transient(HealthRemoteFailure error) =>
      error.status == 408 || error.status == 425 || error.status == 429 || error.status >= 500;
}

/// Reutiliza el flujo de alta de animales para dependencias offline.
class HealthAnimalRegistrationRecovery {
  /// Inyecta el store de animales y el transporte sanitario protegido.
  const HealthAnimalRegistrationRecovery(this._animals, this._remote, this._repository);

  final BrickAnimalStore _animals;
  final HealthRemoteDataSource _remote;
  final HealthRepositoryImpl _repository;

  /// Confirma que el servidor conoce al animal o recupera su alta local.
  Future<HealthAnimalDependency> call(
    String id,
    String establishmentId,
    HealthSession session,
    Future<void> Function() guard,
  ) async {
    final animal = await _animals.getAnimalById(id);
    if (animal != null && animal.establishmentId != establishmentId) return HealthAnimalDependency.rejected;
    if (animal?.syncStatus == BrickAnimalSyncStatus.synchronized) return HealthAnimalDependency.confirmed;
    if (await _remote.hasAnimal(id, establishmentId, guard)) return HealthAnimalDependency.confirmed;
    if (animal == null || animal.syncStatus == BrickAnimalSyncStatus.rejected) {
      return HealthAnimalDependency.rejected;
    }
    final body = await _animals.recoverableRegistrationBody(animal, session.userId);
    if (body == null) return HealthAnimalDependency.waiting;
    String? errorCode;
    try {
      final data = await _remote.recoverAnimal(body, guard);
      if (data['id'] != id || data['establecimiento_id'] != establishmentId) {
        throw const FormatException('Animal response did not match health dependency');
      }
    } on HealthRemoteFailure catch (error) {
      if (!error.definitive) rethrow;
      if (!await _remote.hasAnimal(id, establishmentId, guard)) errorCode = error.code;
    }
    await guard();
    await _animals.reconcileRecoveredRegistration(
      animal,
      errorCode: errorCode,
      requireSession: () => _repository.requireSession(session),
    );
    return errorCode == null ? HealthAnimalDependency.confirmed : HealthAnimalDependency.rejected;
  }
}
