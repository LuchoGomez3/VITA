import 'dart:async';
import 'dart:convert';

import 'package:frontend_mayoral/brick/mappers/animal_productive_status_mapper.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/health_catalog.model.dart';
import 'package:frontend_mayoral/brick/models/health_event.model.dart';
import 'package:frontend_mayoral/brick/models/health_operation.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/health_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/core/validators/rfid_validator.dart';
import 'package:frontend_mayoral/features/health/data/mappers/health_codec.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/repositories/health_repository.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';

/// Identidad que se conserva durante una lectura, envío o transacción.
typedef HealthSession = ({String userId, int generation});

/// Sanidad lee y escribe primero en la base local.
class HealthRepositoryImpl implements HealthRepository {
  /// Inyecta la cuenta y las fuentes locales que necesita Sanidad.
  HealthRepositoryImpl({
    required HealthBrickStore store,
    required AnimalBrickStore animals,
    required EstablishmentCatalog memberships,
    required HealthSession? Function() session,
    void Function()? onPending,
    DateTime Function()? now,
  }) : _store = store,
       _animals = animals,
       _memberships = memberships,
       _session = session,
       _onPending = onPending,
       _now = now ?? DateTime.now;

  final HealthBrickStore _store;
  final AnimalBrickStore _animals;
  final EstablishmentCatalog _memberships;
  final HealthSession? Function() _session;
  final void Function()? _onPending;
  final DateTime Function() _now;

  /// Identidad de la sesión abierta, si la hay.
  HealthSession? get session => _session();

  /// Garantiza que una lectura o respuesta siga perteneciendo a la misma cuenta.
  void requireSession(HealthSession expected) {
    if (_session() != expected) throw const HealthFailure(HealthProblem.unauthorized);
  }

  /// Lee establecimientos que pueden consultar y registrar Sanidad.
  Future<List<EstablishmentMembership>> establishments() async {
    final current = _session();
    if (current == null) return const [];
    final memberships = await _memberships.getMemberships();
    requireSession(current);
    return memberships.where((value) => value.role != UserRole.unknown).toList();
  }

  /// Comprueba la membresía offline y vuelve a validar la identidad.
  Future<HealthSession> authorize(String establishmentId) async {
    final current = _session();
    if (current == null) throw const HealthFailure(HealthProblem.unauthorized);
    final membership = await _memberships.getById(establishmentId);
    requireSession(current);
    if (membership == null || membership.role == UserRole.unknown) {
      throw const HealthFailure(HealthProblem.unauthorized);
    }
    return current;
  }

  @override
  Future<HealthCatalog?> getCatalog(String establishmentId) async {
    final current = await authorize(establishmentId);
    final payload = (await _store.catalog(establishmentId))?.payload;
    requireSession(current);
    return payload == null ? null : HealthCodec.catalogFrom(HealthCodec.object(payload), establishmentId);
  }

  /// Aplica el catálogo descargado sin perder el avance del historial.
  Future<void> cacheCatalog(HealthSession current, HealthCatalog catalog) => _store.serialize(() async {
    final previous = await _store.catalog(catalog.establishmentId);
    await _store.save(
      catalog: BrickHealthCatalogModel(
        establishmentId: catalog.establishmentId,
        payload: jsonEncode(HealthCodec.catalogTo(catalog)),
        cursor: previous?.cursor,
      ),
      requireSession: () => requireSession(current),
    );
  });

  Future<List<BrickAnimalModel>> _eligibleAnimals(String establishmentId, HealthSession current) async {
    final animals = await _animals.getLocalAnimals();
    requireSession(current);
    return animals
        .where(
          (animal) =>
              animal.establishmentId == establishmentId &&
              animal.deletedAt == null &&
              (animal.productiveStatus.toDomain().isInProductiveStock ||
                  (animal.syncStatus == BrickAnimalSyncStatus.pending &&
                      animal.localRegistrationAuthorId == current.userId &&
                      animal.productiveStatus == BrickAnimalProductiveStatus.unknown)) &&
              (animal.syncStatus == BrickAnimalSyncStatus.synchronized ||
                  animal.localRegistrationAuthorId == null ||
                  animal.localRegistrationAuthorId == current.userId) &&
              animal.syncStatus != BrickAnimalSyncStatus.rejected,
        )
        .toList();
  }

