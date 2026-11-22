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
    required AnimalSelectionStore animals,
    required EstablishmentCatalog memberships,
    required HealthSession? Function() session,
    void Function()? onPending,
    DateTime Function()? now,
    String Function()? generateId,
  }) : _store = store,
       _animals = animals,
       _memberships = memberships,
       _session = session,
       _onPending = onPending,
       _now = now ?? DateTime.now,
       _generateId = generateId ?? generateUuidV4;

  final HealthBrickStore _store;
  final AnimalSelectionStore _animals;
  final EstablishmentCatalog _memberships;
  final HealthSession? Function() _session;
  final void Function()? _onPending;
  final DateTime Function() _now;
  final String Function() _generateId;
  static const _resultRejectionKey = 'local_result_rejection';

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

  static bool _isEligibleAnimal(BrickAnimalModel animal, HealthSession current) =>
      animal.deletedAt == null &&
      (animal.productiveStatus.toDomain().isInProductiveStock ||
          (animal.syncStatus == BrickAnimalSyncStatus.pending &&
              animal.localRegistrationAuthorId == current.userId &&
              animal.productiveStatus == BrickAnimalProductiveStatus.unknown)) &&
      (animal.syncStatus == BrickAnimalSyncStatus.synchronized ||
          animal.localRegistrationAuthorId == null ||
          animal.localRegistrationAuthorId == current.userId) &&
      animal.syncStatus != BrickAnimalSyncStatus.rejected;

  @override
  Future<List<HealthRecipient>> getRecipients(String establishmentId, List<String> animalIds) async {
    final current = await authorize(establishmentId);
    final ids = animalIds.toSet();
    final rows = await _animals.getLocalAnimalsByIds(establishmentId, ids);
    requireSession(current);
    final animals = {
      for (final animal in rows.where((animal) => _isEligibleAnimal(animal, current))) animal.localId: animal,
    };
    return [
      for (final id in ids)
        if (animals[id] case final animal?) _recipient(animal),
    ];
  }

  @override
  Future<HealthRecipient?> findRecipient(String establishmentId, String tag, {required bool electronic}) async {
    final current = await authorize(establishmentId);
    final code = tag.trim();
    if (electronic && !RfidValidator.isValid(code)) throw const HealthFailure(HealthProblem.invalidTag);
    if (code.isEmpty) return null;
    final rows = await _animals.findLocalAnimalsByTag(establishmentId, code, electronic: electronic);
    requireSession(current);
    final matches = rows.where((animal) => _isEligibleAnimal(animal, current)).toList();
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
        final events = await _store.serialize(() async {
          final rows = await _store.events(establishmentId, animalId: animalId);
          final drafts = await _resultDrafts(current, establishmentId);
          return [
            for (final event in rows.map(_decode))
              if (event.deletedAt == null &&
                  (event.syncStatus == HealthSyncStatus.synchronized || event.recordedById == current.userId))
                _withResultDraft(event, drafts[event.id]),
          ]..sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
        });
        requireSession(current);
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
      final previousEvents = previous == null ? <HealthEvent>[] : await _rejectedEvents(current, previous);
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
            id: previousByAnimal[animal.animalId]?.id ?? _generateId(),
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
          ),
      ];
      final operationId = _generateId();
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
  Future<HealthCorrection?> getRejectedRegistration(HealthEvent event) async {
    final current = await authorize(event.establishmentId);
    final operations = await _store.operations(current.userId, establishmentId: event.establishmentId);
    requireSession(current);
    for (final operation in operations) {
      if (operation.rejection == null || operation.resultEventId != null) continue;
      final ids = registrationEventIds(operation);
      if (!ids.contains(event.id)) continue;
      final rows = await _rejectedEvents(current, operation);
      requireSession(current);
      final rejected = rows.where((item) => item.id == event.id).firstOrNull;
      if (rejected == null) return null;
      return (
        id: operation.localId,
        rejection: rejected.syncRejection,
        registration: HealthRegistration(
          establishmentId: rejected.establishmentId,
          occurredAt: rejected.occurredAt,
          practice: rejected.practice,
          details: rejected.details,
          responsible: rejected.responsible,
          notes: rejected.notes,
          recipients: [for (final item in rows) item.recipient],
        ),
      );
    }
    return null;
  }

  Future<List<HealthEvent>> _rejectedEvents(HealthSession current, BrickHealthOperationModel operation) async {
    final establishmentId = operation.establishmentId;
    final ids = registrationEventIds(operation);
    final drafts = await _resultDrafts(current, establishmentId);
    final rows = {
      for (final row in await _store.eventsByIds(establishmentId, ids)) row.localId: _decode(row),
    };
    return [
      for (final id in ids)
        if (rows[id] case final event? when event.syncStatus == HealthSyncStatus.rejected && event.deletedAt == null)
          _withResultDraft(event, drafts[id]),
    ];
  }

  Future<Map<String, BrickHealthOperationModel>> _resultDrafts(HealthSession current, String establishmentId) async => {
    for (final operation in await _store.operations(current.userId, establishmentId: establishmentId))
      if (operation.resultEventId case final id?) id: operation,
  };

  static HealthEvent _withResultDraft(HealthEvent event, BrickHealthOperationModel? draft) {
    final canonical = _withoutLegacyResult(event);
    if (draft == null || canonical.result != null || canonical.deletedAt != null) return canonical;
    final payload = HealthCodec.object(draft.payload);
    final legacyDetails = event.result?.reportedById == draft.authorId ? event.resultRejection : null;
    return canonical.copyWith(
      result: HealthStudyResult(
        value: payload['resultado'] as String,
        reportedAt: DateTime.parse(payload['fecha'] as String),
        reportedById: draft.authorId,
      ),
      resultSyncStatus: draft.rejection == null ? HealthSyncStatus.pending : HealthSyncStatus.rejected,
      resultIssue: HealthCodec.issueFrom(draft.rejection),
      resultRejection: draft.rejection == null
          ? null
          : payload.containsKey(_resultRejectionKey)
          ? HealthCodec.rejectionFrom(payload[_resultRejectionKey])
          : legacyDetails,
    );
  }

  static HealthEvent _withoutLegacyResult(HealthEvent event) => event.resultSyncStatus == null
      ? event
      : event.copyWith(result: null, resultSyncStatus: null, resultIssue: null, resultRejection: null);

  /// UUID de los eventos afectados, en el orden del registro persistido.
  static Set<String> registrationEventIds(BrickHealthOperationModel operation) =>
      (HealthCodec.object(operation.payload)['animales'] as List)
          .cast<Map<String, dynamic>>()
          .map((entry) => entry['id'] as String)
          .toSet();

  @override
  Future<void> recordResult(HealthEvent event, String result, DateTime reportedAt) async {
    final current = await authorize(event.establishmentId);
    await _store.serialize(() async {
      final row = await _store.event(event.establishmentId, event.id);
      final latest = row == null || row.animalId != event.recipient.animalId ? null : _decode(row);
      if (latest == null ||
          latest.deletedAt != null ||
          latest.practice.kind != HealthPracticeKind.sampling ||
          (latest.syncStatus != HealthSyncStatus.synchronized && latest.recordedById != current.userId)) {
        throw const HealthFailure(HealthProblem.invalidResult);
      }
      final previous = (await _resultDrafts(current, event.establishmentId))[event.id];
      if (_withoutLegacyResult(latest).result != null || (previous != null && previous.rejection == null)) {
        throw const HealthFailure(HealthProblem.invalidResult);
      }
      final id = _generateId();
      final timestamp = _now().toUtc();
      await _store.save(
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

  /// Operaciones reintentables. Un resultado con alta rechazada espera la corrección del alta.
  Future<List<BrickHealthOperationModel>> pendingOperations() => _store.serialize(() async {
    final current = session;
    final pending = (await visibleOperations()).where((item) => item.rejection == null).toList();
    final resultIds = <String, Set<String>>{};
    for (final item in pending) {
      if (item.resultEventId case final id?) (resultIds[item.establishmentId] ??= {}).add(id);
    }
    final available = {
      for (final parent in (await _store.resultParents(resultIds)).map(_decode).map(_withoutLegacyResult))
        if (parent.deletedAt == null && parent.syncStatus != HealthSyncStatus.rejected && parent.result == null)
          (parent.establishmentId, parent.id),
    };
    if (session != current) return const [];
    return [
      for (final item in pending)
        if (item.resultEventId == null || available.contains((item.establishmentId, item.resultEventId))) item,
    ];
  });

  /// Observa transacciones confirmadas de Sanidad.
  Stream<void> get changes => _store.changes;

  /// Lee el evento local sin proyectar borradores privados para resolver dependencias del envío.
  Future<HealthEvent?> localEvent(String establishmentId, String eventId) async {
    final row = await _store.event(establishmentId, eventId);
    return row == null ? null : _withoutLegacyResult(_decode(row));
  }

  /// Aplica una página descargada y su cursor en una sola transacción.
  Future<void> reconcilePage(
    HealthSession current,
    String establishmentId,
    List<HealthEvent> incoming,
    String cursor,
  ) => _store.serialize(() async {
    if (incoming.any((event) => event.establishmentId != establishmentId)) {
      throw const FormatException('Health history belongs to a different establishment');
    }
    final cache = await _store.catalog(establishmentId);
    final ids = incoming.map((event) => event.id).toSet();
    final local = {for (final row in await _store.eventsByIds(establishmentId, ids)) row.localId: _decode(row)};
    final updatedEvents = <BrickHealthEventModel>[];
    final resolvedResults = <String>{};
    for (final remote in incoming) {
      final previous = local[remote.id];
      if (!_shouldApply(remote, previous)) continue;
      final merged = _applyRemote(remote, previous);
      if (merged.resultSyncStatus == null && (merged.result != null || merged.deletedAt != null)) {
        resolvedResults.add(remote.id);
      }
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
    if (local.recipient.animalId != remote.recipient.animalId) {
      throw const FormatException('Health event changed its animal');
    }
    // Un evento confirmado en historial puede llegar antes del ACK de su alta.
    if (local.syncStatus != HealthSyncStatus.synchronized) return true;
    if (local.deletedAt != null && remote.deletedAt == null && !remote.updatedAt.isAfter(local.updatedAt)) {
      return false;
    }
    if (local.resultSyncStatus == null && local.result != null && remote.result == null && remote.deletedAt == null) {
      return false;
    }
    return !remote.updatedAt.isBefore(local.updatedAt);
  }

  static HealthEvent _applyRemote(HealthEvent remote, HealthEvent? previous) {
    if (previous?.resultSyncStatus == null) return remote.copyWith(resultIssue: previous?.resultIssue);
    if (remote.result != null || remote.deletedAt != null) return remote;
    return remote.copyWith(
      result: previous?.result,
      resultSyncStatus: previous?.resultSyncStatus,
      resultIssue: previous?.resultIssue,
      resultRejection: previous?.resultRejection,
    );
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
      for (final row in await _store.eventsByIds(operation.establishmentId, expected)) row.localId: _decode(row),
    };
    final rows = <BrickHealthEventModel>[];
    final finished = <String>{};
    for (final accepted in remote) {
      final local = previous[accepted.id];
      final reconciled = _shouldApply(accepted, local) ? _applyRemote(accepted, local) : local!;
      if (reconciled.resultSyncStatus == null && (reconciled.result != null || reconciled.deletedAt != null)) {
        finished.add(reconciled.id);
      }
      rows.add(
        HealthCodec.eventRow(
          resultConflict && reconciled.deletedAt == null
              ? reconciled.copyWith(resultIssue: HealthSyncIssue.resultAlreadyRecorded)
              : reconciled,
        ),
      );
    }
    await _store.save(
      events: rows,
      removing: {
        operation.localId: operation,
        for (final draft in await _store.resultOperations(operation.establishmentId, finished)) draft.localId: draft,
      }.values,
      requireSession: () => requireSession(current),
    );
  });

  /// Conserva un rechazo funcional para que su autor pueda corregirlo.
  Future<void> reject(
    HealthSession current,
    BrickHealthOperationModel operation,
    String reason, {
    HealthRejectionDetails? details,
  }) => _store.serialize(() async {
    final resultTarget = operation.resultEventId;
    final ids = resultTarget == null ? registrationEventIds(operation) : const <String>{};
    final events = await _store.eventsByIds(operation.establishmentId, ids);
    await _store.save(
      events: [
        for (final event in events.map(_decode))
          if (event.syncStatus != HealthSyncStatus.synchronized)
            HealthCodec.eventRow(
              event.copyWith(
                syncStatus: HealthSyncStatus.rejected,
                syncIssue: HealthCodec.issueFrom(reason),
                syncRejection: details,
              ),
            ),
      ],
      operations: [
        BrickHealthOperationModel(
          localId: operation.localId,
          establishmentId: operation.establishmentId,
          authorId: operation.authorId,
          createdAt: operation.createdAt,
          payload: resultTarget == null
              ? operation.payload
              : jsonEncode({
                  ...HealthCodec.object(operation.payload),
                  _resultRejectionKey: HealthCodec.rejectionTo(details),
                }),
          resultEventId: resultTarget,
          rejection: reason,
        ),
      ],
      requireSession: () => requireSession(current),
    );
  });
}
