import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/authenticated_backend_client.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/auth/guarded_backend_request.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/health_event.model.dart';
import 'package:frontend_mayoral/brick/models/health_operation.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_registration_recovery.dart';
import 'package:frontend_mayoral/brick/stores/health_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/health/data/datasources/health_remote_data_source.dart';
import 'package:frontend_mayoral/features/health/data/mappers/health_codec.dart';
import 'package:frontend_mayoral/features/health/data/repositories/health_repository_impl.dart';
import 'package:frontend_mayoral/features/health/data/services/health_sync_service.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  const farm = 'health-farm';
  const author = (userId: 'author', generation: 1);
  const other = (userId: 'other', generation: 2);
  const sampling = HealthPractice(id: 'study', name: 'Sangrado', kind: HealthPracticeKind.sampling);
  final date = DateTime.utc(2026, 10, 15);
  late Directory directory;
  late String sqlitePath;
  late String queuePath;
  late HealthBrickStore store;
  late HealthRepositoryImpl repository;
  late HealthSession current;
  var nextId = 0xffffffff;

  // UUID con orden inverso al de alta para probar la corrección sin azar.
  String generateId() => '${(nextId--).toRadixString(16)}-0000-4000-8000-000000000000';

  setUpAll(() async {
    sqfliteFfiInit();
    directory = await Directory.systemTemp.createTemp('vita_health_test_');
    sqlitePath = path.join(directory.path, 'brick.sqlite');
    queuePath = path.join(directory.path, 'queue.sqlite');
    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: queuePath,
      backendBaseUrl: 'http://localhost',
      localDatabaseFactory: databaseFactoryFfi,
    );
    final brick = AppBrickRepository.instance;
    BrickAnimalStore.configure(brick);
    final animals = BrickAnimalStore.instance;
    for (final id in ['animal-1', 'animal-2', 'animal-3', 'animal-4']) {
      await animals.cacheAnimal(
        _animal(
          id: id,
          rfid: id.split('-').last.padLeft(15, '0'),
          visual: id,
          farm: farm,
          date: date,
          owner: author.userId,
        ),
      );
    }
    final catalog = EstablishmentCatalog(secureStorage: _Storage());
    await catalog.upsert(const EstablishmentMembership(id: farm, name: 'Campo', role: UserRole.employee));
    store = HealthBrickStore(brick);
    current = author;
    repository = HealthRepositoryImpl(
      store: store,
      animals: animals,
      memberships: catalog,
      session: () => current,
      now: () => date,
      generateId: generateId,
    );
  });

  tearDownAll(() async {
    await databaseFactoryFfi.deleteDatabase(sqlitePath);
    await databaseFactoryFfi.deleteDatabase(queuePath);
    await directory.delete(recursive: true);
  });

  test('catalogue gates new applications and keeps its establishment', () async {
    expect(await repository.getCatalog(farm), isNull);
    await repository.cacheCatalog(
      author,
      const HealthCatalog(establishmentId: farm, practices: [sampling], products: []),
    );
    expect((await repository.getCatalog(farm))?.practices.single, sampling);
    await expectLater(repository.getCatalog('another-farm'), throwsA(isA<HealthFailure>()));
  });

  test('queries a large set of event IDs within its establishment', () async {
    final ids = {for (var index = 0; index < 1100; index++) 'query-event-$index'};
    final first = BrickHealthEventModel(
      localId: ids.first,
      establishmentId: 'query-farm',
      animalId: 'query-animal',
      payload: '{}',
    );
    final last = BrickHealthEventModel(
      localId: ids.last,
      establishmentId: 'query-farm',
      animalId: 'query-animal-2',
      payload: '{}',
    );
    final outside = BrickHealthEventModel(
      localId: ids.elementAt(1),
      establishmentId: 'other-query-farm',
      animalId: first.animalId,
      payload: '{}',
    );
    await store.save(events: [first, last, outside]);

    expect((await store.eventsByIds(first.establishmentId, ids)).map((row) => row.localId), [
      first.localId,
      last.localId,
    ]);
    expect(await store.event(first.establishmentId, outside.localId), isNull);
    expect((await store.events(first.establishmentId, animalId: first.animalId)).single.localId, first.localId);
    expect(await store.eventsByIds(first.establishmentId, {}), isEmpty);
  });

  test('resolves RFID, visual tags and preselection only among eligible animals of the chosen farm', () async {
    const selectionFarm = 'manga-farm';
    const otherFarm = 'manga-other';
    const rfid = '911111111111111';
    const visual = 'Áb_100%';
    final animals = BrickAnimalStore.instance;
    final memberships = EstablishmentCatalog(secureStorage: _Storage());
    for (final id in [selectionFarm, otherFarm]) {
      await memberships.upsert(EstablishmentMembership(id: id, name: id, role: UserRole.employee));
    }
    final reader = HealthRepositoryImpl(
      store: store,
      animals: animals,
      memberships: memberships,
      session: () => author,
    );
    for (final (id, farm, owner, status, deletedAt) in [
      ('manga-selected', selectionFarm, author.userId, BrickAnimalSyncStatus.pending, null),
      ('manga-cross-farm', otherFarm, author.userId, BrickAnimalSyncStatus.pending, null),
      ('manga-private', selectionFarm, other.userId, BrickAnimalSyncStatus.pending, null),
      ('manga-rejected', selectionFarm, author.userId, BrickAnimalSyncStatus.rejected, null),
      ('manga-deleted', selectionFarm, author.userId, BrickAnimalSyncStatus.synchronized, date),
    ]) {
      await animals.cacheAnimal(
        _animal(
          id: id,
          rfid: rfid,
          visual: ' $visual ',
          farm: farm,
          date: date,
          owner: owner,
          status: status,
          deletedAt: deletedAt,
        ),
      );
    }
    final byRfid = await reader.findRecipient(selectionFarm, rfid, electronic: true);
    final byVisual = await reader.findRecipient(selectionFarm, '  áB_100% ', electronic: false);
    expect(byRfid?.animalId, 'manga-selected');
    expect(byVisual, byRfid);
    expect((await reader.findRecipient(otherFarm, rfid, electronic: true))?.animalId, 'manga-cross-farm');
    expect(await reader.findRecipient(selectionFarm, 'ÁB_', electronic: false), isNull);

    await animals.cacheAnimal(
      _animal(
        id: 'manga-ambiguous',
        rfid: '922222222222222',
        visual: visual,
        farm: selectionFarm,
        date: date,
        owner: author.userId,
      ),
    );
    expect(
      (await reader.getRecipients(selectionFarm, [
        'manga-ambiguous',
        'manga-cross-farm',
        'manga-selected',
      ])).map((animal) => animal.animalId),
      ['manga-ambiguous', 'manga-selected'],
    );
    await expectLater(
      reader.findRecipient(selectionFarm, visual, electronic: false),
      throwsA(isA<HealthFailure>().having((error) => error.problem, 'problem', HealthProblem.ambiguousTag)),
    );
  });

  test('persists one outbox entry for a group and one result on an existing event', () async {
    final recipients = await repository.getRecipients(farm, ['animal-1', 'animal-2']);
    final original = HealthRegistration(
      establishmentId: farm,
      occurredAt: date,
      practice: sampling,
      details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
      responsible: 'Operario',
      recipients: [
        recipients.first,
        recipients.last.copyWith(sampleReference: 'muestra-2'),
      ],
    );
    await RegisterHealthEventsUseCase(repository)(original);
    final restartedStore = HealthBrickStore(AppBrickRepository.instance);
    final creation = (await restartedStore.operations(author.userId)).single;
    expect(HealthRepositoryImpl.registrationEventIds(creation), hasLength(2));

    final history = await repository.watchHistory(farm, 'animal-2').first;
    final event = history.single;
    expect(event.recipient.sampleReference, 'muestra-2');
    expect(event.syncStatus, HealthSyncStatus.pending);

    await RecordHealthResultUseCase(repository)(event, 'Resultado informado', date);
    final attempts = await restartedStore.operations(author.userId);
    expect(attempts.where((row) => row.resultEventId == event.id), hasLength(1));
    expect(await restartedStore.events(farm, animalId: 'animal-2'), hasLength(1));
    final updated = (await repository.watchHistory(farm, 'animal-2').first).single;
    expect(updated.id, event.id);
    expect(updated.result?.value, 'Resultado informado');
    expect(updated.resultSyncStatus, HealthSyncStatus.pending);

    current = other;
    expect(await repository.watchHistory(farm, 'animal-2').first, isEmpty);
    expect(await restartedStore.operations(other.userId), isEmpty);
    expect(await repository.getRecipients(farm, ['animal-1']), isEmpty);
    current = author;

    final paths = <String>[];
    final registrationBodies = <String>[];
    final knownAnimals = <String>{};
    final resultEvent = updated.copyWith(
      result: HealthStudyResult(value: 'Aceptado desde otro teléfono', reportedAt: date, reportedById: 'other'),
    );
    final initialEvents = [
      (await repository.watchHistory(farm, 'animal-1').first).single,
      event,
    ];
    final backend = _backend(
      client: MockClient((request) async {
        paths.add('${request.method} ${request.url.path}');
        final parts = request.url.pathSegments;
        if (parts.contains('animales')) {
          if (request.method == 'GET') {
            return knownAnimals.contains(parts.last)
                ? _response({'id': parts.last, 'establecimiento_id': farm})
                : http.Response('', 404);
          }
          final body = HealthCodec.object(request.body);
          final id = body['id'] as String;
          expect(body.containsKey('local_registration_author_id'), isFalse);
          knownAnimals.add(id);
          return _response({'id': id, 'establecimiento_id': farm});
        }
        if (request.method == 'POST') {
          registrationBodies.add(request.body);
          if (registrationBodies.length == 1) throw http.ClientException('Interrupted response');
          return _response(initialEvents.map(_wire).toList());
        }
        expect(parts[parts.length - 2], event.id);
        return http.Response(
          jsonEncode({
            'success': false,
            'errors': [
              {
                'code': 'resultado_ya_completado',
                'details': {'evento': _wire(resultEvent)},
              },
            ],
          }),
          409,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final sync = HealthSyncService(
      repository: repository,
      remote: HealthRemoteDataSource(backend),
      resolveAnimal: _resolveAnimal(backend, repository),
    );
    addTearDown(sync.dispose);
    await sync.request();
    expect((await restartedStore.operations(author.userId)).map((row) => row.localId), contains(creation.localId));
    await sync.request();
    expect(registrationBodies, hasLength(2));
    expect(registrationBodies.toSet(), hasLength(1));
    expect(
      paths.where((entry) => !entry.startsWith('GET ')),
      [
        'POST /api/v1/animales',
        'POST /api/v1/animales',
        'POST /api/v1/eventos_sanitarios',
        'POST /api/v1/eventos_sanitarios',
        'PUT /api/v1/eventos_sanitarios/${event.id}/resultado',
      ],
    );
    final reconciled = (await repository.watchHistory(farm, 'animal-2').first).single;
    expect(reconciled.result?.value, resultEvent.result?.value);
    expect(reconciled.resultSyncStatus, isNull);
    expect(reconciled.resultIssue, HealthSyncIssue.resultAlreadyRecorded);
    expect(await restartedStore.operations(author.userId), isEmpty);
  });

  test('applies the canonical result and tombstone without consuming drafts on unrelated changes', () async {
    await repository.cacheCatalog(
      author,
      const HealthCatalog(establishmentId: farm, practices: [sampling], products: []),
    );
    final recipients = await repository.getRecipients(farm, ['animal-1', 'animal-2']);
    await RegisterHealthEventsUseCase(repository)(
      HealthRegistration(
        establishmentId: farm,
        occurredAt: date,
        practice: sampling,
        details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
        responsible: 'Resultados',
        recipients: recipients,
      ),
    );
    final creation = (await store.operations(author.userId)).single;
    final events = [
      for (final id in HealthRepositoryImpl.registrationEventIds(creation))
        (await repository.localEvent(farm, id))!.copyWith(syncStatus: HealthSyncStatus.synchronized),
    ];
    await repository.accept(author, creation, events);
    final [first, second] = events;
    await RecordHealthResultUseCase(repository)(first, 'Resultado rechazado', date);
    final rejected = (await store.operations(author.userId)).single;
    const legacyDetails = (animalId: null, field: HealthRejectionField.result);
    await store.save(
      events: [
        HealthCodec.eventRow(
          first.copyWith(
            result: HealthStudyResult(value: 'Resultado rechazado', reportedAt: date, reportedById: author.userId),
            resultSyncStatus: HealthSyncStatus.rejected,
            resultRejection: legacyDetails,
          ),
        ),
      ],
      operations: [
        BrickHealthOperationModel(
          localId: rejected.localId,
          establishmentId: rejected.establishmentId,
          authorId: rejected.authorId,
          createdAt: rejected.createdAt,
          payload: rejected.payload,
          resultEventId: rejected.resultEventId,
          rejection: 'resultado_invalido',
        ),
      ],
    );
    await RecordHealthResultUseCase(repository)(second, 'Resultado pendiente', date);

    current = other;
    addTearDown(() => current = author);
    final metadataTime = date.add(const Duration(minutes: 1));
    await repository.reconcilePage(other, farm, [first.copyWith(notes: 'Nota vigente', updatedAt: metadataTime)], '1');
    current = author;
    final retained = (await repository.watchHistory(farm, first.recipient.animalId).first).singleWhere(
      (event) => event.id == first.id,
    );
    expect(retained.notes, 'Nota vigente');
    expect(retained.result?.value, 'Resultado rechazado');
    expect(retained.resultSyncStatus, HealthSyncStatus.rejected);
    expect(retained.resultRejection, legacyDetails);
    expect(await store.operations(author.userId), hasLength(2));

    final updated = date.add(const Duration(minutes: 2));
    final canonical = HealthStudyResult(value: 'Resultado vigente', reportedAt: updated, reportedById: other.userId);
    current = other;
    await repository.reconcilePage(other, farm, [
      first.copyWith(result: canonical, updatedAt: updated),
      second.copyWith(deletedAt: updated, updatedAt: updated),
    ], '2');

    final visible = (await repository.watchHistory(farm, first.recipient.animalId).first).singleWhere(
      (event) => event.id == first.id,
    );
    expect(visible.result, canonical);
    expect(visible.resultSyncStatus, isNull);
    expect(visible.resultIssue, isNull);
    expect(await repository.localEvent(farm, second.id), isNotNull);
    expect(
      (await repository.watchHistory(farm, second.recipient.animalId).first).map((event) => event.id),
      isNot(contains(second.id)),
    );
    expect(await store.operations(author.userId), isEmpty);
    expect(await repository.cursor(farm), '2');
  });

  test('isolates study drafts between accounts on one device and clears both on acceptance', () async {
    await repository.cacheCatalog(
      author,
      const HealthCatalog(establishmentId: farm, practices: [sampling], products: []),
    );
    final recipients = await repository.getRecipients(farm, ['animal-1']);
    await RegisterHealthEventsUseCase(repository)(
      HealthRegistration(
        establishmentId: farm,
        occurredAt: date,
        practice: sampling,
        details: const HealthObservation(description: 'Muestreo compartido', sampleType: 'Sangre'),
        responsible: 'Operario',
        recipients: recipients,
      ),
    );
    final creation = (await store.operations(author.userId)).single;
    final id = HealthRepositoryImpl.registrationEventIds(creation).single;
    final study = (await repository.localEvent(farm, id))!.copyWith(syncStatus: HealthSyncStatus.synchronized);
    await repository.accept(author, creation, [study]);

    Future<HealthEvent> visible() async =>
        (await repository.watchHistory(farm, 'animal-1').first).singleWhere((event) => event.id == id);

    await RecordHealthResultUseCase(repository)(study, 'Resultado privado de A', date);
    final draftA = (await store.operations(author.userId)).single;
    const details = (animalId: null, field: HealthRejectionField.result);
    await repository.reject(author, draftA, 'resultado_invalido', details: details);
    expect((await visible()).resultRejection, details);

    current = other;
    addTearDown(() => current = author);
    final available = await visible();
    expect(available.result, isNull);
    expect(available.resultRejection, isNull);
    await RecordHealthResultUseCase(repository)(available, 'Resultado privado de B', date);
    await expectLater(
      RecordHealthResultUseCase(repository)(available, 'Duplicado de B', date),
      throwsA(isA<HealthFailure>()),
    );
    expect((await visible()).result?.value, 'Resultado privado de B');
    expect(await repository.localEvent(farm, id), study);
    final draftB = (await store.operations(other.userId)).single;
    expect(draftB.localId, isNot(draftA.localId));

    current = author;
    final retained = await visible();
    expect(retained.result?.value, 'Resultado privado de A');
    expect(retained.resultSyncStatus, HealthSyncStatus.rejected);
    expect(retained.resultRejection, details);

    current = other;
    final reportedAt = date.add(const Duration(hours: 1));
    final result = HealthStudyResult(
      value: 'Resultado privado de B',
      reportedAt: reportedAt,
      reportedById: other.userId,
    );
    await repository.accept(other, draftB, [study.copyWith(result: result, updatedAt: reportedAt)]);
    expect(await store.operations(other.userId), isEmpty);
    expect(await store.operations(author.userId), isEmpty);
    current = author;
    final shared = await visible();
    expect(shared.result, result);
    expect(shared.resultSyncStatus, isNull);
    expect(shared.resultRejection, isNull);
  });

  test('allows correcting a group after a definitive animal rejection and keeps an excluded study result', () async {
    await repository.cacheCatalog(
      author,
      const HealthCatalog(establishmentId: farm, practices: [sampling], products: []),
    );
    final recipients = await repository.getRecipients(farm, ['animal-3', 'animal-4']);
    final registration = HealthRegistration(
      establishmentId: farm,
      occurredAt: date,
      practice: sampling,
      details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
      responsible: 'Operario',
      recipients: [
        recipients.first.copyWith(sampleReference: 'muestra-3'),
        recipients.last,
      ],
    );
    await RegisterHealthEventsUseCase(repository)(registration);
    final group = (await store.operations(author.userId)).single;
    final kept = (await repository.watchHistory(farm, 'animal-3').first).single;
    final blocked = (await repository.watchHistory(farm, 'animal-4').first).single;
    await RecordHealthResultUseCase(repository)(blocked, 'Resultado de muestra 4', date);

    var rejectedAnimalAttempts = 0;
    final groupRequests = <List<String>>[];
    final backend = _backend(
      client: MockClient((request) async {
        final resource = request.url.pathSegments.last;
        if (resource == 'animal-3') return _response({'id': resource, 'establecimiento_id': farm});
        if (resource == 'animal-4') return http.Response('', 404);
        if (resource == 'animales') {
          if (++rejectedAnimalAttempts == 1) return http.Response('', 503);
          return http.Response(
            jsonEncode({
              'success': false,
              'errors': [
                {'code': 'caravana_duplicada'},
              ],
            }),
            409,
            headers: {'content-type': 'application/json'},
          );
        }
        final body = HealthCodec.object(request.body);
        final animals = (body['animales'] as List).cast<Map<String, dynamic>>();
        groupRequests.add([for (final animal in animals) animal['animal_id'] as String]);
        expect(body['id'], isNot(group.localId));
        expect(animals.single['id'], kept.id);
        expect(animals.single['referencia_muestra'], 'muestra-3');
        return _response([_wire(kept)]);
      }),
    );
    final sync = HealthSyncService(
      repository: repository,
      remote: HealthRemoteDataSource(backend),
      resolveAnimal: _resolveAnimal(backend, repository),
    );
    addTearDown(sync.dispose);

    await sync.request();
    expect((await repository.localEvent(farm, kept.id))?.syncStatus, HealthSyncStatus.pending);
    await sync.request();
    final rejected = (await repository.localEvent(farm, kept.id))!;
    expect(rejected.syncStatus, HealthSyncStatus.rejected);
    expect(rejected.syncIssue, HealthSyncIssue.animalRegistrationRejected);
    expect(groupRequests, isEmpty);

    final draft = (await repository.getRejectedRegistration(rejected))!;
    expect(draft.id, group.localId);
    expect(draft.rejection, (animalId: 'animal-4', field: null));
    expect(draft.registration.recipients, hasLength(2));
    final selectable = await repository.getRecipients(farm, ['animal-3', 'animal-4']);
    expect(selectable.map((recipient) => recipient.animalId), ['animal-3']);
    await RegisterHealthEventsUseCase(repository)(
      draft.registration.copyWith(
        recipients: [draft.registration.recipients.firstWhere((r) => r.animalId == 'animal-3')],
      ),
      replacingOperationId: draft.id,
    );
    await sync.request();

    expect(groupRequests, [
      ['animal-3'],
    ]);
    expect((await repository.localEvent(farm, kept.id))?.syncStatus, HealthSyncStatus.synchronized);
    final remaining = (await repository.watchHistory(farm, 'animal-4').first).singleWhere(
      (event) => event.id == blocked.id,
    );
    expect(remaining.syncStatus, HealthSyncStatus.rejected);
    expect(remaining.result?.value, 'Resultado de muestra 4');
    final pendingCorrection = (await repository.getRejectedRegistration(remaining))!;
    expect(pendingCorrection.registration.recipients.map((recipient) => recipient.animalId), ['animal-4']);
    expect(await store.operations(author.userId), hasLength(2));
  });

  test('persists the affected animal and field from a rejected group response', () async {
    await repository.cacheCatalog(
      author,
      const HealthCatalog(establishmentId: farm, practices: [sampling], products: []),
    );
    final recipients = await repository.getRecipients(farm, ['animal-1', 'animal-2']);
    final existingIds = (await store.operations(author.userId)).map((item) => item.localId).toSet();
    await RegisterHealthEventsUseCase(repository)(
      HealthRegistration(
        establishmentId: farm,
        occurredAt: date,
        practice: sampling,
        details: const HealthObservation(description: 'Muestreo', sampleType: 'Sangre'),
        responsible: 'Operario',
        recipients: recipients,
      ),
    );
    final group = (await store.operations(author.userId)).singleWhere((item) => !existingIds.contains(item.localId));
    final adapter = _healthRemote(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        return http.Response(
          jsonEncode({
            'success': false,
            'errors': [
              {
                'code': 'referencia_muestra_no_valida',
                'details': {'animal_id': 'animal-2', 'campo': 'animales.1.referencia_muestra'},
              },
            ],
          }),
          422,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final sync = HealthSyncService(
      repository: repository,
      remote: adapter,
      resolveAnimal: (_, _, _, _) async => AnimalRegistrationAvailability.confirmed,
    );
    addTearDown(sync.dispose);
    await sync.request();

    final ids = HealthRepositoryImpl.registrationEventIds(group);
    final reloaded = HealthBrickStore(AppBrickRepository.instance);
    final row = (await reloaded.events(farm, animalId: 'animal-1')).singleWhere((item) => ids.contains(item.localId));
    final rejected = HealthCodec.eventFrom(HealthCodec.object(row.payload));
    final correction = (await repository.getRejectedRegistration(rejected))!;
    expect(rejected.syncStatus, HealthSyncStatus.rejected);
    expect(correction.rejection, (animalId: 'animal-2', field: HealthRejectionField.sampleReference));
    expect(correction.registration.recipients.map((recipient) => recipient.animalId), ['animal-1', 'animal-2']);
  });

  test('a form refresh shares the catalog download without submitting operations or pulling history', () async {
    final requests = <http.Request>[];
    final started = Completer<void>();
    final response = Completer<http.Response>();
    final original = (await repository.getCatalog(farm))!;
    final refreshed = original.copyWith(practices: [sampling.copyWith(name: 'Sangrado habilitado')]);
    final sync = HealthSyncService(
      repository: repository,
      remote: _healthRemote(
        client: MockClient((request) {
          requests.add(request);
          if (!started.isCompleted) started.complete();
          return response.future;
        }),
      ),
      resolveAnimal: (_, _, _, _) async => fail('Catalog refresh must not resolve an animal'),
    );
    addTearDown(sync.dispose);

    final first = sync.refreshCatalog(farm);
    await started.future;
    final second = sync.refreshCatalog(farm);
    response.complete(_response(HealthCodec.catalogTo(refreshed)));
    await Future.wait([first, second]);

    final request = requests.single;
    expect(request.method, 'GET');
    expect(request.url.path, '/api/v1/eventos_sanitarios/catalogo');
    expect(request.url.queryParameters, {'establecimiento_id': farm});
    expect(await repository.getCatalog(farm), refreshed);
    await repository.cacheCatalog(author, original);
  });

  test('a catalog response received after changing accounts is discarded', () async {
    final started = Completer<void>();
    final response = Completer<http.Response>();
    final original = (await repository.getCatalog(farm))!;
    final refreshed = original.copyWith(practices: [sampling.copyWith(name: 'Sangrado de la sesión anterior')]);
    final sync = HealthSyncService(
      repository: repository,
      remote: _healthRemote(
        client: MockClient((_) {
          started.complete();
          return response.future;
        }),
      ),
      resolveAnimal: (_, _, _, _) async => fail('Catalog refresh must not resolve an animal'),
    );
    addTearDown(sync.dispose);
    addTearDown(() => current = author);

    final refresh = sync.refreshCatalog(farm);
    await started.future;
    current = other;
    response.complete(_response(HealthCodec.catalogTo(refreshed)));
    await refresh;

    expect(await repository.getCatalog(farm), original);
  });

  test('refreshes the history and catalog independently during a partial outage', () async {
    final requests = <Uri>[];
    final freshPractice = sampling.copyWith(name: 'Sangrado actualizado');
    var unavailable = 'catalogo';
    final adapter = _healthRemote(
      client: MockClient((request) async {
        requests.add(request.url);
        final resource = request.url.pathSegments.last;
        if (resource == unavailable) return http.Response('', 503);
        if (resource == 'catalogo') {
          return _response(
            HealthCodec.catalogTo(HealthCatalog(establishmentId: farm, practices: [freshPractice], products: [])),
          );
        }
        return http.Response(
          jsonEncode({
            'success': true,
            'data': const <Object?>[],
            'meta': {'next_cursor': 'available-history', 'has_more': false},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final sync = HealthSyncService(
      repository: repository,
      remote: adapter,
      resolveAnimal: (_, _, _, _) async => AnimalRegistrationAvailability.confirmed,
    );
    addTearDown(sync.dispose);

    final cached = await repository.getCatalog(farm);
    expect(await sync.request(refresh: true), isFalse);
    expect(requests.map((uri) => uri.pathSegments.last), ['catalogo', 'eventos_sanitarios']);
    expect(await repository.cursor(farm), 'available-history');
    expect(await repository.getCatalog(farm), cached);

    unavailable = 'eventos_sanitarios';
    requests.clear();
    expect(await sync.request(refresh: true), isFalse);
    expect(requests.map((uri) => uri.pathSegments.last), ['catalogo', 'eventos_sanitarios']);
    expect(requests.last.queryParameters['cursor'], 'available-history');
    expect(await repository.cursor(farm), 'available-history');
    expect((await repository.getCatalog(farm))?.practices.single, freshPractice);

    unavailable = '';
    expect(await sync.request(refresh: true), isTrue);
    await repository.cacheCatalog(
      author,
      const HealthCatalog(establishmentId: farm, practices: [sampling], products: []),
    );
  });

  for (final sendDuringDownload in [false, true]) {
    final timing = sendDuringDownload ? 'during the download' : 'after the retry is scheduled';
    test('preserves a failed history retry when an upload starts $timing', () async {
      const catalog = HealthCatalog(establishmentId: farm, practices: [sampling], products: []);
      await repository.reconcilePage(author, farm, [], 'before-outage');
      final historyStarted = Completer<void>();
      final firstHistory = Completer<http.Response>();
      final retries = <_RetryTimer>[];
      final requests = <String>[];
      late HealthEvent submitted;
      final adapter = _healthRemote(
        client: MockClient((request) async {
          final resource = request.url.pathSegments.last;
          requests.add('${request.method} $resource');
          if (request.method == 'POST') return _response([_wire(submitted)]);
          if (resource == 'catalogo') return _response(HealthCodec.catalogTo(catalog));
          if (!historyStarted.isCompleted) {
            historyStarted.complete();
            return firstHistory.future;
          }
          expect(request.url.queryParameters['cursor'], 'before-outage');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': const <Object?>[],
              'meta': {'next_cursor': 'history-recovered', 'has_more': false},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      final sync = HealthSyncService(
        repository: repository,
        remote: adapter,
        resolveAnimal: (_, _, _, _) async => AnimalRegistrationAvailability.confirmed,
      );
      addTearDown(sync.dispose);

      await runZoned(
        () async {
          final download = sync.request(refresh: true);
          await historyStarted.future;
          if (!sendDuringDownload) {
            firstHistory.complete(http.Response('', 503));
            expect(await download, isFalse);
            expect(retries.single.isActive, isTrue);
          }

          final prior = (await store.operations(author.userId)).map((item) => item.localId).toSet();
          final recipients = await repository.getRecipients(farm, ['animal-1']);
          await RegisterHealthEventsUseCase(repository)(
            HealthRegistration(
              establishmentId: farm,
              occurredAt: date,
              practice: sampling,
              details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
              responsible: 'Operario',
              recipients: recipients,
            ),
          );
          final operation = (await store.operations(
            author.userId,
          )).singleWhere((item) => !prior.contains(item.localId));
          submitted = (await repository.localEvent(farm, HealthRepositoryImpl.registrationEventIds(operation).single))!;
          final upload = sync.request();
          if (sendDuringDownload) firstHistory.complete(http.Response('', 503));
          expect(await download, isFalse);
          expect(await upload, !sendDuringDownload);
          expect(
            (await store.operations(author.userId)).map((item) => item.localId),
            isNot(contains(operation.localId)),
          );
          expect(requests, ['GET catalogo', 'GET eventos_sanitarios', 'POST eventos_sanitarios']);
          expect(await repository.cursor(farm), 'before-outage');

          expect(retries.single.isActive, isTrue);
          retries.single.fire();
          expect(await sync.request(), isTrue);
          expect(requests, [
            'GET catalogo',
            'GET eventos_sanitarios',
            'POST eventos_sanitarios',
            'GET catalogo',
            'GET eventos_sanitarios',
          ]);
          expect(await repository.cursor(farm), 'history-recovered');
        },
        zoneSpecification: ZoneSpecification(
          createTimer: (self, parent, zone, duration, callback) {
            if (duration != const Duration(seconds: 30)) return parent.createTimer(zone, duration, callback);
            final timer = _RetryTimer(() => zone.run(callback));
            retries.add(timer);
            return timer;
          },
        ),
      );
    });
  }

  test('an older backend without sanitary routes keeps a refresh compatible', () async {
    final requests = <String>[];
    final adapter = _healthRemote(
      client: MockClient((request) async {
        requests.add(request.url.pathSegments.last);
        return http.Response('{"detail":"Not Found"}', 404);
      }),
    );
    final sync = HealthSyncService(
      repository: repository,
      remote: adapter,
      resolveAnimal: (_, _, _, _) async => AnimalRegistrationAvailability.confirmed,
    );
    addTearDown(sync.dispose);

    expect(await sync.request(refresh: true), isTrue);
    expect(requests, ['catalogo', 'eventos_sanitarios']);
  });

  test('resumes a blocked result only after its rejected study is corrected', () async {
    await repository.cacheCatalog(
      author,
      const HealthCatalog(establishmentId: farm, practices: [sampling], products: []),
    );
    final before = (await store.operations(author.userId)).map((item) => item.localId).toSet();
    final recipients = await repository.getRecipients(farm, ['animal-1']);
    await RegisterHealthEventsUseCase(repository)(
      HealthRegistration(
        establishmentId: farm,
        occurredAt: date,
        practice: sampling,
        details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
        responsible: 'Operario',
        recipients: recipients,
      ),
    );
    final group = (await store.operations(author.userId)).singleWhere((item) => !before.contains(item.localId));
    final id = HealthRepositoryImpl.registrationEventIds(group).single;
    final study = (await repository.localEvent(farm, id))!;
    await RecordHealthResultUseCase(repository)(study, 'Resultado conservado', date);

    final methods = <String>[];
    var valid = false;
    final confirmed = study.copyWith(syncStatus: HealthSyncStatus.synchronized);
    final result = HealthStudyResult(value: 'Resultado conservado', reportedAt: date, reportedById: author.userId);
    final adapter = _healthRemote(
      client: MockClient((request) async {
        methods.add(request.method);
        if (!valid) {
          return http.Response(
            jsonEncode({
              'success': false,
              'errors': [
                {'code': 'registro_invalido'},
              ],
            }),
            422,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.method == 'POST') return _response([_wire(confirmed)]);
        expect(request.url.pathSegments, contains(id));
        expect(HealthCodec.object(request.body)['resultado'], 'Resultado conservado');
        return _response(_wire(confirmed.copyWith(result: result)));
      }),
    );
    final sync = HealthSyncService(
      repository: repository,
      remote: adapter,
      resolveAnimal: (_, _, _, _) async => AnimalRegistrationAvailability.confirmed,
    );
    addTearDown(sync.dispose);

    await sync.request();
    await sync.request();
    expect(methods, ['POST']);
    expect((await repository.pendingOperations()).where((item) => item.resultEventId == id), isEmpty);
    expect((await repository.visibleOperations()).where((item) => item.resultEventId == id), hasLength(1));
    final rejected = (await repository.watchHistory(farm, 'animal-1').first).singleWhere((event) => event.id == id);
    expect(rejected.result, result);
    expect(rejected.syncStatus, HealthSyncStatus.rejected);

    final draft = (await repository.getRejectedRegistration(rejected))!;
    valid = true;
    await RegisterHealthEventsUseCase(repository)(draft.registration, replacingOperationId: draft.id);
    expect((await repository.pendingOperations()).where((item) => item.resultEventId == id), hasLength(1));
    await sync.request();

    expect(methods, ['POST', 'POST', 'PUT']);
    expect((await repository.visibleOperations()).where((item) => item.resultEventId == id), isEmpty);
    expect((await repository.localEvent(farm, id))?.result, result);
  });

  for (final deleted in [false, true]) {
    final change = deleted ? 'tombstone' : 'result';
    test('preserves a canonical $change received before the lost create response is replayed', () async {
      final farm = 'replay-$change';
      final session = (userId: 'author-$change', generation: 1);
      final animals = BrickAnimalStore.instance;
      await animals.cacheAnimal(
        _animal(id: 'animal-$change', rfid: '', visual: '101', farm: farm, date: date, owner: session.userId),
      );
      final memberships = EstablishmentCatalog(secureStorage: _Storage());
      await memberships.upsert(EstablishmentMembership(id: farm, name: 'Campo', role: UserRole.employee));
      final repository = HealthRepositoryImpl(
        store: store,
        animals: animals,
        memberships: memberships,
        session: () => session,
        now: () => date,
        generateId: generateId,
      );
      final catalog = HealthCatalog(establishmentId: farm, practices: [sampling], products: const []);
      await repository.cacheCatalog(session, catalog);
      await RegisterHealthEventsUseCase(repository)(
        HealthRegistration(
          establishmentId: farm,
          occurredAt: date,
          practice: sampling,
          details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
          responsible: 'Operario',
          recipients: await repository.getRecipients(farm, ['animal-$change']),
        ),
      );
      final operation = (await store.operations(session.userId)).single;
      final id = HealthRepositoryImpl.registrationEventIds(operation).single;
      final pending = (await repository.localEvent(farm, id))!;
      final original = pending.copyWith(syncStatus: HealthSyncStatus.synchronized);
      final updated = date.add(const Duration(minutes: 10));
      final canonical = original.copyWith(
        updatedAt: updated,
        deletedAt: deleted ? updated : null,
        result: deleted
            ? null
            : HealthStudyResult(value: 'Resultado confirmado', reportedAt: updated, reportedById: other.userId),
      );
      await RecordHealthResultUseCase(repository)(pending, 'Resultado local pendiente', date);
      var replayAvailable = false;
      var historyReads = 0;
      final cursor = 'cursor-after-$change';
      final sync = HealthSyncService(
        repository: repository,
        remote: _healthRemote(
          client: MockClient((request) async {
            if (request.method == 'POST') {
              expect(request.body, operation.payload);
              return replayAvailable ? _response([_wire(original)]) : http.Response('', 503);
            }
            expect(request.method, 'GET');
            if (request.url.path.endsWith('/catalogo')) return _response(HealthCodec.catalogTo(catalog));
            final firstPage = historyReads++ == 0;
            if (!firstPage) expect(request.url.queryParameters['cursor'], cursor);
            return http.Response(
              jsonEncode({
                'success': true,
                'data': [if (firstPage) _wire(canonical)],
                'meta': {'next_cursor': cursor, 'has_more': false},
              }),
              200,
            );
          }),
        ),
        resolveAnimal: (_, _, _, _) async => AnimalRegistrationAvailability.confirmed,
      );
      addTearDown(sync.dispose);
      expect(await sync.request(refresh: true), isFalse);
      expect(await repository.cursor(farm), cursor);
      expect(await repository.localEvent(farm, id), canonical);
      expect((await store.operations(session.userId)).single.localId, operation.localId);

      replayAvailable = true;
      expect(await sync.request(refresh: true), isTrue);
      expect(await store.operations(session.userId), isEmpty);
      expect(await repository.localEvent(farm, id), canonical);
    });
  }

  test('rolls back all changes when the session changes inside a transaction', () async {
    var calls = 0;
    await expectLater(
      store.save(
        events: [
          BrickHealthEventModel(localId: 'rollback-1', establishmentId: farm, animalId: 'rollback', payload: '{}'),
          BrickHealthEventModel(localId: 'rollback-2', establishmentId: farm, animalId: 'rollback', payload: '{}'),
        ],
        requireSession: () {
          if (++calls == 2) throw StateError('session switched');
        },
      ),
      throwsStateError,
    );
    expect(await store.events(farm, animalId: 'rollback'), isEmpty);
  });
}

Map<String, dynamic> _wire(HealthEvent event) => HealthCodec.object(HealthCodec.eventRow(event).payload);

BrickAnimalModel _animal({
  required String id,
  required String rfid,
  required String visual,
  required String farm,
  required DateTime date,
  required String owner,
  DateTime? deletedAt,
  BrickAnimalSyncStatus status = BrickAnimalSyncStatus.pending,
}) => BrickAnimalModel(
  localId: id,
  rfidTagNumber: rfid,
  visualTag: visual,
  sex: BrickAnimalSex.female,
  breed: '',
  birthDate: date,
  categoryId: '',
  lotId: '',
  establishmentId: farm,
  initialWeight: 0,
  weighingMethod: BrickAnimalWeighingMethod.manual,
  weighingDate: date,
  createdAt: date,
  updatedAt: date,
  productiveStatus: BrickAnimalProductiveStatus.active,
  localRegistrationAuthorId: owner,
  deletedAt: deletedAt,
  syncStatus: status,
);

HealthRemoteDataSource _healthRemote({required http.Client client}) => HealthRemoteDataSource(_backend(client: client));

ResolveHealthAnimal _resolveAnimal(GuardedBackendRequest backend, HealthRepositoryImpl repository) {
  final recovery = AnimalRegistrationRecovery(BrickAnimalStore.instance, backend);
  return (id, establishmentId, session, guard) => recovery(
    id: id,
    establishmentId: establishmentId,
    authorId: session.userId,
    guard: guard,
    requireSession: () => repository.requireSession(session),
  );
}

GuardedBackendRequest _backend({required http.Client client}) => GuardedBackendRequest(
  baseUrl: 'http://localhost',
  send: AuthenticatedBackendClient(
    tokenProvider: const _Tokens(),
    inner: client,
    onSyncResult: (_) async => fail('The guarded transport must not publish a second sync result'),
  ).sendGuarded,
);

class _RetryTimer implements Timer {
  _RetryTimer(this.callback);

  final void Function() callback;
  bool _active = true;
  int _tick = 0;

  @override
  bool get isActive => _active;

  @override
  int get tick => _tick;

  @override
  void cancel() => _active = false;

  void fire() {
    if (!_active) return;
    _active = false;
    _tick++;
    callback();
  }
}

http.Response _response(Object data) => http.Response(
  jsonEncode({'success': true, 'data': data}),
  200,
  headers: {'content-type': 'application/json'},
);

class _Tokens implements RefreshableBackendAccessTokenProvider {
  const _Tokens();

  @override
  Future<String?> getAccessToken() async => 'synthetic';

  @override
  Future<String?> refreshAccessToken() async => 'synthetic-refresh';
}

class _Storage implements SecureStorageService {
  final _values = <String, String>{};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write({required String key, required String value}) async => _values[key] = value;
}