  @override
  Future<List<HealthRecipient>> getRecipients(String establishmentId, List<String> animalIds) async {
    final current = await authorize(establishmentId);
    final animals = {for (final animal in await _eligibleAnimals(establishmentId, current)) animal.localId: animal};
    return [
      for (final id in animalIds.toSet())
        if (animals[id] case final animal?) _recipient(animal),
    ];
  }

  @override
  Future<HealthRecipient?> findRecipient(String establishmentId, String tag, {required bool electronic}) async {
    final current = await authorize(establishmentId);
    final code = tag.trim();
    if (electronic && !RfidValidator.isValid(code)) throw const HealthFailure(HealthProblem.invalidTag);
    if (code.isEmpty) return null;
    final matches = (await _eligibleAnimals(establishmentId, current))
        .where(
          (animal) =>
              electronic ? animal.rfidTagNumber == code : animal.visualTag.trim().toUpperCase() == code.toUpperCase(),
        )
        .toList();
    if (matches.length > 1) throw const HealthFailure(HealthProblem.ambiguousTag);
    return matches.isEmpty ? null : _recipient(matches.single);
  }

  static HealthRecipient _recipient(BrickAnimalModel animal) => HealthRecipient(
    animalId: animal.localId,
    label: animal.visualTag.isEmpty ? animal.rfidTagNumber : animal.visualTag,
    lotId: animal.lotId.isEmpty ? null : animal.lotId,
  );

  @override
  Stream<List<HealthEvent>> watchHistory(String establishmentId, String animalId) async* {
    final current = await authorize(establishmentId);
    final ticks = StreamController<void>()..add(null);
    final subscription = _store.changes.listen(ticks.add);
    try {
      await for (final _ in ticks.stream) {
        await authorize(establishmentId);
        final rows = await _store.events(establishmentId, animalId: animalId);
        requireSession(current);
        final events =
            rows
                .map(_decode)
                .where(
                  (event) =>
                      event.deletedAt == null &&
                      (event.syncStatus == HealthSyncStatus.synchronized || event.recordedById == current.userId),
                )
                .map((event) {
                  final result = event.result;
                  if (event.resultSyncStatus == null || result?.reportedById == current.userId) return event;
                  return event.copyWith(result: null, resultSyncStatus: null, resultErrorCode: null);
                })
                .toList()
              ..sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
        yield events;
      }
    } finally {
      await subscription.cancel();
      unawaited(ticks.close());
    }
  }

  @override
  Future<void> register(HealthRegistration registration, {String? replacingOperationId}) async {
    final establishmentId = registration.establishmentId;
    final current = await authorize(establishmentId);
    await _store.serialize(() async {
      final selected = await getRecipients(establishmentId, [
        for (final entry in registration.recipients) entry.animalId,
      ]);
      if (selected.length != registration.recipients.length) throw const HealthFailure(HealthProblem.unavailableAnimal);

      final selection = {for (final entry in registration.recipients) entry.animalId: entry};
      final previous = replacingOperationId == null
          ? null
          : (await _store.operations(current.userId, establishmentId: establishmentId))
                .where(
                  (row) => row.localId == replacingOperationId && row.rejection != null && row.resultEventId == null,
                )
                .firstOrNull;
      if (replacingOperationId != null && previous == null) {
        throw const HealthFailure(HealthProblem.invalidSelection);
      }
      final previousEvents = previous == null ? <HealthEvent>[] : await _rejectedEvents(establishmentId, previous);
      if (previousEvents.any(
        (event) =>
            event.result != null &&
            selection.containsKey(event.recipient.animalId) &&
            registration.practice.kind != HealthPracticeKind.sampling,
      )) {
        throw const HealthFailure(HealthProblem.invalidResult);
      }
      final previousByAnimal = {for (final event in previousEvents) event.recipient.animalId: event};
      final participants = [
        for (final animal in selected) animal.copyWith(sampleReference: selection[animal.animalId]?.sampleReference),
      ];
      final timestamp = _now().toUtc();
      final events = [
        for (final animal in participants)
          HealthEvent(
            id: previousByAnimal[animal.animalId]?.id ?? generateUuidV4(),
            establishmentId: establishmentId,
            occurredAt: registration.occurredAt,
            createdAt: previousByAnimal[animal.animalId]?.createdAt ?? timestamp,
            updatedAt: timestamp,
            practice: registration.practice,
            details: registration.details,
            responsible: registration.responsible.trim(),
            recordedById: current.userId,
            recipient: animal,
            notes: registration.notes,
            result: previousByAnimal[animal.animalId]?.result,
            resultSyncStatus: previousByAnimal[animal.animalId]?.resultSyncStatus,
            resultErrorCode: previousByAnimal[animal.animalId]?.resultErrorCode,
          ),
      ];
      final operationId = generateUuidV4();
      final body = jsonEncode({
        'id': operationId,
        'establecimiento_id': establishmentId,
        'practica_id': registration.practice.id,
        'fecha_aplicacion': registration.occurredAt.toUtc().toIso8601String(),
        'responsable': registration.responsible.trim(),
        'observaciones': registration.notes,
        'datos': HealthCodec.detailsTo(registration.details),
        'animales': [
          for (final event in events)
            {
              ...HealthCodec.recipientTo(event.recipient),
              'id': event.id,
              'created_at': event.createdAt.toIso8601String(),
              'updated_at': event.updatedAt.toIso8601String(),
            },
        ],
      });
      final unselected = previousEvents.where((event) => !selection.containsKey(event.recipient.animalId));
      final retained = previous == null ? null : _retainUnselectedResults(previous, unselected);
      await _store.save(
        events: [
          ...events.map(HealthCodec.eventRow),
          for (final event in unselected)
            if (event.result == null) HealthCodec.eventRow(event.copyWith(deletedAt: timestamp, updatedAt: timestamp)),
        ],
        operations: [
          BrickHealthOperationModel(
            localId: operationId,
            establishmentId: establishmentId,
            authorId: current.userId,
            createdAt: timestamp,
            payload: body,
          ),
          if (retained != null) retained,
        ],
        removing: [if (previous != null && retained == null) previous],
        requireSession: () => requireSession(current),
      );
    });
    _onPending?.call();
  }

  static BrickHealthOperationModel? _retainUnselectedResults(
    BrickHealthOperationModel previous,
    Iterable<HealthEvent> unselected,
  ) {
    final retained = {
      for (final event in unselected)
        if (event.result != null) event.id,
    };
    if (retained.isEmpty) return null;
    final payload = HealthCodec.object(previous.payload);
    final entries = (payload['animales'] as List).cast<Map<String, dynamic>>();
    return BrickHealthOperationModel(
      localId: previous.localId,
      establishmentId: previous.establishmentId,
      authorId: previous.authorId,
      createdAt: previous.createdAt,
      payload: jsonEncode({...payload, 'animales': entries.where((entry) => retained.contains(entry['id'])).toList()}),
      rejection: previous.rejection,
    );
  }

  @override
  Future<({String id, HealthRegistration registration})?> getRejectedRegistration(HealthEvent event) async {
    final current = await authorize(event.establishmentId);
    final operations = await _store.operations(current.userId, establishmentId: event.establishmentId);
    requireSession(current);
    for (final operation in operations) {
      if (operation.rejection == null || operation.resultEventId != null) continue;
      final ids = registrationEventIds(operation);
      if (!ids.contains(event.id)) continue;
      final rows = await _rejectedEvents(event.establishmentId, operation);
      requireSession(current);
      return (
        id: operation.localId,
        registration: HealthRegistration(
          establishmentId: event.establishmentId,
          occurredAt: event.occurredAt,
          practice: event.practice,
          details: event.details,
          responsible: event.responsible,
          notes: event.notes,
          recipients: [for (final item in rows) item.recipient],
        ),
      );
    }
    return null;
  }

  Future<List<HealthEvent>> _rejectedEvents(String establishmentId, BrickHealthOperationModel operation) async {
    final ids = registrationEventIds(operation);
    return (await _store.events(establishmentId))
        .where((row) => ids.contains(row.localId))
        .map(_decode)
        .where((event) => event.syncStatus == HealthSyncStatus.rejected && event.deletedAt == null)
        .toList();
  }

  /// UUID de los eventos afectados por el registro persistido.
  static Set<String> registrationEventIds(BrickHealthOperationModel operation) =>
      (HealthCodec.object(operation.payload)['animales'] as List)
          .cast<Map<String, dynamic>>()
          .map((entry) => entry['id'] as String)
          .toSet();

  @override
  Future<void> recordResult(HealthEvent event, String result, DateTime reportedAt) async {
    final current = await authorize(event.establishmentId);
    await _store.serialize(() async {
      final latest = (await _store.events(
        event.establishmentId,
        animalId: event.recipient.animalId,
      )).where((row) => row.localId == event.id).map(_decode).firstOrNull;
      if (latest == null ||
          latest.deletedAt != null ||
          latest.practice.kind != HealthPracticeKind.sampling ||
          (latest.syncStatus != HealthSyncStatus.synchronized && latest.recordedById != current.userId)) {
        throw const HealthFailure(HealthProblem.invalidResult);
      }
      final previous = (await _store.operations(
        current.userId,
        establishmentId: event.establishmentId,
      )).where((row) => row.resultEventId == event.id && row.rejection != null).firstOrNull;
      if (latest.result != null && (latest.resultSyncStatus != HealthSyncStatus.rejected || previous == null)) {
        throw const HealthFailure(HealthProblem.invalidResult);
      }
      final id = generateUuidV4();
      final timestamp = _now().toUtc();
      await _store.save(
        events: [
          HealthCodec.eventRow(
            latest.copyWith(
              result: HealthStudyResult(value: result, reportedAt: reportedAt, reportedById: current.userId),
              resultSyncStatus: HealthSyncStatus.pending,
              resultErrorCode: null,
            ),
          ),
        ],
        operations: [
          BrickHealthOperationModel(
            localId: id,
            establishmentId: event.establishmentId,
            authorId: current.userId,
            createdAt: timestamp,
            resultEventId: event.id,
            payload: jsonEncode({'id': id, 'resultado': result, 'fecha': reportedAt.toUtc().toIso8601String()}),
          ),
        ],
        removing: [if (previous != null) previous],
        requireSession: () => requireSession(current),
      );
    });
    _onPending?.call();
  }

  static HealthEvent _decode(BrickHealthEventModel row) => HealthCodec.eventFrom(HealthCodec.object(row.payload));

  /// Devuelve el cursor aplicado a la base local.
  Future<String?> cursor(String establishmentId) async => (await _store.catalog(establishmentId))?.cursor;

  /// Operaciones propias de la sesión y de sus establecimientos autorizados.
  Future<List<BrickHealthOperationModel>> visibleOperations() async {
    final current = session;
    if (current == null) return const [];
    final allowed = (await establishments()).map((item) => item.id).toSet();
    final operations = await _store.operations(current.userId);
    if (session != current) return const [];
    return operations.where((item) => allowed.contains(item.establishmentId)).toList();
  }

  /// Observa transacciones confirmadas de Sanidad.
  Stream<void> get changes => _store.changes;

  /// Lee la proyección local para resolver dependencias del envío.
  Future<HealthEvent?> localEvent(String establishmentId, String eventId) async =>
      (await _store.events(establishmentId)).where((item) => item.localId == eventId).map(_decode).firstOrNull;

  /// Aplica una página descargada y su cursor en una sola transacción.
  Future<void> reconcilePage(
    HealthSession current,
    String establishmentId,
    List<HealthEvent> incoming,
    String cursor,
  ) => _store.serialize(() async {
    final cache = await _store.catalog(establishmentId);
    final local = {for (final row in await _store.events(establishmentId)) row.localId: _decode(row)};
    if (incoming.any((event) => event.establishmentId != establishmentId)) {
      throw const FormatException('Health history belongs to a different establishment');
    }
    final updatedEvents = <BrickHealthEventModel>[];
    final resolvedResults = <String>{};
    for (final remote in incoming) {
      final previous = local[remote.id];
      if (!_shouldApply(remote, previous)) continue;
      final isFinal = remote.result != null || remote.deletedAt != null;
      final hasLocalResult = previous?.resultSyncStatus != null;
      if (isFinal && hasLocalResult) resolvedResults.add(remote.id);
      final merged = hasLocalResult && !isFinal
          ? remote.copyWith(
              result: previous?.result,
              resultSyncStatus: previous?.resultSyncStatus,
              resultErrorCode: previous?.resultErrorCode,
            )
          : remote.copyWith(resultErrorCode: hasLocalResult ? null : previous?.resultErrorCode);
      local[remote.id] = merged;
      updatedEvents.add(HealthCodec.eventRow(merged));
    }
    await _store.save(
      events: updatedEvents,
      removing: await _store.resultOperations(establishmentId, resolvedResults),
      catalog: BrickHealthCatalogModel(establishmentId: establishmentId, payload: cache?.payload, cursor: cursor),
      requireSession: () => requireSession(current),
    );
  });

  static bool _shouldApply(HealthEvent remote, HealthEvent? local) {
    if (local == null) return true;
    if (local.syncStatus != HealthSyncStatus.synchronized) return false;
    if (local.resultSyncStatus == null && local.result != null && remote.result == null && remote.deletedAt == null) {
      return false;
    }
    return !remote.updatedAt.isBefore(local.updatedAt);
  }

  /// Reconcilia una aceptación o el resultado que ganó una carrera.
  Future<void> accept(
    HealthSession current,
    BrickHealthOperationModel operation,
    List<HealthEvent> remote, {
    bool resultConflict = false,
  }) => _store.serialize(() async {
    final resultTarget = operation.resultEventId;
    final expected = resultTarget == null ? registrationEventIds(operation) : {resultTarget};
    final ids = remote.map((item) => item.id).toSet();
    if (expected.length != ids.length ||
        !expected.containsAll(ids) ||
        ids.length != remote.length ||
        remote.any((event) => event.establishmentId != operation.establishmentId) ||
        (resultTarget != null && remote.single.result == null)) {
      throw const FormatException('Health response did not acknowledge the requested events');
    }
    final previous = {
      for (final row in await _store.events(operation.establishmentId))
        if (expected.contains(row.localId)) row.localId: _decode(row),
    };
    final rows = remote.map((accepted) {
      final previousEvent = previous[accepted.id];
      if (resultTarget == null && previousEvent?.resultSyncStatus != null) {
        return HealthCodec.eventRow(
          accepted.copyWith(
            result: previousEvent?.result,
            resultSyncStatus: previousEvent?.resultSyncStatus,
            resultErrorCode: previousEvent?.resultErrorCode,
          ),
        );
      }
      return HealthCodec.eventRow(
        accepted.copyWith(resultErrorCode: resultConflict ? 'resultado_ya_completado' : null),
      );
    });
    await _store.save(events: rows, removing: [operation], requireSession: () => requireSession(current));
  });

  /// Conserva un rechazo funcional para que su autor pueda corregirlo.
  Future<void> reject(
    HealthSession current,
    BrickHealthOperationModel operation,
    String reason,
  ) => _store.serialize(() async {
    final resultTarget = operation.resultEventId;
    final ids = resultTarget == null ? registrationEventIds(operation) : {resultTarget};
    final events = (await _store.events(
      operation.establishmentId,
    )).where((row) => ids.contains(row.localId)).map(_decode);
    await _store.save(
      events: events.map(
        (event) => HealthCodec.eventRow(
          resultTarget != null
              ? event.copyWith(resultSyncStatus: HealthSyncStatus.rejected, resultErrorCode: reason)
              : event.copyWith(syncStatus: HealthSyncStatus.rejected, syncErrorCode: reason),
        ),
      ),
      operations: [
        BrickHealthOperationModel(
          localId: operation.localId,
          establishmentId: operation.establishmentId,
          authorId: operation.authorId,
          createdAt: operation.createdAt,
          payload: operation.payload,
          resultEventId: resultTarget,
          rejection: reason,
        ),
      ],
      requireSession: () => requireSession(current),
    );
  });
}
